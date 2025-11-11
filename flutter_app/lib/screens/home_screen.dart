import 'package:flutter/material.dart';
import '../services/excel_picker.dart';
import '../services/excel_reader.dart';
import '../services/rf_predictor.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map>? matchData;
  String resultText = "Henüz tahmin yapılmadı.";

  void loadExcel() async {
    final bytes = await ExcelPicker.pickExcel();
    if (bytes != null) {
      final data = ExcelReader.readExcel(bytes);
      setState(() {
        matchData = data;
        resultText = "Excel yüklendi! Satır sayısı: ${data.length}";
      });
    }
  }

  void makePrediction() {
    if (matchData == null) {
      setState(() => resultText = "Önce Excel yüklemelisin.");
      return;
    }

    final predictions = RFPredictor.predict(matchData!);
    setState(() => resultText = predictions.join("\n"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maç Analiz")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loadExcel,
              child: Text("Excel Yükle"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: makePrediction,
              child: Text("Tahmin Yap"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(resultText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
