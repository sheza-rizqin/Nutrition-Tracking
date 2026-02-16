import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/app_database.dart';
import '../../utils/who_standards.dart';
import '../../utils/nutrition_guidance.dart';
import '../../utils/tts_service.dart';
import 'child_form_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final int recordId;

  const ChildDetailScreen({super.key, required this.recordId});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  Map<String, dynamic>? _record;
  List<Map<String, dynamic>> _growthHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final record = await AppDatabase.instance.getChildRecord(widget.recordId);
    final history = await AppDatabase.instance.getChildGrowthHistory(widget.recordId);
    setState(() {
      _record = record;
      _growthHistory = history;
      _isLoading = false;
    });
  }

  int _calculateAgeMonths(String dob) {
    final birthDate = DateTime.parse(dob);
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    if (now.day < birthDate.day) months--;
    return months;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child Record')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Child Record')),
        body: const Center(child: Text('Record not found')),
      );
    }

    final ageMonths = _calculateAgeMonths(_record!['date_of_birth']);
    final riskLevel = _record!['risk_level'] ?? 'Normal';
    final guidance = NutritionGuidance.getChildGuidance(ageMonths, _record!);

    return Scaffold(
      appBar: AppBar(
        title: Text(_record!['name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildFormScreen(recordId: widget.recordId),
                ),
              );
              if (result == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2196F3),
                    const Color(0xFF2196F3).withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      _record!['gender'] == 'Male' ? Icons.boy : Icons.girl,
                      size: 50,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _record!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Age: $ageMonths months • ${_record!['gender']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: WHOStandards.getRiskColor(riskLevel),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.health_and_safety, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          riskLevel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Risk Alert 
            if (riskLevel != 'Normal') _buildRiskAlert(riskLevel),
            
            // Growth Measurements
            _buildSection(
              'Current Measurements',
              [
                _buildMeasurementCard(
                  'Weight',
                  '${_record!['weight']} kg',
                  Icons.monitor_weight,
                  Colors.blue,
                ),
                if (_record!['height'] != null)
                  _buildMeasurementCard(
                    'Height',
                    '${_record!['height']} cm',
                    Icons.height,
                    Colors.green,
                  ),
                if (_record!['muac'] != null)
                  _buildMeasurementCard(
                    'MUAC',
                    '${_record!['muac']} cm',
                    Icons.straighten,
                    Colors.orange,
                  ),
              ],
            ),
            
            // Growth Chart
            if (_growthHistory.isNotEmpty) _buildGrowthChart(),
            
            // Health Information
            _buildSection(
              'Health Information',
              [
                _buildInfoRow('Date of Birth', DateFormat('dd MMM yyyy').format(DateTime.parse(_record!['date_of_birth']))),
                _buildInfoRow('Feeding Practice', _record!['feeding_practice'] ?? 'Not recorded'),
                _buildInfoRow('Illness Episodes', _record!['illness_episodes'] ?? 'None'),
                _buildInfoRow('Milestones', _record!['milestones'] ?? 'On track'),
                _buildInfoRow('Immunizations', _record!['immunizations'] ?? 'Up to date'),
              ],
            ),
            
            // Nutrition Guidance
            _buildGuidanceSection(guidance, riskLevel),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAlert(String riskLevel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WHOStandards.getRiskColor(riskLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WHOStandards.getRiskColor(riskLevel),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: WHOStandards.getRiskColor(riskLevel),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  WHOStandards.getRiskDescription(riskLevel),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: WHOStandards.getRiskColor(riskLevel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    List<FlSpot> weightSpots = [];
    for (int i = 0; i < _growthHistory.length; i++) {
      final measurement = _growthHistory[i];
      weightSpots.add(FlSpot(
        measurement['age_months'].toDouble(),
        measurement['weight'].toDouble(),
      ));
    }

    // WHO reference data
    final isMale = _record!['gender'] == 'Male';
    final whoData = WHOStandards.getGrowthChartReference(isMale, 'weight_for_age');
    List<FlSpot> whoMedianSpots = [];
    for (var point in whoData) {
      whoMedianSpots.add(FlSpot(point['age'].toDouble(), point['median'].toDouble()));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Chart - Weight for Age',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Text('Age (months)'),
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Text('Weight (kg)'),
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  // WHO reference line
                  LineChartBarData(
                    spots: whoMedianSpots,
                    isCurved: true,
                    color: Colors.grey,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                  // Actual measurements
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: true,
                    color: const Color(0xFF2196F3),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.grey, 'WHO Median', isDashed: true),
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFF2196F3), 'Child\'s Growth'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            border: isDashed ? Border.all(color: color) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGuidanceSection(Map<String, dynamic> guidance, String riskLevel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!,
            Colors.blue[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_information,
                color: Colors.green[700],
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  guidance['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tap to hear guidance aloud
          InkWell(
            onTap: () async {
              final parts = <String>[];
              if (guidance['recommendations'] != null) {
                parts.add('Recommendations: ' + guidance['recommendations'].join('. '));
              }
              parts.add('Risk level: $riskLevel');
              final text = parts.join('\n');
              await TtsService.speak(text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.volume_up, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap to hear guidance',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildGuidanceItem('Key Nutrients', guidance['nutrients'], Icons.science),
          const SizedBox(height: 12),
          
          _buildGuidanceItem('Food Recommendations', guidance['foods'], Icons.restaurant_menu),
          const SizedBox(height: 12),
          
          _buildGuidanceItem('Care Recommendations', guidance['recommendations'], Icons.check_circle),
          
          // Risk specific recommendations
          if (riskLevel != 'Normal') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WHOStandards.getRiskColor(riskLevel).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: WHOStandards.getRiskColor(riskLevel),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: WHOStandards.getRiskColor(riskLevel),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Action Required',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WHOStandards.getRiskColor(riskLevel),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...WHOStandards.getRiskRecommendations(riskLevel).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(left: 28, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              color: WHOStandards.getRiskColor(riskLevel),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rec,
                              style: TextStyle(
                                fontSize: 14,
                                color: WHOStandards.getRiskColor(riskLevel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 28, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
