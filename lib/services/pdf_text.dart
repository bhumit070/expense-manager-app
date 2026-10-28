import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dart_pdf_reader/dart_pdf_reader.dart';

/// The PDF is password-protected; the user must save an unlocked copy.
class PdfLockedException implements Exception {
  const PdfLockedException();

  @override
  String toString() => 'This PDF is password-protected. Save an unlocked copy (Print → Save as PDF) and import that.';
}

/// The bytes are not a PDF we can read.
class PdfUnreadableException implements Exception {
  const PdfUnreadableException(this.cause);

  final Object cause;

  @override
  String toString() => 'Could not read this PDF ($cause)';
}

/// Extracts the visible text of a PDF as lines, top to bottom, page by page.
///
/// Pure Dart (no native code): parses the file with `dart_pdf_reader`, then
/// interprets each page's content stream, positioning glyphs with the text
/// and graphics matrices so table rows come out as single lines. Fragments
/// separated by a wide gap are joined with two spaces (a column break).
Future<List<String>> extractPdfLines(Uint8List bytes) async {
  try {
    final doc = await PDFParser(ByteStream(bytes)).parse();
    if (doc.mainTrailer.has(const PDFName('Encrypt'))) throw const PdfLockedException();
    final pages = await (await doc.catalog).getPages();
    final lines = <String>[];
    for (var i = 0; i < pages.pageCount; i++) {
      final page = pages.getPageAtIndex(i);
      final frags = <_Frag>[];
      final interp = _Interpreter(page.objectResolver, frags);
      for (final s in await page.contentStreams ?? const <PDFStreamObject>[]) {
        await interp.run(await s.read(page.objectResolver), await page.resources, _Matrix.identity);
      }
      lines.addAll(_layout(frags));
    }
    return lines;
  } on PdfLockedException {
    rethrow;
  } catch (e) {
    throw PdfUnreadableException(e);
  }
}

/// A run of text placed at (x, y) in page space.
class _Frag {
  _Frag(this.x, this.y, this.end, this.size, this.text);

  final double x, y, end, size;
  final String text;
}

/// Groups fragments into lines (same baseline) and joins them left to right.
List<String> _layout(List<_Frag> frags) {
  frags.sort((a, b) => b.y.compareTo(a.y));
  final rows = <List<_Frag>>[];
  for (final f in frags) {
    if (rows.isNotEmpty && (rows.last.first.y - f.y).abs() <= math.max(2, rows.last.first.size * 0.4)) {
      rows.last.add(f);
    } else {
      rows.add([f]);
    }
  }
  final out = <String>[];
  for (final row in rows) {
    row.sort((a, b) => a.x.compareTo(b.x));
    final b = StringBuffer(row.first.text);
    for (var i = 1; i < row.length; i++) {
      final gap = row[i].x - row[i - 1].end;
      if (gap > row[i].size * 1.2) {
        b.write('  ');
      } else if (gap > row[i].size * 0.15) {
        b.write(' ');
      }
      b.write(row[i].text);
    }
    final line = b.toString().replaceAll(RegExp(r' {3,}'), '  ').trim();
    if (line.isNotEmpty) out.add(line);
  }
  return out;
}

class _Matrix {
  const _Matrix(this.a, this.b, this.c, this.d, this.e, this.f);

  static const identity = _Matrix(1, 0, 0, 1, 0, 0);

  factory _Matrix.of(List<Object?> v) => _Matrix(_n(v[0]), _n(v[1]), _n(v[2]), _n(v[3]), _n(v[4]), _n(v[5]));

  final double a, b, c, d, e, f;

  /// this × o (apply this first, then o).
  _Matrix times(_Matrix o) => _Matrix(a * o.a + b * o.c, a * o.b + b * o.d, c * o.a + d * o.c, c * o.b + d * o.d, e * o.a + f * o.c + o.e, e * o.b + f * o.d + o.f);

  _Matrix translate(double tx, double ty) => _Matrix(1, 0, 0, 1, tx, ty).times(this);

  double get scaleY => math.sqrt(c * c + d * d);
}

double _n(Object? v) => (v as num).toDouble();

class _Name {
  const _Name(this.v);

  final String v;
}

class _Op {
  const _Op(this.v);

  final String v;
}

/// Tokenizer for content streams and CMaps (PDF syntax subset).
class _Lexer {
  _Lexer(this.s);

  final Uint8List s;
  int i = 0;

  static bool _ws(int c) => c == 0 || c == 9 || c == 10 || c == 12 || c == 13 || c == 32;

  static bool _delim(int c) => _ws(c) || '()<>[]{}/%'.codeUnits.contains(c);

