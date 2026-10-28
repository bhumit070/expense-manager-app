import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Platform file access, behind an interface so screens are testable.
abstract class FileGateway {
  /// Lets the user pick a CSV file and returns its text, or null if cancelled.
  Future<String?> pickCsvText();

  /// Writes [bytes] to a temp file named [name] and opens the share sheet.
  Future<String> saveAndShare(String name, List<int> bytes, String mimeType);

  /// Opens the share sheet with plain [text] (e.g. a reminder message).
  Future<void> shareText(String text, {String? subject});
}

class PlatformFileGateway implements FileGateway {
  PlatformFileGateway({SharePlus? share}) : _share = share ?? SharePlus.instance;

  final SharePlus _share;

  @override
  Future<String?> pickCsvText() async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['csv']);
    if (files.isEmpty) return null;
    return utf8.decode(await files.first.readAsBytes(), allowMalformed: true);
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

  @override
  Future<void> shareText(String text, {String? subject}) async {
    await _share.share(ShareParams(text: text, subject: subject));
  }
}
