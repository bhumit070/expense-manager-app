import 'package:expense_manager/core/licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Bundle extends CachingAssetBundle {
  final asked = <String>[];

  @override
  Future<ByteData> load(String key) async {
    asked.add(key);
    return ByteData.sublistView(Uint8List.fromList('SIL Open Font License'.codeUnits));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled font license is registered', () async {
    LicenseRegistry.reset();
    final bundle = _Bundle();
    registerAssetLicenses(bundle: bundle);
    final entries = await LicenseRegistry.licenses.toList();
    expect(entries.single.packages, ['Plus Jakarta Sans (font)']);
    expect(entries.single.paragraphs.first.text, 'SIL Open Font License');
    expect(bundle.asked, ['assets/fonts/OFL.txt']);
  });

  test('defaults to the root bundle', () async {
    LicenseRegistry.reset();
    registerAssetLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    expect(entries.single.paragraphs.map((p) => p.text).join('\n'), contains('Open Font License'));
  });
}
