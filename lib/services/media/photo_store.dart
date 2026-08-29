import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists picked image files into the app's documents directory.
///
/// `image_picker` returns a path in the OS temp/cache dir, which can be purged
/// by the system at any time — storing that directly in the DB would leave the
/// visit pointing at a dead file after a restart. Copying into
/// `<documents>/photos/` keeps the attachment stable across app restarts
/// on the same device. (Across *simulated* devices the local path is still a
/// mock-only fiction — called out in the README trade-offs.)
class PhotoStore {
  Future<String?> save(String sourcePath) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docsDir.path}/photos');
      await photosDir.create(recursive: true);

      final extension = sourcePath.split('.').lastOrNull ?? 'jpg';
      final destPath =
          '${photosDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension';
      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }
}