  /// Next object, or null at end of input.
  Object? next() {
    while (i < s.length && (_ws(s[i]) || s[i] == 0x25)) {
      if (s[i] == 0x25) {
        while (i < s.length && s[i] != 10 && s[i] != 13) {
          i++;
        }
      } else {
        i++;
      }
    }
    if (i >= s.length) return null;
    final c = s[i];
    if (c == 0x28) return _literal();
    if (c == 0x3C && i + 1 < s.length && s[i + 1] == 0x3C) {
      i += 2;
      final map = <String, Object?>{};
      for (var k = next(); k is _Name; k = next()) {
        map[k.v] = next();
      }
      return map;
    }
    if (c == 0x3C) return _hex();
    if (c == 0x5B) {
      i++;
      final list = <Object?>[];
      for (var o = next(); o != null && !(o is _Op && o.v == ']'); o = next()) {
        list.add(o);
      }
      return list;
    }
    final start = c == 0x2F ? ++i : i;
    if (c != 0x2F && _delim(c)) {
      // `]`, `>>`, braces or a stray `)`: return it as a one-off operator.
      final two = c == 0x3E && i + 1 < s.length && s[i + 1] == 0x3E;
      i += two ? 2 : 1;
      return _Op(String.fromCharCodes(s, start, i));
    }
    while (i < s.length && !_delim(s[i])) {
      i++;
    }
    final word = String.fromCharCodes(s, start, i);
    if (c == 0x2F) return _Name(word);
    return num.tryParse(word) ?? _Op(word);
  }

  Uint8List _literal() {
    i++;
    final out = BytesBuilder();
    var depth = 1;
    while (i < s.length) {
      var c = s[i++];
      if (c == 0x5C) {
        c = s[i++];
        const esc = {0x6E: 10, 0x72: 13, 0x74: 9, 0x62: 8, 0x66: 12};
        if (c >= 0x30 && c <= 0x37) {
          var v = c - 0x30;
          for (var k = 0; k < 2 && s[i] >= 0x30 && s[i] <= 0x37; k++) {
            v = v * 8 + s[i++] - 0x30;
          }
          out.addByte(v & 0xFF);
        } else if (c != 10 && c != 13) {
          out.addByte(esc[c] ?? c);
        }
        continue;
      }
      if (c == 0x28) depth++;
      if (c == 0x29 && --depth == 0) break;
      out.addByte(c);
    }
    return out.takeBytes();
  }

  Uint8List _hex() {
    final end = s.indexOf(0x3E, i);
    final digits = String.fromCharCodes(s, i + 1, end).replaceAll(RegExp(r'\s'), '');
    i = end + 1;
    final even = digits.length.isOdd ? '${digits}0' : digits;
    return Uint8List.fromList([for (var k = 0; k < even.length; k += 2) int.parse(even.substring(k, k + 2), radix: 16)]);
  }

  /// Skips inline image data after `ID` up to and including `EI`.
  void skipInlineImage() {
    bool atEnd(int k) => _ws(s[k]) && s[k + 1] == 0x45 && s[k + 2] == 0x49 && (k + 3 == s.length || _ws(s[k + 3]));
    while (i + 2 < s.length && !atEnd(i)) {
      i++;
    }
    i += 3;
  }
}

/// Maps character codes of one font to text and glyph widths.
class _Font {
  _Font({required this.bytesPerCode, required this.widths, required this.defaultWidth, required this.toUnicode, required this.differences});

  final int bytesPerCode;
  final Map<int, double> widths;
  final double defaultWidth;
  final Map<int, String> toUnicode;
  final Map<int, String> differences;

  static final fallback = _Font(bytesPerCode: 1, widths: const {}, defaultWidth: 500, toUnicode: const {}, differences: const {});

  Iterable<(String, double)> decode(Uint8List bytes) sync* {
    for (var k = 0; k + bytesPerCode <= bytes.length; k += bytesPerCode) {
      final code = bytesPerCode == 2 ? bytes[k] << 8 | bytes[k + 1] : bytes[k];
      final text = toUnicode[code] ?? differences[code] ?? (bytesPerCode == 1 ? _winAnsi(code) : String.fromCharCode(code));
      yield (text, widths[code] ?? defaultWidth);
    }
  }
}

String _winAnsi(int code) {
  const high = {0x80: '€', 0x91: '‘', 0x92: '’', 0x93: '“', 0x94: '”', 0x95: '•', 0x96: '–', 0x97: '—'};
  return high[code] ?? String.fromCharCode(code);
}

/// Glyph names commonly used in /Differences arrays.
String? _glyphName(String n) {
  if (n.length == 1) return n;
  const names = {
    'space': ' ', 'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', //
    'period': '.', 'comma': ',', 'hyphen': '-', 'minus': '-', 'slash': '/', 'colon': ':', 'parenleft': '(', 'parenright': ')', 'ampersand': '&', 'at': '@', 'rupee': '₹', 'uni20B9': '₹',
  };
  return names[n];
}

