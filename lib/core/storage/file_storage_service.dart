import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stocke sur disque les fichiers volumineux destinés à l'accès hors ligne
/// (photos de profil, et à terme vidéos, PDF, JSON volumineux). Ces fichiers
/// ne doivent pas transiter par SQLite (`DatabaseService`) — path_provider
/// donne un répertoire applicatif stable pour les écrire directement.
///
/// Enregistré comme lazy singleton dans `injection.dart` ; `init()` doit être
/// appelé une fois pendant `setupDependencies()`, avant tout accès.
class FileStorageService {
  Directory? _rootDir;

  Future<void> init() async {
    // `getApplicationSupportDirectory()` — pas `getApplicationDocumentsDirectory()` —
    // car cette dernière pointe vers le dossier "Documents" réel et visible de
    // l'utilisateur sur desktop (Linux/macOS) ; le cache média est un détail
    // d'implémentation interne à l'app, pas un document de l'utilisateur.
    final supportDir = await getApplicationSupportDirectory();
    final root = Directory(p.join(supportDir.path, 'media'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    _rootDir = root;
  }

  Directory _categoryDir(String category) {
    final root = _rootDir;
    if (root == null) {
      throw StateError(
        'FileStorageService.init() doit être appelé avant utilisation.',
      );
    }
    return Directory(p.join(root.path, category));
  }

  String _filePath(String category, String fileName) =>
      p.join(_categoryDir(category).path, fileName);

  /// Renvoie le fichier mis en cache localement s'il existe, sinon `null`.
  File? getCachedFile(String category, String fileName) {
    final file = File(_filePath(category, fileName));
    return file.existsSync() ? file : null;
  }

  Future<File> saveBytes(
    String category,
    String fileName,
    List<int> bytes,
  ) async {
    final dir = _categoryDir(category);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(_filePath(category, fileName)).writeAsBytes(
      bytes,
      flush: true,
    );
  }

  /// Copie un fichier local (ex: sélection `image_picker`, dans un répertoire
  /// temporaire) vers le stockage permanent de l'app.
  Future<File> saveLocalFile(
    String category,
    String fileName,
    File sourceFile,
  ) async {
    return saveBytes(category, fileName, await sourceFile.readAsBytes());
  }

  /// Télécharge le fichier distant et le met en cache pour un accès hors
  /// ligne ultérieur. Renvoie `null` en cas d'échec (pas de réseau, URL
  /// invalide, ...) — l'appelant doit alors se contenter du cache existant.
  Future<File?> downloadAndCache(
    String url,
    String category,
    String fileName,
  ) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes == null) return null;
      return saveBytes(category, fileName, bytes);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteFile(String category, String fileName) async {
    final file = File(_filePath(category, fileName));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearCategory(String category) async {
    final dir = _categoryDir(category);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
