import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ReceiptSource { camera, gallery, pdf }

bool isPdf(String path) => path.toLowerCase().endsWith('.pdf');

/// Receipt files (photos or PDFs) kept in `<documents>/receipts/`.
abstract class ReceiptStore {
  /// Lets the user pick a receipt and copies it into the receipts folder.
  /// Returns the stored path, or null if cancelled.
  Future<String?> pick(ReceiptSource source);

  /// Opens the file with another app (via the share sheet).
  Future<void> open(String path);

  Future<void> delete(String path);
}

class PlatformReceiptStore implements ReceiptStore {
  PlatformReceiptStore({ImagePicker? images, SharePlus? share, Future<Directory> Function()? documents, DateTime Function()? clock})
    : _images = images ?? ImagePicker(),
      _share = share ?? SharePlus.instance,
      _documents = documents ?? getApplicationDocumentsDirectory,
      _clock = clock ?? DateTime.now;

  final ImagePicker _images;
  final SharePlus _share;
  final Future<Directory> Function() _documents;
  final DateTime Function() _clock;

  @override
  Future<String?> pick(ReceiptSource source) async {
    final (String name, List<int> bytes)? picked;
    if (source == ReceiptSource.pdf) {
      final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
      picked = files.isEmpty ? null : (files.first.name, await files.first.readAsBytes());
    } else {
      final x = await _images.pickImage(source: source == ReceiptSource.camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 2000, imageQuality: 80);
      picked = x == null ? null : (x.name.isEmpty ? 'receipt.jpg' : x.name, await x.readAsBytes());
    }
    if (picked == null) return null;
    final dir = Directory(p.join((await _documents()).path, 'receipts'));
    await dir.create(recursive: true);
    final safe = p.basename(picked.$1).replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File(p.join(dir.path, '${_clock().millisecondsSinceEpoch}_$safe'));
    await file.writeAsBytes(picked.$2, flush: true);
    return file.path;
  }

  @override
  Future<void> open(String path) async {
    await _share.share(ShareParams(files: [XFile(path, mimeType: isPdf(path) ? 'application/pdf' : 'image/jpeg')]));
  }

  @override
  Future<void> delete(String path) async {
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }
}
