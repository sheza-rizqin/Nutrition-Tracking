import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/app_database.dart';
import '../../utils/helpers.dart';

class ChildFormScreen extends StatefulWidget {
  final int? recordId;

  const ChildFormScreen({super.key, this.recordId});

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _muacController = TextEditingController();
  
  DateTime? _dateOfBirth;
  String _gender = 'Male';
  String _feedingPractice = 'Breastfeeding';
  String _illnessEpisodes = 'None';
  String _milestones = 'On track';
  String _immunizations = 'Up to date';
  
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
    final record = await AppDatabase.instance.getChildRecord(widget.recordId!);
    if (record != null) {
      setState(() {
        _nameController.text = record['name'] ?? '';
        _weightController.text = record['weight']?.toString() ?? '';
        _heightController.text = record['height']?.toString() ?? '';
        _muacController.text = record['muac']?.toString() ?? '';
        _gender = record['gender'] ?? 'Male';
        _feedingPractice = record['feeding_practice'] ?? 'Breastfeeding';
        _illnessEpisodes = record['illness_episodes'] ?? 'None';
        _milestones = record['milestones'] ?? 'On track';
        _immunizations = record['immunizations'] ?? 'Up to date';
        if (record['date_of_birth'] != null) {
          _dateOfBirth = DateTime.parse(record['date_of_birth']);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final weight = double.parse(_weightController.text);
    final height = _heightController.text.isNotEmpty
        ? double.parse(_heightController.text)
        : null;
    final muac = _muacController.text.isNotEmpty
        ? double.parse(_muacController.text)
        : null;

    final ageMonths = _calculateAgeMonths(_dateOfBirth!);

    String riskLevel = 'Normal';
    if (height != null) {
      final zScore = WHOStandards.calculateWFLZScore(
        weight,
        height,
        _gender == 'Male',
      );
      riskLevel = WHOStandards.getRiskLevel(zScore, muac);
    }

    final record = {
      'name': _nameController.text,
      'date_of_birth': _dateOfBirth!.toIso8601String(),
      'gender': _gender,
      'weight': weight,
      'height': height,
      'muac': muac,
      'feeding_practice': _feedingPractice,
      'illness_episodes': _illnessEpisodes,
      'milestones': _milestones,
      'immunizations': _immunizations,
      'risk_level': riskLevel,
    };

    try {
      int childId;
      if (widget.recordId != null) {
        await AppDatabase.instance.updateChildRecord(widget.recordId!, record);
        childId = widget.recordId!;
      } else {
        childId = await AppDatabase.instance.insertChildRecord(record);
      }

      final measurement = {
        'child_id': childId,
        'measurement_date': DateTime.now().toIso8601String(),
        'age_months': ageMonths,
        'weight': weight,
        'height': height,
        'muac': muac,
        'z_score_wfl': height != null
            ? WHOStandards.calculateWFLZScore(weight, height, _gender == 'Male')
            : null,
        'z_score_wfa': null, 
        'z_score_hfa': null, 
      };
      await AppDatabase.instance.insertGrowthMeasurement(measurement);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _calculateAgeMonths(DateTime dob) {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    return months;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recordId != null ? 'Edit Child Record' : 'New Child Record'),
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
                    _buildSectionTitle('Basic Information'),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Child Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.child_care),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Date of Birth *'),
                            subtitle: Text(_dateOfBirth != null
                                ? DateFormat('dd MMM yyyy').format(_dateOfBirth!)
                                : 'Not set'),
                            trailing: const Icon(Icons.calendar_today),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dateOfBirth ?? DateTime.now(),
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => _dateOfBirth = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.wc),
                      ),
                      items: ['Male', 'Female'].map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _gender = value!);
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Growth Measurements'),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                        suffixText: 'kg',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height/Length',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _muacController,
                      decoration: const InputDecoration(
                        labelText: 'MUAC (Mid-Upper Arm Circumference)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Feeding & Health'),
                    DropdownButtonFormField<String>(
                      value: _feedingPractice,
                      decoration: const InputDecoration(
                        labelText: 'Feeding Practice',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.restaurant),
                      ),
                      items: [
                        'Exclusive Breastfeeding',
                        'Breastfeeding',
                        'Formula feeding',
                        'Mixed feeding',
                        'Complementary feeding',
                        'Family foods',
                      ].map((practice) {
                        return DropdownMenuItem(
                          value: practice,
                          child: Text(practice),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _feedingPractice = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      initialValue: _illnessEpisodes,
                      decoration: const InputDecoration(
                        labelText: 'Recent Illness Episodes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sick),
                        hintText: 'e.g., diarrhea, fever',
                      ),
                      maxLines: 2,
                      onChanged: (value) => _illnessEpisodes = value,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      initialValue: _milestones,
                      decoration: const InputDecoration(
                        labelText: 'Developmental Milestones',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.stars),
                        hintText: 'e.g., walking, talking',
                      ),
                      maxLines: 2,
                      onChanged: (value) => _milestones = value,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      initialValue: _immunizations,
                      decoration: const InputDecoration(
                        labelText: 'Immunization Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vaccines),
                      ),
                      onChanged: (value) => _immunizations = value,
                    ),
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        widget.recordId != null ? 'Update Record' : 'Save Record',
                        style: const TextStyle(fontSize: 16),
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
          color: Color(0xFF2196F3),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _muacController.dispose();
    super.dispose();
  }
}
