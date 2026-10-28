import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A file the user picked: its name and contents.
class PickedFile {
  const PickedFile(this.name, this.bytes);

  final String name;
  final Uint8List bytes;

  String get extension => p.extension(name).toLowerCase().replaceFirst('.', '');

  String get text => utf8.decode(bytes, allowMalformed: true);
}

/// Platform file access, behind an interface so screens are testable.
abstract class FileGateway {
  /// Lets the user pick a file (any type when [extensions] is null), or null if cancelled.
  Future<PickedFile?> pickFile({List<String>? extensions});

  /// Writes [bytes] to a temp file named [name] and opens the share sheet.
  Future<String> saveAndShare(String name, List<int> bytes, String mimeType);
}

class PlatformFileGateway implements FileGateway {
  PlatformFileGateway({SharePlus? share}) : _share = share ?? SharePlus.instance;

  final SharePlus _share;

  @override
  Future<PickedFile?> pickFile({List<String>? extensions}) async {
    final files = await FilePicker.pickFiles(type: extensions == null ? FileType.any : FileType.custom, allowedExtensions: extensions);
    if (files.isEmpty) return null;
    return PickedFile(files.first.name, await files.first.readAsBytes());
  }

  @override
  Future<String> saveAndShare(String name, List<int> bytes, String mimeType) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    await _share.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        fileNameOverrides: [name],
      ),
    );
    return file.path;
  }
}
