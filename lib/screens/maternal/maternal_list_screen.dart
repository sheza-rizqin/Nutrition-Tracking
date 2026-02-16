import 'package:flutter/material.dart';
import '../../database/app_database.dart';
import 'maternal_form_screen.dart';
import 'maternal_detail_screen.dart';

class MaternalListScreen extends StatefulWidget {
  const MaternalListScreen({super.key});

  @override
  State<MaternalListScreen> createState() => _MaternalListScreenState();
}

class _MaternalListScreenState extends State<MaternalListScreen> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await AppDatabase.instance.getAllMaternalRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maternal Health Records'),
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
              builder: (context) => const MaternalFormScreen(),
            ),
          );
          _loadRecords();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: const Color(0xFFE91E63),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pregnant_woman,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No maternal records yet',
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
    final trimester = record['current_trimester'] ?? 1;
    final name = record['name'] ?? 'Unknown';
    final age = record['age'] ?? 0;

   
    final risk = record['ml_predicted_label']; 

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
              builder: (context) => MaternalDetailScreen(
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
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.pregnant_woman,
                  size: 30,
                  color: Color(0xFFE91E63),
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
                      'Age: $age years • Trimester: $trimester',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (record['edd'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'EDD: ${record['edd']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    _buildRiskChip(risk),
                  ],
                ),
              ),

              // TRIMESTER BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getTrimesterColor(trimester),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'T$trimester',
                  style: const TextStyle(
                    color: Colors.white,
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

  
  Widget _buildRiskChip(String? risk) {
    if (risk == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "No Prediction",
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      );
    }

    Color color;
    if (risk == "high risk") {
      color = Colors.red;
    } else if (risk == "mid risk") {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        risk.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }

  Color _getTrimesterColor(int trimester) {
    switch (trimester) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
