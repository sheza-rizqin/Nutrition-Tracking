import 'dart:convert';
import 'package:http/http.dart' as http;

class MaternalMLService {
  static Future<Map<String, dynamic>> predictRisk(Map<String, dynamic> data) async {
    final url = Uri.parse("http://192.168.1.3:5000/predict");

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    return jsonDecode(res.body);
  }
}
