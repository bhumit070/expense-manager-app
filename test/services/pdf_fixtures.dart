import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Assembles a PDF from object bodies (object n = bodies[n - 1]) with a valid xref.
Uint8List rawPdf(List<String> bodies, {String trailerExtra = ''}) {
  final out = BytesBuilder();
  void w(String s) => out.add(latin1.encode(s));
  w('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < bodies.length; i++) {
    offsets.add(out.length);
    w('${i + 1} 0 obj\n${bodies[i]}\nendobj\n');
  }
  final xref = out.length;
  w('xref\n0 ${bodies.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    w('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  w('trailer\n<< /Size ${bodies.length + 1} /Root 1 0 R $trailerExtra>>\nstartxref\n$xref\n%%EOF\n');
  return out.takeBytes();
}

/// An uncompressed stream object body.
String stream(String dict, String content) => '<< $dict /Length ${latin1.encode(content).length} >>\nstream\n$content\nendstream';

/// One page per entry of [pages]; each page holds [lines] of text drawn top to bottom
/// with optional column cells separated by `|` (placed at fixed x positions).
Future<Uint8List> statementPdf(List<List<String>> pages, {bool ttf = false}) async {
  final font = ttf ? pw.Font.ttf(File('assets/fonts/PlusJakartaSans-400.ttf').readAsBytesSync().buffer.asByteData()) : null;
  final doc = pw.Document();
  for (final lines in pages) {
    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(1400, 900, marginAll: 30),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final l in lines)
              pw.Row(
                children: [
                  for (final cell in l.split('|'))
                    pw.SizedBox(
                      width: 180,
                      child: pw.Text(cell, style: pw.TextStyle(font: font, fontSize: 9)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  return doc.save();
}
