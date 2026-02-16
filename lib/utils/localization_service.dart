import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple language/localization service.
/// Stores user's language preference and provides easy access to app strings.
class LocalizationService extends ChangeNotifier {
  static LocalizationService? _instance;
  
  Locale _locale = const Locale('en');
  late SharedPreferences _prefs;
  
  LocalizationService._();
  
  static LocalizationService get instance {
    _instance ??= LocalizationService._();
    return _instance!;
  }
  
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'NutriTrack',
      'maternalRecords': 'Maternal Records',
      'childRecords': 'Child Records',
      'addMaternalRecord': 'Add Maternal Record',
      'addChildRecord': 'Add Child Record',
      'editRecord': 'Edit Record',
      'deleteRecord': 'Delete Record',
      'name': 'Name',
      'age': 'Age',
      'weight': 'Weight',
      'height': 'Height',
      'gender': 'Gender',
      'dateOfBirth': 'Date of Birth',
      'hemoglobin': 'Hemoglobin',
      'muac': 'MUAC',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'loading': 'Loading...',
      'noRecordsFound': 'No records found',
      'recordSaved': 'Record saved successfully',
      'recordDeleted': 'Record deleted successfully',
      'confirmDelete': 'Are you sure?',
      'nutrition': 'Nutrition',
      'guidance': 'Guidance',
      'recommendations': 'Recommendations',
      'riskLevel': 'Risk Level',
      'normal': 'Normal',
      'moderate': 'Moderate',
      'highRisk': 'High Risk',
      'severe': 'Severe',
      'offline': 'Offline',
      'synced': 'Synced',
      'syncing': 'Syncing...',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'hindi': 'हिंदी',
    },
    'hi': {
      'appTitle': 'पोषण ट्रैक',
      'maternalRecords': 'माता के रिकॉर्ड',
      'childRecords': 'बच्चे के रिकॉर्ड',
      'addMaternalRecord': 'माता का रिकॉर्ड जोड़ें',
      'addChildRecord': 'बच्चे का रिकॉर्ड जोड़ें',
      'editRecord': 'रिकॉर्ड संपादित करें',
      'deleteRecord': 'रिकॉर्ड हटाएं',
      'name': 'नाम',
      'age': 'उम्र',
      'weight': 'वजन',
      'height': 'लंबाई',
      'gender': 'लिंग',
      'dateOfBirth': 'जन्म की तारीख',
      'hemoglobin': 'हीमोग्लोबिन',
      'muac': 'म्यूएसी',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'loading': 'लोड हो रहा है...',
      'noRecordsFound': 'कोई रिकॉर्ड नहीं मिला',
      'recordSaved': 'रिकॉर्ड सफलतापूर्वक सहेजा गया',
      'recordDeleted': 'रिकॉर्ड सफलतापूर्वक हटा दिया गया',
      'confirmDelete': 'क्या आप सुनिश्चित हैं?',
      'nutrition': 'पोषण',
      'guidance': 'मार्गदर्शन',
      'recommendations': 'सिफारिशें',
      'riskLevel': 'जोखिम स्तर',
      'normal': 'सामान्य',
      'moderate': 'मध्यम',
      'highRisk': 'उच्च जोखिम',
      'severe': 'गंभीर',
      'offline': 'ऑफलाइन',
      'synced': 'सिंक किया हुआ',
      'syncing': 'सिंक हो रहा है...',
      'selectLanguage': 'भाषा चुनें',
      'english': 'English',
      'hindi': 'हिंदी',
    },
  };
  
  /// Initialize the service and load saved language preference
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs.getString('language_code') ?? 'en';
    _locale = Locale(savedLang);
  }
  
  /// Set the app language
  Future<void> setLanguage(String langCode) async {
    _locale = Locale(langCode);
    await _prefs.setString('language_code', langCode);
    notifyListeners();
  }
  
  /// Get translated string by key
  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }
  
  /// Get translated string with parameter substitution
  String translateWithParam(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((paramKey, paramValue) {
      text = text.replaceAll('{$paramKey}', paramValue);
    });
    return text;
  }
  
  /// Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];
}
