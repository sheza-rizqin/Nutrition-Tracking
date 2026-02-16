import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutritrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Maternal data table
    await db.execute('''
      CREATE TABLE maternal_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        lmp TEXT,
        edd TEXT,
        current_trimester INTEGER,
        hemoglobin REAL,
        folic_acid_intake TEXT,
        meal_count INTEGER,
        dietary_diversity TEXT,
        symptoms TEXT,
        food_security TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Child growth records table
    await db.execute('''
      CREATE TABLE child_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        weight REAL NOT NULL,
        height REAL,
        muac REAL,
        feeding_practice TEXT,
        illness_episodes TEXT,
        milestones TEXT,
        immunizations TEXT,
        risk_level TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Child growth tracking 
    await db.execute('''
      CREATE TABLE growth_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        measurement_date TEXT NOT NULL,
        age_months INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL,
        muac REAL,
        z_score_wfl REAL,
        z_score_wfa REAL,
        z_score_hfa REAL,
        FOREIGN KEY (child_id) REFERENCES child_records (id)
      )
    ''');
  }

  // Maternal Records CRUD
  Future<int> insertMaternalRecord(Map<String, dynamic> record) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    record['created_at'] = now;
    record['updated_at'] = now;
    return await db.insert('maternal_records', record);
  }

  Future<List<Map<String, dynamic>>> getAllMaternalRecords() async {
    final db = await database;
    return await db.query('maternal_records', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getMaternalRecord(int id) async {
    final db = await database;
    final results = await db.query(
      'maternal_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateMaternalRecord(int id, Map<String, dynamic> record) async {
    final db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'maternal_records',
      record,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Child Records CRUD
  Future<int> insertChildRecord(Map<String, dynamic> record) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    record['created_at'] = now;
    record['updated_at'] = now;
    return await db.insert('child_records', record);
  }

  Future<List<Map<String, dynamic>>> getAllChildRecords() async {
    final db = await database;
    return await db.query('child_records', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getChildRecord(int id) async {
    final db = await database;
    final results = await db.query(
      'child_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateChildRecord(int id, Map<String, dynamic> record) async {
    final db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'child_records',
      record,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Growth Measurements CRUD
  Future<int> insertGrowthMeasurement(Map<String, dynamic> measurement) async {
    final db = await database;
    return await db.insert('growth_measurements', measurement);
  }

  Future<List<Map<String, dynamic>>> getChildGrowthHistory(int childId) async {
    final db = await database;
    return await db.query(
      'growth_measurements',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'measurement_date DESC',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