/// Parses a ToUnicode CMap (codespace, bfchar, bfrange).
(int, Map<int, String>) _parseCMap(Uint8List data) {
  final lx = _Lexer(data);
  final map = <int, String>{};
  var width = 1;
  int code(Uint8List b) => b.fold(0, (v, x) => v << 8 | x);
  String utf16(Uint8List b) => String.fromCharCodes([for (var k = 0; k + 1 < b.length; k += 2) b[k] << 8 | b[k + 1]]);
  final ops = <Object?>[];
  for (var t = lx.next(); t != null; t = lx.next()) {
    if (t is! _Op) {
      ops.add(t);
      continue;
    }
    switch (t.v) {
      case 'endcodespacerange':
        width = (ops.last! as Uint8List).length;
      case 'endbfchar':
        for (var k = 0; k + 1 < ops.length; k += 2) {
          map[code(ops[k]! as Uint8List)] = utf16(ops[k + 1]! as Uint8List);
        }
      case 'endbfrange':
        for (var k = 0; k + 2 < ops.length; k += 3) {
          final lo = code(ops[k]! as Uint8List), hi = code(ops[k + 1]! as Uint8List), dst = ops[k + 2];
          for (var c = lo; c <= hi; c++) {
            if (dst is Uint8List) {
              final last = dst.length - 1;
              map[c] = utf16(Uint8List.fromList([...dst.sublist(0, last), dst[last] + c - lo]));
            } else {
              map[c] = utf16((dst! as List)[c - lo]! as Uint8List);
            }
          }
        }
    }
    ops.clear();
  }
  return (width, map);
}

/// Converts a dart_pdf_reader object to the plain values the interpreter uses.
Future<Object?> _plain(ObjectResolver doc, PDFObject? o) async {
  final r = await doc.resolve<PDFObject>(o);
  return switch (r) {
    PDFNumber() => r.toDouble(),
    PDFName() => _Name(r.value),
    PDFArray() => [for (final e in r) await _plain(doc, e)],
    _ => r,
  };
}

class _GState {
  _GState(this.ctm, this.font, this.size, this.leading, this.charSpace, this.wordSpace);

  _Matrix ctm;
  _Font font;
  double size, leading, charSpace, wordSpace;

  _GState copy() => _GState(ctm, font, size, leading, charSpace, wordSpace);
}

class _Interpreter {
  _Interpreter(this.doc, this.out);

  final ObjectResolver doc;
  final List<_Frag> out;
  final _fonts = <PDFDictionary, _Font>{};
  int _depth = 0;

  Future<_Font> _font(PDFDictionary? resources, String name) async {
    final fonts = await doc.resolve<PDFDictionary>(resources?[const PDFName('Font')]);
    final dict = await doc.resolve<PDFDictionary>(fonts?[PDFName(name)]);
    if (dict == null) return _Font.fallback;
    return _fonts[dict] ??= await _buildFont(dict);
  }

  Future<_Font> _buildFont(PDFDictionary f) async {
    final type0 = f[const PDFName('Subtype')] == const PDFName('Type0');
    final widths = <int, double>{};
    var dw = type0 ? 1000.0 : 500.0;
    var bytesPerCode = type0 ? 2 : 1;
    final toUni = <int, String>{};
    final diffs = <int, String>{};
    final cmap = await doc.resolve<PDFStreamObject>(f[const PDFName('ToUnicode')]);
    if (cmap != null) {
      final (w, m) = _parseCMap(await cmap.read(doc));
      toUni.addAll(m);
      if (!type0) bytesPerCode = w;
    }
    if (type0) {
      final cid = ((await _plain(doc, f[const PDFName('DescendantFonts')]))! as List).first! as PDFDictionary;
      dw = (await _plain(doc, cid[const PDFName('DW')]) as double?) ?? dw;
      final w = (await _plain(doc, cid[const PDFName('W')]) as List?) ?? const [];
      for (var k = 0; k + 1 < w.length;) {
        final first = _n(w[k]).toInt();
        if (w[k + 1] is List) {
          final list = w[k + 1]! as List;
          for (var j = 0; j < list.length; j++) {
            widths[first + j] = _n(list[j]);
          }
          k += 2;
        } else {
          for (var c = first; c <= _n(w[k + 1]); c++) {
            widths[c] = _n(w[k + 2]);
          }
          k += 3;
        }
      }
    } else {
      final firstChar = (await _plain(doc, f[const PDFName('FirstChar')]) as double?)?.toInt() ?? 0;
      final ws = (await _plain(doc, f[const PDFName('Widths')]) as List?) ?? const [];
      for (var j = 0; j < ws.length; j++) {
        widths[firstChar + j] = _n(ws[j]);
      }
      final enc = await doc.resolve<PDFObject>(f[const PDFName('Encoding')]);
      final d = enc is PDFDictionary ? (await _plain(doc, enc[const PDFName('Differences')]) as List?) ?? const <Object?>[] : const <Object?>[];
      var at = 0;
      for (final e in d) {
        if (e is double) {
          at = e.toInt();
        } else {
          final g = _glyphName((e! as _Name).v);
          if (g != null) diffs[at] = g;
          at++;
        }
      }
    }
    return _Font(bytesPerCode: bytesPerCode, widths: widths, defaultWidth: dw, toUnicode: toUni, differences: diffs);
  }

