import 'package:flutter/material.dart';
import 'pages/excel_picker.dart';

void main() {
  runApp(const MacAnalizApp());
}

class MacAnalizApp extends StatelessWidget {
  const MacAnalizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'macanaliz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ExcelPickerPage(),
    );
  }
}
