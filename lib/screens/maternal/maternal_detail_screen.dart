import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../database/app_database.dart';
import '../../utils/nutrition_guidance.dart';
import '../../utils/tts_service.dart';
import 'maternal_form_screen.dart';

class MaternalDetailScreen extends StatefulWidget {
  final int recordId;

  const MaternalDetailScreen({super.key, required this.recordId});

  @override
  State<MaternalDetailScreen> createState() => _MaternalDetailScreenState();
}

class _MaternalDetailScreenState extends State<MaternalDetailScreen> {
  Map<String, dynamic>? _record;
  bool _isLoading = true;

  // ML prediction state
  bool _predicting = false;
  String? _predictedLabel;
  Map<String, dynamic>? _probabilities;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    setState(() => _isLoading = true);
    final record = await AppDatabase.instance.getMaternalRecord(widget.recordId);

    setState(() {
      _record = record;
      _predictedLabel = record?['ml_predicted_label'];
      _probabilities = record?['ml_probabilities'] != null
          ? Map<String, dynamic>.from(jsonDecode(record!['ml_probabilities']))
          : null;

      _isLoading = false;
    });
  }


  Future<void> _runPrediction() async {
    if (_record == null) return;

    final age = _record!['age'];
    final sys = _record!['systolic_bp'];
    final dia = _record!['diastolic_bp'];
    final bs = _record!['bs'];
    final temp = _record!['body_temp'];
    final hr = _record!['heart_rate'];

    if (age == null || sys == null || dia == null || bs == null || temp == null || hr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing BP / Sugar / Temp / HR. Edit record to add them.")),
      );
      return;
    }

    setState(() => _predicting = true);

    final url = Uri.parse("http://192.168.1.3:5000/predict");

    final body = {
      "Age": age.toDouble(),
      "SystolicBP": sys.toDouble(),
      "DiastolicBP": dia.toDouble(),
      "BS": bs.toDouble(),
      "BodyTemp": temp.toDouble(),
      "HeartRate": hr.toDouble(),
    };

    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          _predictedLabel = data["predicted_label"];
          _probabilities = Map<String, dynamic>.from(data["probabilities"]);
        });

        await AppDatabase.instance.updateMaternalRecord(widget.recordId, {
          "ml_predicted_label": _predictedLabel,
          "ml_probabilities": jsonEncode(_probabilities),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Prediction saved.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${res.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Prediction failed: $e")),
      );
    }

    setState(() => _predicting = false);
  }

  Color _riskColor(String? label) {
    if (label == "high risk") return Colors.red;
    if (label == "mid risk") return Colors.orange;
    return Colors.green;
  }

  String _riskText(String? label) {
    if (label == "high risk") return "⚠ High risk — Needs urgent monitoring.";
    if (label == "mid risk") return "⚠ Moderate risk — Follow-up required.";
    if (label == "low risk") return "✓ Low risk — Normal ANC care.";
    return "No prediction yet.";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Record")),
        body: const Center(child: Text("Record not found")),
      );
    }

    final trimester = _record!['current_trimester'] ?? 1;
    final guidance = NutritionGuidance.getMaternalGuidance(trimester, _record!);

    return Scaffold(
      appBar: AppBar(
        title: Text(_record!['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final refreshed = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MaternalFormScreen(recordId: widget.recordId)),
              );
              if (refreshed == true) _loadRecord();
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            
            _buildHeader(),

            _buildDetails(),

            _buildGuidanceSection(guidance),

            _buildPredictionCard(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFE91E63).withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.pregnant_woman, size: 50, color: Color(0xFFE91E63))),
          const SizedBox(height: 10),
          Text(_record!['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Age: ${_record!['age']}",
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
        ],
      ),
    );
  }


  Widget _buildDetails() {
    return Column(
      children: [
        _buildSection("Pregnancy Information", [
          if (_record!['lmp'] != null)
            _row("LMP", DateFormat('dd MMM yyyy').format(DateTime.parse(_record!['lmp']))),
          if (_record!['edd'] != null)
            _row("EDD", DateFormat('dd MMM yyyy').format(DateTime.parse(_record!['edd']))),
          _row("Trimester", "Trimester ${_record!['current_trimester']}"),
        ]),

        _buildSection("Health Status", [
          if (_record!['hemoglobin'] != null)
            _row("Hemoglobin", "${_record!['hemoglobin']} g/dL"),
          _row("Folic Acid Intake", _record!['folic_acid_intake']),
          if (_record!['symptoms'] != "None")
            _row("Symptoms", _record!['symptoms']),
        ]),

        _buildSection("Nutrition Status", [
          if (_record!['meal_count'] != null)
            _row("Meals Per Day", "${_record!['meal_count']}"),
          _row("Dietary Diversity", _record!['dietary_diversity']),
          _row("Food Security", _record!['food_security']),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
        const SizedBox(height: 10),
        ...children
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
        Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildGuidanceSection(Map<String, dynamic> g) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.lightbulb, color: Colors.orange),
            SizedBox(width: 8),
            Text("Nutrition Guidance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green))
          ]),
          const SizedBox(height: 12),

          _guidanceBlock("Key Nutrients", g['nutrients']),
          const SizedBox(height: 8),

          _guidanceBlock("Food Recommendations", g['foods']),
          const SizedBox(height: 8),

          _guidanceBlock("Recommendations", g['recommendations']),

          if (g['warnings'].isNotEmpty) ...[
            const SizedBox(height: 8),
            _guidanceBlock("Important Reminders", g['warnings'], isWarn: true),
          ],
        ],
      ),
    );
  }

  Widget _guidanceBlock(String title, List<String> items, {bool isWarn = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarn ? Colors.orange : Colors.green[900],
            )),
        const SizedBox(height: 6),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                const Text("• "),
                Expanded(child: Text(e)),
              ]),
            ))
      ],
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("AI Risk Prediction",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _predicting ? null : _runPrediction,
          icon: const Icon(Icons.auto_awesome),
          label: Text(_predicting ? "Predicting..." : "Run Prediction"),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, foregroundColor: Colors.white),
        ),

        const SizedBox(height: 12),

        if (_predictedLabel != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _riskColor(_predictedLabel).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _riskColor(_predictedLabel)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Risk Level: ${_predictedLabel!.toUpperCase()}",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _riskColor(_predictedLabel))),

              const SizedBox(height: 6),

              if (_probabilities != null)
                ..._probabilities!.entries.map((e) {
                  final pct = (e.value * 100).toStringAsFixed(1);
                  return Text("${e.key}: $pct%");
                }),

              const SizedBox(height: 6),

              Text(_riskText(_predictedLabel))
            ]),
          ),
      ]),
    );
  }
}