  Future<void> run(Uint8List content, PDFDictionary? resources, _Matrix ctm) async {
    final lx = _Lexer(content);
    var gs = _GState(ctm, _Font.fallback, 12, 0, 0, 0);
    final stack = <_GState>[];
    var tm = _Matrix.identity, tlm = _Matrix.identity;
    final args = <Object?>[];
    void moveLine(double tx, double ty) => tm = tlm = tlm.translate(tx, ty);
    void show(Uint8List bytes) {
      final m = tm.times(gs.ctm);
      final size = gs.size * m.scaleY;
      final text = StringBuffer();
      var adv = 0.0;
      for (final (t, w) in gs.font.decode(bytes)) {
        text.write(t);
        adv += w / 1000 * gs.size + gs.charSpace + (t == ' ' ? gs.wordSpace : 0);
      }
      final end = tm.translate(adv, 0).times(gs.ctm);
      final clean = text.toString().replaceAll(RegExp(r'[\x00-\x1F]'), ' ');
      if (clean.trim().isNotEmpty) out.add(_Frag(m.e, m.f, end.e, size, clean));
      tm = tm.translate(adv, 0);
    }

    for (var t = lx.next(); t != null; t = lx.next()) {
      if (t is! _Op) {
        args.add(t);
        continue;
      }
      switch (t.v) {
        case 'q':
          stack.add(gs.copy());
        case 'Q':
          if (stack.isNotEmpty) gs = stack.removeLast();
        case 'cm':
          gs.ctm = _Matrix.of(args).times(gs.ctm);
        case 'BT':
          tm = tlm = _Matrix.identity;
        case 'Tf':
          gs.font = await _font(resources, (args[0]! as _Name).v);
          gs.size = _n(args[1]);
        case 'TL':
          gs.leading = _n(args[0]);
        case 'Tc':
          gs.charSpace = _n(args[0]);
        case 'Tw':
          gs.wordSpace = _n(args[0]);
        case 'Td':
          moveLine(_n(args[0]), _n(args[1]));
        case 'TD':
          gs.leading = -_n(args[1]);
          moveLine(_n(args[0]), _n(args[1]));
        case 'Tm':
          tm = tlm = _Matrix.of(args);
        case 'T*':
          moveLine(0, -gs.leading);
        case 'Tj':
          show(args[0]! as Uint8List);
        case "'":
          moveLine(0, -gs.leading);
          show(args[0]! as Uint8List);
        case '"':
          gs.wordSpace = _n(args[0]);
          gs.charSpace = _n(args[1]);
          moveLine(0, -gs.leading);
          show(args[2]! as Uint8List);
        case 'TJ':
          for (final e in args[0]! as List) {
            if (e is Uint8List) {
              show(e);
            } else {
              tm = tm.translate(-_n(e) / 1000 * gs.size, 0);
            }
          }
        case 'ID':
          lx.skipInlineImage();
        case 'Do':
          await _form(resources, (args[0]! as _Name).v, gs.ctm);
      }
      args.clear();
    }
  }

  /// Runs a Form XObject (nested content with its own resources).
  Future<void> _form(PDFDictionary? resources, String name, _Matrix ctm) async {
    final xobjects = await doc.resolve<PDFDictionary>(resources?[const PDFName('XObject')]);
    final x = await doc.resolve<PDFStreamObject>(xobjects?[PDFName(name)]);
    if (x == null || x.dictionary[const PDFName('Subtype')] != const PDFName('Form') || _depth > 8) return;
    final m = await _plain(doc, x.dictionary[const PDFName('Matrix')]) as List?;
    final own = await doc.resolve<PDFDictionary>(x.dictionary[const PDFName('Resources')]);
    _depth++;
    await run(await x.read(doc), own ?? resources, (m == null ? _Matrix.identity : _Matrix.of(m)).times(ctm));
    _depth--;
  }
}
