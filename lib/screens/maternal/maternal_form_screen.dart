import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../database/app_database.dart';

class MaternalFormScreen extends StatefulWidget {
  final int? recordId;

  const MaternalFormScreen({super.key, this.recordId});

  @override
  State<MaternalFormScreen> createState() => _MaternalFormScreenState();
}

class _MaternalFormScreenState extends State<MaternalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic info
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  // Pregnancy fields
  DateTime? _lmpDate;
  DateTime? _eddDate;
  int _currentTrimester = 1;

  // Nutrition fields
  final _hemoglobinController = TextEditingController();
  final _mealCountController = TextEditingController();
  String _folicAcidIntake = 'Regular';
  String _dietaryDiversity = 'Good';
  String _symptoms = 'None';
  String _foodSecurity = 'Adequate';

  // Vital signs (normal UI — NOT labeled ML)
  final _sysController = TextEditingController();
  final _diaController = TextEditingController();
  final _bsController = TextEditingController();
  final _tempController = TextEditingController();
  final _hrController = TextEditingController();

  // ML output
  String? predictedLabel;
  Map<String, dynamic>? probabilities;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recordId != null) {
      _loadRecord();
    }
  }

  Future<void> _loadRecord() async {
    setState(() => _isLoading = true);
    final record = await AppDatabase.instance.getMaternalRecord(widget.recordId!);

    if (record != null) {
      _nameController.text = record['name'] ?? '';
      _ageController.text = record['age']?.toString() ?? '';

      if (record['lmp'] != null) _lmpDate = DateTime.parse(record['lmp']);
      if (record['edd'] != null) _eddDate = DateTime.parse(record['edd']);

      _currentTrimester = record['current_trimester'] ?? 1;

      _hemoglobinController.text = record['hemoglobin']?.toString() ?? '';
      _mealCountController.text = record['meal_count']?.toString() ?? '';
      _folicAcidIntake = record['folic_acid_intake'] ?? 'Regular';
      _dietaryDiversity = record['dietary_diversity'] ?? 'Good';
      _symptoms = record['symptoms'] ?? 'None';
      _foodSecurity = record['food_security'] ?? 'Adequate';

      // Vital signs
      _sysController.text = record['systolic_bp']?.toString() ?? '';
      _diaController.text = record['diastolic_bp']?.toString() ?? '';
      _bsController.text = record['bs']?.toString() ?? '';
      _tempController.text = record['body_temp']?.toString() ?? '';
      _hrController.text = record['heart_rate']?.toString() ?? '';

      if (record['ml_predicted_label'] != null) {
        predictedLabel = record['ml_predicted_label'];
      }
      if (record['ml_probabilities'] != null) {
        probabilities = Map<String, dynamic>.from(jsonDecode(record['ml_probabilities']));
      }
    }

    setState(() => _isLoading = false);
  }

  void _calculateEDD() {
    if (_lmpDate != null) {
      _eddDate = _lmpDate!.add(const Duration(days: 280));
    }
  }

  Future<void> _runPrediction() async {
    final age = double.tryParse(_ageController.text);
    final sys = double.tryParse(_sysController.text);
    final dia = double.tryParse(_diaController.text);
    final bs = double.tryParse(_bsController.text);
    final temp = double.tryParse(_tempController.text);
    final hr = double.tryParse(_hrController.text);

    if ([age, sys, dia, bs, temp, hr].contains(null)) return;

    try {
      final res = await http.post(
        Uri.parse("http://192.168.1.3:5000/predict"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Age": age,
          "SystolicBP": sys,
          "DiastolicBP": dia,
          "BS": bs,
          "BodyTemp": temp,
          "HeartRate": hr,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        predictedLabel = data["predicted_label"];
        probabilities = data["probabilities"];
      }
    } catch (_) {}
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await _runPrediction(); 

    final record = {
      'name': _nameController.text,
      'age': int.parse(_ageController.text),
      'lmp': _lmpDate?.toIso8601String(),
      'edd': _eddDate?.toIso8601String(),
      'current_trimester': _currentTrimester,
      'hemoglobin': double.tryParse(_hemoglobinController.text),
      'folic_acid_intake': _folicAcidIntake,
      'meal_count': int.tryParse(_mealCountController.text),
      'dietary_diversity': _dietaryDiversity,
      'symptoms': _symptoms,
      'food_security': _foodSecurity,

      // vital signs
      'systolic_bp': int.tryParse(_sysController.text),
      'diastolic_bp': int.tryParse(_diaController.text),
      'bs': double.tryParse(_bsController.text),
      'body_temp': double.tryParse(_tempController.text),
      'heart_rate': int.tryParse(_hrController.text),

      // save ML results
      'ml_predicted_label': predictedLabel,
      'ml_probabilities': probabilities != null ? jsonEncode(probabilities) : null,
    };

    try {
      if (widget.recordId != null) {
        await AppDatabase.instance.updateMaternalRecord(widget.recordId!, record);
      } else {
        await AppDatabase.instance.insertMaternalRecord(record);
      }

      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving record: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  Color _riskColor(String? label) {
    if (label == "high risk") return Colors.red;
    if (label == "mid risk") return Colors.orange;
    return Colors.green;
  }

  String _guidanceText(String? label) {
    if (label == "high risk") {
      return "⚠ High Risk — Immediate medical attention recommended.";
    } else if (label == "mid risk") {
      return "⚠ Moderate Risk — Monitor closely and counsel appropriately.";
    } else {
      return "✓ Low Risk — Continue routine care.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordId != null ? 'Edit Record' : 'New Maternal Record'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    _buildSectionTitle('Personal Information'),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age *',
                        border: OutlineInputBorder(),
                        suffixText: 'years',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Enter age' : null,
                    ),
                    const SizedBox(height: 24),

                    // Pregnancy Details
                    _buildSectionTitle('Pregnancy Details'),

                    ListTile(
                      title: const Text("Last Menstrual Period"),
                      subtitle: Text(_lmpDate != null
                          ? DateFormat('dd MMM yyyy').format(_lmpDate!)
                          : "Not set"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _lmpDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _lmpDate = date;
                            _calculateEDD();
                          });
                        }
                      },
                    ),

                    ListTile(
                      title: const Text("Expected Delivery Date"),
                      subtitle: Text(_eddDate != null
                          ? DateFormat('dd MMM yyyy').format(_eddDate!)
                          : "Not calculated"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _eddDate ?? DateTime.now().add(const Duration(days: 280)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => _eddDate = date);
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      value: _currentTrimester,
                      decoration: const InputDecoration(
                        labelText: "Current Trimester",
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3]
                          .map((t) => DropdownMenuItem(value: t, child: Text("Trimester $t")))
                          .toList(),
                      onChanged: (v) => setState(() => _currentTrimester = v!),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle('Nutrition & Health'),

            
                    TextFormField(
                      controller: _sysController,
                      decoration: const InputDecoration(
                          labelText: 'Systolic BP', border: OutlineInputBorder(), suffixText: 'mmHg'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _diaController,
                      decoration: const InputDecoration(
                          labelText: 'Diastolic BP', border: OutlineInputBorder(), suffixText: 'mmHg'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bsController,
                      decoration: const InputDecoration(
                          labelText: 'Blood Sugar', border: OutlineInputBorder(), suffixText: 'mg/dL'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _tempController,
                      decoration: const InputDecoration(
                          labelText: 'Body Temperature', border: OutlineInputBorder(), suffixText: '°C'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hrController,
                      decoration: const InputDecoration(
                          labelText: 'Heart Rate', border: OutlineInputBorder(), suffixText: 'bpm'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    
                    TextFormField(
                      controller: _hemoglobinController,
                      decoration: const InputDecoration(
                        labelText: 'Hemoglobin Level',
                        border: OutlineInputBorder(),
                        suffixText: 'g/dL',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _folicAcidIntake,
                      decoration: const InputDecoration(
                        labelText: 'Folic Acid Intake',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Regular', 'Irregular', 'None']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _folicAcidIntake = v!),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _mealCountController,
                      decoration: const InputDecoration(
                        labelText: 'Meals Per Day',
                        border: OutlineInputBorder(),
                        suffixText: 'meals',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _dietaryDiversity,
                      decoration: const InputDecoration(
                        labelText: 'Dietary Diversity',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Good', 'Moderate', 'Poor']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _dietaryDiversity = v!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _foodSecurity,
                      decoration: const InputDecoration(
                        labelText: 'Food Security',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Adequate', 'Moderate', 'Inadequate']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _foodSecurity = v!),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _symptoms,
                      decoration: const InputDecoration(
                        labelText: 'Symptoms',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      onChanged: (v) => _symptoms = v,
                    ),

                    const SizedBox(height: 24),

                    if (predictedLabel != null)
                      Card(
                        color: _riskColor(predictedLabel).withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _riskColor(predictedLabel).withOpacity(0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Risk Level: ${predictedLabel!.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _riskColor(predictedLabel),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (probabilities != null)
                                ...probabilities!.entries.map((e) {
                                  final pct = (e.value * 100).toStringAsFixed(1);
                                  return Text("${e.key}: $pct%");
                                }),
                              const SizedBox(height: 12),
                              Text(_guidanceText(predictedLabel)),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFFE91E63),
                      ),
                      child: Text(
                        widget.recordId != null ? "Update Record" : "Save Record",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE91E63),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _hemoglobinController.dispose();
    _mealCountController.dispose();
    _sysController.dispose();
    _diaController.dispose();
    _bsController.dispose();
    _tempController.dispose();
    _hrController.dispose();
    super.dispose();
  }
}
