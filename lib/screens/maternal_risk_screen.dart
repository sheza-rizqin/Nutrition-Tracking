import 'package:flutter/material.dart';
import '../services/maternal_ml_service.dart';

class MaternalRiskScreen extends StatefulWidget {
  @override
  _MaternalRiskScreenState createState() => _MaternalRiskScreenState();
}

class _MaternalRiskScreenState extends State<MaternalRiskScreen> {
  final age = TextEditingController();
  final sbp = TextEditingController();
  final dbp = TextEditingController();
  final bs = TextEditingController();
  final temp = TextEditingController();
  final hr = TextEditingController();

  String result = "";
  bool loading = false;

  predict() async {
    setState(() => loading = true);

    final res = await MaternalMLService.predictRisk({
      "Age": int.parse(age.text),
      "SystolicBP": int.parse(sbp.text),
      "DiastolicBP": int.parse(dbp.text),
      "BS": double.parse(bs.text),
      "BodyTemp": double.parse(temp.text),
      "HeartRate": int.parse(hr.text),
    });

    setState(() {
      result = res["predicted_label"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maternal Risk Prediction")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: age, decoration: InputDecoration(labelText: "Age")),
            TextField(controller: sbp, decoration: InputDecoration(labelText: "Systolic BP")),
            TextField(controller: dbp, decoration: InputDecoration(labelText: "Diastolic BP")),
            TextField(controller: bs, decoration: InputDecoration(labelText: "Blood Sugar")),
            TextField(controller: temp, decoration: InputDecoration(labelText: "Body Temperature")),
            TextField(controller: hr, decoration: InputDecoration(labelText: "Heart Rate")),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : predict,
              child: loading ? CircularProgressIndicator() : Text("Predict"),
            ),

            SizedBox(height: 20),
            Text(
              result.isEmpty ? "Enter info to get prediction" : "Risk Level: $result",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
