import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // ← usamos HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transporte App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const HomePage(), // ← aquí cambiamos a HomePage
    );
  }
}
