import 'who_standards.dart';
import '../ml/model_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
class Recommendation {
  static List<String> recommendForMaternal(Map<String, dynamic> record) {
    final List<String> recs = [];
    final trimester = (record['current_trimester'] is int) ? record['current_trimester'] as int : 0;
    final hb = (record['hemoglobin'] is num) ? (record['hemoglobin'] as num).toDouble() : null;
    final meals = (record['meal_count'] is int) ? record['meal_count'] as int : null;
    final diversity = (record['dietary_diversity'] is String) ? record['dietary_diversity'] as String : '';

    if (trimester == 1) {
      recs.add('Take folic acid (400 mcg) and iron as advised. Emphasize leafy greens.');
      recs.add('Ensure adequate caloric intake (+100 kcal/day).');
    } else if (trimester == 2) {
      recs.add('Increase iron-rich foods (lentils, red meat, fortified cereals).');
      recs.add('Add calcium-rich foods (milk, yogurt).');
    } else if (trimester == 3) {
      recs.add('Focus on protein and energy-dense meals. Consider small frequent meals.');
      recs.add('Monitor fetal movement and hydration.');
    } else {
      recs.add('Maintain balanced diet and regular antenatal checkups.');
    }

    if (hb != null) {
      if (hb < 7.0) {
        recs.add('Severe anemia: urgent medical referral and iron transfusion may be necessary.');
      } else if (hb < 11.0) {
        recs.add('Low hemoglobin: increase iron intake, take iron supplements, eat vitamin C rich foods to improve absorption.');
      }
    }

    if (meals != null && meals < 3) {
      recs.add('Increase meal frequency to at least 3 main meals and 2 snacks per day.');
    }

    if (diversity.toLowerCase().contains('low') || diversity.isEmpty) {
      recs.add('Improve dietary diversity: include pulses, vegetables, fruits, dairy, and animal-source foods when possible.');
    }

    recs.addAll([
      'Attend regular antenatal visits',
      'Ensure clean water and hygiene',
    ]);

    return recs;
  }

  static List<String> recommendForChild(Map<String, dynamic> record, {double? zScore}) {
    final List<String> recs = [];
    final muac = (record['muac'] is num) ? (record['muac'] as num).toDouble() : null;
    final feeding = (record['feeding_practice'] is String) ? record['feeding_practice'] as String : '';


    final risk = WHOStandards.getRiskLevel(zScore, muac);
    recs.add('Risk level: $risk');
    recs.addAll(WHOStandards.getRiskRecommendations(risk));


    if (feeding.toLowerCase().contains('breast')) {
      recs.add('Encourage exclusive breastfeeding until 6 months, then continue breastfeeding with complementary foods.');
    } else if (feeding.toLowerCase().contains('formula')) {
      recs.add('Ensure correct formula preparation and feeding frequency.');
    } else {
      recs.add('Advise age-appropriate complementary feeding and dietary diversity.');
    }

    recs.add('Schedule follow-up growth measurement in 1-4 weeks depending on risk.');

    return recs;
  }
  static Future<List<String>> recommendForChildWithML(Map<String, dynamic> record, {double? zScore}) async {
    if (!kIsWeb) {
      try {
        final svc = await ModelService.instance();
        if (svc.isReady) {
  
          final weight = (record['weight'] is num) ? (record['weight'] as num).toDouble() : 0.0;
          final height = (record['height'] is num) ? (record['height'] as num).toDouble() : 0.0;
          final muac = (record['muac'] is num) ? (record['muac'] as num).toDouble() : 0.0;
          final hb = (record['hemoglobin'] is num) ? (record['hemoglobin'] as num).toDouble() : 0.0;
          final meals = (record['meal_count'] is int) ? (record['meal_count'] as int).toDouble() : 3.0;

          final pred = await svc.predict([weight, height, muac, hb, meals]);
          if (pred != null) {
            final map = {0: 'Normal', 1: 'Moderate', 2: 'High Risk', 3: 'Severe'};
            final risk = map[pred] ?? 'Normal';
            final recs = <String>[];
            recs.add('Risk level: $risk (predicted by on-device model)');
            recs.addAll(WHOStandards.getRiskRecommendations(risk));
            recs.add('ML confidence: approximate');
            return recs;
          }
        }
      } catch (_) {
    
      }
    }

 
    return Future.value(recommendForChild(record, zScore: zScore));
  }
}
