// lib/ml/maternal_ml_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class MaternalMLService {
  // 🔥 REPLACE WITH YOUR LAPTOP'S IP ADDRESS
  // Example: "http://192.168.1.8:5000/predict"
  static const String _serverUrl = "http://192.168.1.3:5000/predict";

  static Future<Map<String, dynamic>> predictRisk({
    required int age,
    required int systolicBP,
    required int diastolicBP,
    required double bs,
    required double bodyTemp,
    required int heartRate,
  }) async {
    final Uri url = Uri.parse(_serverUrl);

    final Map<String, dynamic> payload = {
      "Age": age,
      "SystolicBP": systolicBP,
      "DiastolicBP": diastolicBP,
      "BS": bs,
      "BodyTemp": bodyTemp,
      "HeartRate": heartRate,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception("ML Server Error: ${response.statusCode}");
    }

    return jsonDecode(response.body);
  }
}

// ✔ HOW TO USE IT IN YOUR SCREEN (EXAMPLE):
// final result = await MaternalMLService.predictRisk(
//   age: 28,
//   systolicBP: 130,
//   diastolicBP: 80,
//   bs: 14.5,
//   bodyTemp: 98.4,
//   heartRate: 82,
// );
// print(result["predicted_label"]);
// print(result["probabilities"]);
