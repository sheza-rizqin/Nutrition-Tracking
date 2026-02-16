import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_helper.dart';
import 'web_database.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();

  AppDatabase._();

  Future<void> init() async {
    if (kIsWeb) {
      await WebDatabase.init();
    } else {
      await DatabaseHelper.instance.database;
    }
  }

  // Maternal
  Future<int> insertMaternalRecord(Map<String, dynamic> record) async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.insertMaternalRecord(record));
    return await DatabaseHelper.instance.insertMaternalRecord(record);
  }

  Future<List<Map<String, dynamic>>> getAllMaternalRecords() async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.getAllMaternalRecords());
    return await DatabaseHelper.instance.getAllMaternalRecords();
  }

  Future<Map<String, dynamic>?> getMaternalRecord(int id) async {
    if (kIsWeb) {
      return await WebDatabase.init().then((db) => db.getMaternalRecord(id));
    }
    return await DatabaseHelper.instance.getMaternalRecord(id);
  }

  Future<int> updateMaternalRecord(int id, Map<String, dynamic> record) async {
    if (kIsWeb) {
      return await WebDatabase.init().then((db) => db.updateMaternalRecord(id, record));
    }
    return await DatabaseHelper.instance.updateMaternalRecord(id, record);
  }

  // Child
  Future<int> insertChildRecord(Map<String, dynamic> record) async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.insertChildRecord(record));
    return await DatabaseHelper.instance.insertChildRecord(record);
  }

  Future<List<Map<String, dynamic>>> getAllChildRecords() async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.getAllChildRecords());
    return await DatabaseHelper.instance.getAllChildRecords();
  }

  Future<Map<String, dynamic>?> getChildRecord(int id) async {
    if (kIsWeb) {
      return await WebDatabase.init().then((db) => db.getChildRecord(id));
    }
    return await DatabaseHelper.instance.getChildRecord(id);
  }

  Future<int> updateChildRecord(int id, Map<String, dynamic> record) async {
    if (kIsWeb) {
      return await WebDatabase.init().then((db) => db.updateChildRecord(id, record));
    }
    return await DatabaseHelper.instance.updateChildRecord(id, record);
  }

  Future<int> insertGrowthMeasurement(Map<String, dynamic> measurement) async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.insertGrowthMeasurement(measurement));
    return await DatabaseHelper.instance.insertGrowthMeasurement(measurement);
  }

  Future<List<Map<String, dynamic>>> getChildGrowthHistory(int childId) async {
    if (kIsWeb) return await WebDatabase.init().then((db) => db.getChildGrowthHistory(childId));
    return await DatabaseHelper.instance.getChildGrowthHistory(childId);
  }
}
