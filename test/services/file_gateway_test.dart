import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:expense_manager/services/file_gateway.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

base class FakeFile extends PlatformFile {
  FakeFile(this.bytes);

  final Uint8List bytes;

  @override
  String get name => 'x.csv';

  @override
  Uri get uri => Uri.file('/tmp/x.csv');

  @override
  XFile get xFile => XFile.fromData(bytes);

  @override
  int? lengthSync() => bytes.length;

  @override
  Future<int?> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

class FakePicker extends FilePickerPlatform with MockPlatformInterfaceMixin {
  List<PlatformFile> result = [];
  List<String>? extensions;

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    extensions = allowedExtensions;
    return result;
  }
}

class FakeShare extends SharePlatform with MockPlatformInterfaceMixin {
  ShareParams? last;

  @override
  Future<ShareResult> share(ShareParams params) async {
    last = params;
    return const ShareResult('ok', ShareResultStatus.success);
  }
}

class FakePaths extends PathProviderPlatform with MockPlatformInterfaceMixin {
  FakePaths(this.dir);

  final String dir;

  @override
  Future<String?> getTemporaryPath() async => dir;
}

void main() {
  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('gw');
    PathProviderPlatform.instance = FakePaths(tmp.path);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('pickCsvText returns decoded text or null when cancelled', () async {
    final picker = FakePicker();
    FilePickerPlatform.instance = picker;
    final gw = PlatformFileGateway(share: SharePlus.custom(FakeShare()));
    expect(await gw.pickCsvText(), isNull);
    picker.result = [FakeFile(Uint8List.fromList(utf8.encode('a,b\n₹,2')))];
    expect(await gw.pickCsvText(), 'a,b\n₹,2');
    expect(picker.extensions, ['csv']);
  });

  test('shareText opens the share sheet with text only', () async {
    final share = FakeShare();
    await PlatformFileGateway(share: SharePlus.custom(share)).shareText('Hi Rahul', subject: 'Reminder');
    expect(share.last!.text, 'Hi Rahul');
    expect(share.last!.subject, 'Reminder');
    expect(share.last!.files, isNull);
  });

  test('saveAndShare writes a temp file and opens the share sheet', () async {
    final share = FakeShare();
    final gw = PlatformFileGateway(share: SharePlus.custom(share));
    final path = await gw.saveAndShare('r.csv', utf8.encode('hello'), 'text/csv');
    expect(File(path).readAsStringSync(), 'hello');
    expect(share.last!.files!.single.path, path);
    expect(share.last!.fileNameOverrides, ['r.csv']);
  });

  test('default constructor uses the shared SharePlus instance', () {
    expect(PlatformFileGateway(), isA<FileGateway>());
  });
}
