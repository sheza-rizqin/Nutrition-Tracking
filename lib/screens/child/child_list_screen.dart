import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import 'child_form_screen.dart';
import 'child_detail_screen.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({super.key});

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await AppDatabase.instance.getAllChildRecords();
    setState(() {
      _records = records;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Health Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return _buildRecordCard(record);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChildFormScreen(),
            ),
          );
          _loadRecords();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Child'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No child records yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new record',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final name = record['name'] ?? 'Unknown';
    final gender = record['gender'] ?? 'Not specified';
    final ageMonths = _calculateAgeMonths(record['date_of_birth']);
    final weight = record['weight']?.toString() ?? 'N/A';
    final riskLevel = record['risk_level'] ?? 'Normal';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildDetailScreen(
                recordId: record['id'],
              ),
            ),
          );
          _loadRecords();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  gender == 'Male' ? Icons.boy : Icons.girl,
                  size: 30,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age: $ageMonths months • Weight: $weight kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getRiskIcon(riskLevel),
                          size: 16,
                          color: _getRiskColor(riskLevel),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          riskLevel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRiskColor(riskLevel),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: gender == 'Male' 
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.pink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  gender,
                  style: TextStyle(
                    color: gender == 'Male' ? Colors.blue[700] : Colors.pink[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
        return Colors.red[700]!;
      case 'high risk':
        return Colors.orange[700]!;
      case 'moderate':
        return Colors.yellow[700]!;
      case 'normal':
      default:
        return Colors.green[700]!;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'severe':
      case 'high risk':
        return Icons.warning;
      case 'moderate':
        return Icons.info;
      case 'normal':
      default:
        return Icons.check_circle;
    }
  }
}
