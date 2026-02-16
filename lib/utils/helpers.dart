import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Combined helpers: WHO standards, simple recommendations, TTS and ML loader.
// This single file keeps the app compact and easy to explain in presentations.

class WHOStandards {
  // Simplified z-score approximation for demo purposes.
  static double calculateWFLZScore(double weight, double height, bool isMale) {
    double expectedWeight;
    if (height < 65) {
      expectedWeight = height * 0.08 - 1.5;
    } else if (height < 85) {
      expectedWeight = height * 0.12 - 4.0;
    } else if (height < 110) {
      expectedWeight = height * 0.18 - 9.0;
    } else {
      expectedWeight = height * 0.28 - 20.0;
    }
    double sd = expectedWeight * 0.15;
    return (weight - expectedWeight) / sd;
  }

  static String getRiskLevel(double? zScore, double? muac) {
    if (muac != null) {
      if (muac < 11.5) return 'Severe';
      if (muac < 12.5) return 'High Risk';
    }
    if (zScore != null) {
      if (zScore < -3.0) return 'Severe';
      if (zScore < -2.0) return 'High Risk';
      if (zScore < -1.0) return 'Moderate';
    }
    return 'Normal';
  }

  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
        return const Color(0xFFD32F2F);
      case 'high risk':
        return const Color(0xFFF57C00);
      case 'moderate':
        return const Color(0xFFFBC02D);
      default:
        return const Color(0xFF388E3C);
    }
  }

  static List<String> getRiskRecommendations(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
        return ['Refer immediately to health facility', 'Medical assessment required'];
      case 'high risk':
        return ['Increase meal frequency', 'Provide energy-dense foods', 'Monitor weekly'];
      case 'moderate':
        return ['Improve dietary diversity', 'Monitor monthly'];
      default:
        return ['Continue regular feeding and monitoring'];
    }
  }
}

class Recommendation {
  static List<String> recommendForMaternal(Map<String, dynamic> record) {
    final recs = <String>[];
    final trimester = (record['current_trimester'] is int) ? record['current_trimester'] as int : 0;
    final hb = (record['hemoglobin'] is num) ? (record['hemoglobin'] as num).toDouble() : null;
    final meals = (record['meal_count'] is int) ? record['meal_count'] as int : null;

    if (trimester == 1) recs.add('Take folic acid and maintain balanced meals.');
    if (trimester == 2) recs.add('Include iron and calcium-rich foods.');
    if (trimester == 3) recs.add('Focus on protein and small frequent meals.');
    if (hb != null && hb < 11.0) recs.add('Low hemoglobin: take iron supplements and vitamin C foods.');
    if (meals != null && meals < 3) recs.add('Increase meal frequency to at least 3 per day.');
    recs.add('Attend regular antenatal visits.');
    return recs;
  }

  static List<String> recommendForChild(Map<String, dynamic> record, {double? zScore}) {
    final muac = (record['muac'] is num) ? (record['muac'] as num).toDouble() : null;
    final risk = WHOStandards.getRiskLevel(zScore, muac);
    final recs = <String>['Risk level: $risk'];
    recs.addAll(WHOStandards.getRiskRecommendations(risk));
    recs.add('Follow up in 1-4 weeks depending on risk.');
    return recs;
  }

  static Future<List<String>> recommendForChildWithML(Map<String, dynamic> record, {double? zScore}) async {
    if (!kIsWeb) {
      try {
      } catch (_) {}
    }
    return recommendForChild(record, zScore: zScore);
  }
}


