import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart'; // ← usamos HomePage
import 'providers/billetera_provider.dart';
import 'providers/chofer_billetera_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BilleteraProvider()),
        ChangeNotifierProvider(create: (context) => ChoferBilleteraProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Transporte App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF4F46E5)),
          useMaterial3: true,
        ),
        home: const HomePage(), // ← aquí cambiamos a HomePage
      ),
    );
  }
}
