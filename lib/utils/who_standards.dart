import 'package:flutter/material.dart';
class WHOStandards {
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
    
    double zScore = (weight - expectedWeight) / sd;
    
    return zScore;
  }
  
  static String getRiskLevel(double? zScore, double? muac) {
    if (muac != null) {
      if (muac < 11.5) {
        return 'Severe';
      } else if (muac < 12.5) {
        return 'High Risk';
      }
    }
    
    if (zScore != null) {
      if (zScore < -3.0) {
        return 'Severe';
      } else if (zScore < -2.0) {
        return 'High Risk';
      } else if (zScore < -1.0) {
        return 'Moderate';
      }
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
      case 'normal':
      default:
        return const Color(0xFF388E3C); 
    }
  }
  
  static String getRiskDescription(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
        return 'Severe Acute Malnutrition (SAM) - Immediate medical attention required';
      case 'high risk':
        return 'Moderate Acute Malnutrition (MAM) - Requires nutritional intervention';
      case 'moderate':
        return 'At risk of malnutrition - Monitor closely and improve diet';
      case 'normal':
      default:
        return 'Normal nutritional status - Continue good practices';
    }
  }
  
  static List<String> getRiskRecommendations(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
        return [
          'Refer to nearest health facility immediately',
          'Ready-to-use therapeutic food (RUTF) may be needed',
          'Medical assessment for complications',
          'Admission for inpatient care may be required',
        ];
      case 'high risk':
        return [
          'Increase meal frequency to 5-6 times per day',
          'Add energy-dense foods (oil, ghee, nuts)',
          'Fortified supplementary foods',
          'Monitor weight weekly',
          'Consult healthcare provider',
        ];
      case 'moderate':
        return [
          'Improve dietary diversity',
          'Ensure adequate protein intake',
          'Add nutritious snacks between meals',
          'Monitor growth monthly',
        ];
      case 'normal':
      default:
        return [
          'Continue current feeding practices',
          'Maintain dietary diversity',
          'Regular growth monitoring',
          'Ensure complete immunization',
        ];
    }
  }
  
  static List<Map<String, dynamic>> getGrowthChartReference(bool isMale, String type) {

    if (type == 'weight_for_age') {
      return [
        {'age': 0, 'median': isMale ? 3.3 : 3.2, 'sd': 0.5},
        {'age': 1, 'median': isMale ? 4.5 : 4.2, 'sd': 0.6},
        {'age': 2, 'median': isMale ? 5.6 : 5.1, 'sd': 0.7},
        {'age': 3, 'median': isMale ? 6.4 : 5.8, 'sd': 0.8},
        {'age': 6, 'median': isMale ? 7.9 : 7.3, 'sd': 0.9},
        {'age': 9, 'median': isMale ? 9.2 : 8.6, 'sd': 1.0},
        {'age': 12, 'median': isMale ? 9.6 : 9.0, 'sd': 1.1},
        {'age': 18, 'median': isMale ? 10.9 : 10.2, 'sd': 1.2},
        {'age': 24, 'median': isMale ? 12.2 : 11.5, 'sd': 1.3},
        {'age': 36, 'median': isMale ? 14.3 : 13.9, 'sd': 1.5},
        {'age': 48, 'median': isMale ? 16.3 : 16.0, 'sd': 1.8},
        {'age': 60, 'median': isMale ? 18.3 : 18.2, 'sd': 2.0},
      ];
    }
    return [];
  }
}
