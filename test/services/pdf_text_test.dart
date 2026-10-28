import 'dart:convert';
import 'dart:typed_data';

import 'package:expense_manager/services/pdf_text.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pdf_fixtures.dart';

const _cmap1 = '''%!PS-Adobe-3.0 Resource-CMap
/CIDInit /ProcSet findresource begin
12 dict begin
begincmap
1 begincodespacerange <00> <FF> endcodespacerange
2 beginbfchar <41> <0048> <42> <0069> endbfchar
2 beginbfrange <43> <45> <0061> <46> <47> [<0078> <0079>] endbfrange
endcmap''';

const _cmap2 = '''begincmap
1 begincodespacerange <0000> <FFFF> endcodespacerange
3 beginbfchar <0001> <0041> <0002> <0042> <0003> <20B9> endbfchar
endcmap''';

const _contentA = r'''% a comment
q 1 0 0 1 0 0 cm
BT /F1 12 Tf 14 TL 0 Tc 0 Tw
72 700 Td (ABCDEF) Tj
T* (\(paren\) \\ \n\101\0121 \
joined) Tj
(Quote line) '
1 0 (Double quote) "
0 -20 TD (After TD) Tj T* (After Tstar) Tj
0 -20 Td [(Wide) -2000 (Gap) -300 (Mid) 50 (Tight)] TJ
0 -20 Td (x   y \(a \(b\) c\)) Tj
ET
Q Q
BT /F2 10 Tf 1 0 0 1 72 500 Tm (ABCDEFG) Tj ET
BT /F3 10 Tf 72 480 Td <000100020003> Tj ( ) Tj <00010> Tj ET
BT /F4 10 Tf 72 460 Td <00410042> Tj ET
BT /F5 10 Tf 72 440 Td (\200 Euro \225) Tj ET
/P <</MCID 0 /Alt (x)>> BDC EMC
BI /W 2 /H 1 /BPC 8 /CS /G ID xx EI
/X1 Do /X2 Do /Im Do
BT /F1 10 Tf 300 700 Td ( ) Tj ET
{ } ) >''';

/// A handcrafted 3-page PDF exercising every operator and font path.
Uint8List _fixture({String trailerExtra = ''}) => rawPdf([
  '<< /Type /Catalog /Pages 2 0 R >>',
  '<< /Type /Pages /Kids [3 0 R 9 0 R 20 0 R] /Count 3 >>',
  '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 600 800] /Resources << /Font << /F1 4 0 R /F2 5 0 R /F3 6 0 R /F4 15 0 R /F5 17 0 R >> /XObject << /X1 7 0 R /X2 18 0 R /Im 8 0 R >> >> /Contents [10 0 R 11 0 R] >>',
  '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /FirstChar 32 /Widths [250 300 300] /Encoding << /Differences [65 /rupee /space /zero /unknownglyph 70 /B] >> >>',
  '<< /Type /Font /Subtype /TrueType /BaseFont /Arial /ToUnicode 12 0 R >>',
  '<< /Type /Font /Subtype /Type0 /BaseFont /X /Encoding /Identity-H /DescendantFonts [13 0 R] /ToUnicode 14 0 R >>',
  stream(
    '/Type /XObject /Subtype /Form /BBox [0 0 100 100] /Matrix [1 0 0 1 0 -60] /Resources << /Font << /F1 4 0 R >> /XObject << /X1 7 0 R >> >>',
    'BT /F1 10 Tf 50 380 Td (Form text) Tj ET /X1 Do',
  ),
  stream('/Type /XObject /Subtype /Image /Width 1 /Height 1 /ColorSpace /DeviceGray /BitsPerComponent 8', 'x'),
  '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 600 800] /Contents 19 0 R >>',
  stream('', _contentA),
  stream('', 'BT /Missing 9 Tf 72 300 Td (fallback) Tj ET /Nope Do true false null'),
  stream('', _cmap1),
  '<< /Type /Font /Subtype /CIDFontType2 /BaseFont /X /DW 500 /W [1 [600 700] 3 5 800] >>',
  stream('', _cmap2),
  '<< /Type /Font /Subtype /Type0 /BaseFont /Y /Encoding /Identity-H /DescendantFonts [16 0 R] >>',
  '<< /Type /Font /Subtype /CIDFontType2 /BaseFont /Y >>',
  '<< /Type /Font /Subtype /Type1 /BaseFont /Times-Roman /Encoding /WinAnsiEncoding >>',
  stream('/Type /XObject /Subtype /Form /BBox [0 0 100 100]', 'BT /F2 8 Tf 72 100 Td (C) Tj ET'),
  stream('', 'BT /F1 9 Tf 10 10 Td (P2) Tj ET /X1 Do'),
  '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 600 800] >>',
], trailerExtra: trailerExtra);

void main() {
  test('handcrafted PDF: operators, encodings, CMaps, forms and inline images', () async {
    final lines = await extractPdfLines(_fixture());
    expect(lines.first, '₹ 0DEB');
    expect(
      lines,
      containsAll(<String>['(paren) \\  ₹ 1 joined', 'Quote line', 'Double quote', '₹fter TD', '₹fter Tstar', 'Wide  Gap MidTight', 'x  y (a (b) c)', 'Hiabcxy', '€ Euro •', 'fallback', 'P2', 'a']),
    );
    // Type0 fonts: ToUnicode for codes 1-3 (odd hex digit pads to <0001>); no CMap → raw code points.
    expect(lines, containsAll(<String>['AB₹A', 'AB']));
    // The self-nesting form stops after 9 levels.
    expect(lines.where((l) => l == 'Borm text'), hasLength(9));
  });

  test('generated statements (built-in and embedded TrueType fonts) keep table rows on one line', () async {
    for (final ttf in [false, true]) {
      final bytes = await statementPdf([
        ['HDFC BANK Ltd', 'Date|Narration|Withdrawal Amt.|Closing Balance', '01/10/26|UPI-SWIGGY|486.00|12,345.67'],
        ['Page 2', '02/10/26|SALARY OCT|1,10,000.00|1,22,345.67'],
      ], ttf: ttf);
      final lines = await extractPdfLines(bytes);
      expect(lines, ['HDFC BANK Ltd', 'Date  Narration  Withdrawal Amt.  Closing Balance', '01/10/26  UPI-SWIGGY  486.00  12,345.67', 'Page 2', '02/10/26  SALARY OCT  1,10,000.00  1,22,345.67']);
    }
  });

  test('locked and unreadable PDFs raise clear errors', () async {
    await expectLater(extractPdfLines(_fixture(trailerExtra: '/Encrypt << /Filter /Standard >> ')), throwsA(isA<PdfLockedException>()));
    await expectLater(extractPdfLines(Uint8List.fromList(utf8.encode('not a pdf'))), throwsA(isA<PdfUnreadableException>()));
    expect('${const PdfLockedException()}', contains('password-protected'));
    expect('${const PdfUnreadableException('boom')}', 'Could not read this PDF (boom)');
  });
}
