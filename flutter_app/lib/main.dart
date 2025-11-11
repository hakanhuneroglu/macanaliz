import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MacAnalizApp());
}

class MacAnalizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Maç Analiz',
      home: HomeScreen(),
    );
  }
}
