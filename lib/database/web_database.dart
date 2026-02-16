import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WebDatabase {
  static WebDatabase? _instance;
  late SharedPreferences _prefs;

  WebDatabase._();

  static Future<WebDatabase> init() async {
    if (_instance != null) return _instance!;
    final db = WebDatabase._();
    db._prefs = await SharedPreferences.getInstance();
    db._prefs.setString('maternal_records', db._prefs.getString('maternal_records') ?? '[]');
    db._prefs.setString('child_records', db._prefs.getString('child_records') ?? '[]');
    db._prefs.setString('growth_measurements', db._prefs.getString('growth_measurements') ?? '[]');
    _instance = db;
    return db;
  }

  Future<int> _nextId(String key) async {
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    int maxId = 0;
    for (final it in items) {
      if (it is Map && it['id'] is int) {
        maxId = it['id'] > maxId ? it['id'] as int : maxId;
      }
    }
    return maxId + 1;
  }

  Future<int> insertMaternalRecord(Map<String, dynamic> record) async {
    final key = 'maternal_records';
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    final id = await _nextId(key);
    record['id'] = id;
    final now = DateTime.now().toIso8601String();
    record['created_at'] = now;
    record['updated_at'] = now;
    items.add(record);
    await _prefs.setString(key, jsonEncode(items));
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllMaternalRecords() async {
    final items = jsonDecode(_prefs.getString('maternal_records') ?? '[]') as List<dynamic>;
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getMaternalRecord(int id) async {
    final items = await getAllMaternalRecords();
    try {
      return items.firstWhere((e) => (e['id'] == id));
    } catch (_) {
      return null;
    }
  }

  Future<int> updateMaternalRecord(int id, Map<String, dynamic> record) async {
    final key = 'maternal_records';
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    final list = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final idx = list.indexWhere((e) => e['id'] == id);
    if (idx == -1) return 0;
    record['id'] = id;
    record['updated_at'] = DateTime.now().toIso8601String();
    list[idx] = record;
    await _prefs.setString(key, jsonEncode(list));
    return id;
  }

  Future<int> insertChildRecord(Map<String, dynamic> record) async {
    final key = 'child_records';
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    final id = await _nextId(key);
    record['id'] = id;
    final now = DateTime.now().toIso8601String();
    record['created_at'] = now;
    record['updated_at'] = now;
    items.add(record);
    await _prefs.setString(key, jsonEncode(items));
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllChildRecords() async {
    final items = jsonDecode(_prefs.getString('child_records') ?? '[]') as List<dynamic>;
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getChildRecord(int id) async {
    final items = await getAllChildRecords();
    try {
      return items.firstWhere((e) => (e['id'] == id));
    } catch (_) {
      return null;
    }
  }

  Future<int> updateChildRecord(int id, Map<String, dynamic> record) async {
    final key = 'child_records';
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    final list = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final idx = list.indexWhere((e) => e['id'] == id);
    if (idx == -1) return 0;
    record['id'] = id;
    record['updated_at'] = DateTime.now().toIso8601String();
    list[idx] = record;
    await _prefs.setString(key, jsonEncode(list));
    return id;
  }

  Future<int> insertGrowthMeasurement(Map<String, dynamic> measurement) async {
    final key = 'growth_measurements';
    final items = jsonDecode(_prefs.getString(key) ?? '[]') as List<dynamic>;
    final id = await _nextId(key);
    measurement['id'] = id;
    items.add(measurement);
    await _prefs.setString(key, jsonEncode(items));
    return id;
  }

  Future<List<Map<String, dynamic>>> getChildGrowthHistory(int childId) async {
    final items = jsonDecode(_prefs.getString('growth_measurements') ?? '[]') as List<dynamic>;
    final result = items
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((m) => (m['child_id'] == childId))
        .toList();
    result.sort((a, b) {
      final da = a['measurement_date'] ?? '';
      final db = b['measurement_date'] ?? '';
      return db.toString().compareTo(da.toString());
    });
    return result;
  }
}
