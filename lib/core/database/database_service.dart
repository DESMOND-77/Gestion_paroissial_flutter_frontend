import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'paroissiale.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE membres (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE groupes (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE evenements (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE finances (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE librairie (
        id INTEGER PRIMARY KEY,
        data TEXT NOT NULL,
        syncedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_metadata (
        entityType TEXT PRIMARY KEY,
        lastSyncAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old tables and recreate with new schema
      await db.execute('DROP TABLE IF EXISTS membres');
      await db.execute('DROP TABLE IF EXISTS groupes');
      await db.execute('DROP TABLE IF EXISTS evenements');
      await db.execute('DROP TABLE IF EXISTS finances');
      await db.execute('DROP TABLE IF EXISTS librairie');
      await db.execute('DROP TABLE IF EXISTS sync_metadata');
      
      // Recreate tables with correct schema
      await _createTables(db, newVersion);
    }
  }

  // Sauvegarde une liste d'éléments dans une table
  Future<void> saveItems<T>(
    String tableName,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Supprimer les anciens éléments
      await txn.delete(tableName);
      // Insérer les nouveaux
      for (final item in items) {
        await txn.insert(
          tableName,
          {
            'id': item['id'],
            'data': jsonEncode(item),
            'syncedAt': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      // Mettre à jour la métadonnée de sync
      await txn.insert(
        'sync_metadata',
        {
          'entityType': tableName,
          'lastSyncAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // Récupère tous les éléments d'une table
  Future<List<Map<String, dynamic>>> getItems(String tableName) async {
    final db = await database;
    final rows = await db.query(tableName);
    return rows
        .map((row) => jsonDecode(row['data'] as String) as Map<String, dynamic>)
        .toList();
  }

  // Récupère un élément par ID
  Future<Map<String, dynamic>?> getItemById(
    String tableName,
    int id,
  ) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
  }

  // Récupère la dernière synchronisation pour une entité
  Future<DateTime?> getLastSyncTime(String entityType) async {
    final db = await database;
    final rows = await db.query(
      'sync_metadata',
      where: 'entityType = ?',
      whereArgs: [entityType],
    );
    if (rows.isEmpty) return null;
    final lastSync = rows.first['lastSyncAt'] as String;
    return DateTime.parse(lastSync);
  }

  // Vérifie si le cache est valide (moins de 5 minutes)
  Future<bool> isCacheValid(String entityType) async {
    final lastSync = await getLastSyncTime(entityType);
    if (lastSync == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    return difference.inMinutes < 5;
  }

  // Vérifie si une table a du contenu
  Future<bool> hasData(String tableName) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    return (count ?? 0) > 0;
  }

  // Efface toutes les données
  Future<void> clearDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('membres');
      await txn.delete('groupes');
      await txn.delete('evenements');
      await txn.delete('finances');
      await txn.delete('librairie');
      await txn.delete('sync_metadata');
    });
  }

  // Efface une table spécifique
  Future<void> clearTable(String tableName) async {
    final db = await database;
    await db.delete(tableName);
  }

  // Ferme la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
