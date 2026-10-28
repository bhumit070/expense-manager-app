import 'dart:io';
import 'dart:typed_data';

import 'package:expense_manager/services/receipts.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus/share_plus.dart';

import 'file_gateway_test.dart' show FakeFile, FakePicker, FakeShare;

class FakeImages extends ImagePickerPlatform with MockPlatformInterfaceMixin {
  XFile? next;
  ImageSource? source;

  @override
  Future<XFile?> getImageFromSource({required ImageSource source, ImagePickerOptions options = const ImagePickerOptions()}) async {
    this.source = source;
    return next;
  }
}

void main() {
  late Directory docs;
  late FakeImages images;
  late FakePicker files;
  late FakeShare share;
  late PlatformReceiptStore store;

  setUp(() {
    docs = Directory.systemTemp.createTempSync('rc');
    images = FakeImages();
    files = FakePicker();
    ImagePickerPlatform.instance = images;
    FilePickerPlatform.instance = files;
    share = FakeShare();
    store = PlatformReceiptStore(share: SharePlus.custom(share), documents: () async => docs, clock: () => DateTime.fromMillisecondsSinceEpoch(42));
  });
  tearDown(() => docs.deleteSync(recursive: true));

  test('photos from camera or gallery are copied into receipts/', () async {
    expect(await store.pick(ReceiptSource.camera), isNull);
    expect(images.source, ImageSource.camera);
    images.next = XFile.fromData(Uint8List.fromList([1, 2, 3]));
    expect(await store.pick(ReceiptSource.camera), endsWith('/42_receipt.jpg'));
    images.next = XFile.fromData(Uint8List.fromList([1, 2, 3]), path: '/cam/IMG 01.jpg');
    final path = (await store.pick(ReceiptSource.gallery))!;
    expect(images.source, ImageSource.gallery);
    expect(path, '${docs.path}/receipts/42_IMG_01.jpg');
    expect(File(path).readAsBytesSync(), [1, 2, 3]);
    await store.open(path);
    expect(share.last!.files!.single.mimeType, 'image/jpeg');
    await store.delete(path);
    expect(File(path).existsSync(), isFalse);
    await store.delete(path); // already gone
  });

  test('PDFs come from the file picker', () async {
    expect(await store.pick(ReceiptSource.pdf), isNull);
    files.result = [
      FakeFile(Uint8List.fromList([9])),
    ];
    final path = (await store.pick(ReceiptSource.pdf))!;
    expect(files.extensions, ['pdf']);
    expect(File(path).readAsBytesSync(), [9]);
    await store.open('/x/bill.PDF');
    expect(share.last!.files!.single.mimeType, 'application/pdf');
    expect(isPdf('/x/bill.PDF'), isTrue);
    expect(isPdf('/x/bill.jpg'), isFalse);
  });

  test('default constructor', () {
    expect(PlatformReceiptStore(), isA<ReceiptStore>());
  });
}
