import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'app_database.dart';

class SyncService extends ChangeNotifier {
  static SyncService? _instance;
  
  static const String _serverUrl = 'http://localhost:3000';
  
  bool _isOnline = false;
  bool _isSyncing = false;
  String _lastSyncTime = 'Never';
  
  SyncService._();
  
  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  String get lastSyncTime => _lastSyncTime;
  
  void init() {
    Connectivity().onConnectivityChanged.listen((result) {
      final wasOnline = _isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        syncAll();
      }
      notifyListeners();
    });
    
    _checkConnectivity();
  }
  
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }
  
  /// Sync all local data to server
  Future<void> syncAll() async {
    if (!_isOnline || _isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      // Sync maternal records
      await _syncMaternalRecords();
      // Sync child records
      await _syncChildRecords();
      // Sync growth measurements
      await _syncGrowthMeasurements();
      
      _lastSyncTime = DateTime.now().toString().split('.')[0];
      notifyListeners();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  Future<void> _syncMaternalRecords() async {
    try {
      final records = await AppDatabase.instance.getAllMaternalRecords();
      for (final rec in records) {
        final id = rec['id'] as int?;
        if (id == null) continue;

        DateTime? updatedAt;
        DateTime? serverSyncedAt;
        if (rec['updated_at'] is String) updatedAt = DateTime.tryParse(rec['updated_at']);
        if (rec['server_synced_at'] is String) serverSyncedAt = DateTime.tryParse(rec['server_synced_at']);

        final needsPush = serverSyncedAt == null || (updatedAt != null && serverSyncedAt.isBefore(updatedAt));

        if (needsPush) {
          final ok = await sendMaternalRecord(rec);
          if (ok) {
            rec['server_synced_at'] = DateTime.now().toIso8601String();
            await AppDatabase.instance.updateMaternalRecord(id, rec);
          }
        }
      }
    } catch (e) {
      print('Error syncing maternal records: $e');
    }
  }
  
  Future<void> _syncChildRecords() async {
    try {
      final records = await AppDatabase.instance.getAllChildRecords();
      for (final rec in records) {
        final id = rec['id'] as int?;
        if (id == null) continue;

        DateTime? updatedAt;
        DateTime? serverSyncedAt;
        if (rec['updated_at'] is String) updatedAt = DateTime.tryParse(rec['updated_at']);
        if (rec['server_synced_at'] is String) serverSyncedAt = DateTime.tryParse(rec['server_synced_at']);

        final needsPush = serverSyncedAt == null || (updatedAt != null && serverSyncedAt.isBefore(updatedAt));

        if (needsPush) {
          final ok = await sendChildRecord(rec);
          if (ok) {
            rec['server_synced_at'] = DateTime.now().toIso8601String();
            await AppDatabase.instance.updateChildRecord(id, rec);
          }
        }
      }
    } catch (e) {
      print('Error syncing child records: $e');
    }
  }
  
  Future<void> _syncGrowthMeasurements() async {
    return;
  }

  Future<bool> sendMaternalRecord(Map<String, dynamic> record) async {
    if (!_isOnline) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/maternal'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Failed to send maternal record: $e');
      return false;
    }
  }

  Future<bool> sendChildRecord(Map<String, dynamic> record) async {
    if (!_isOnline) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/child'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(record),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Failed to send child record: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchAllRecords() async {
    if (!_isOnline || kIsWeb) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/api/records'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Failed to fetch records: $e');
    }
    return null;
  }

  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
