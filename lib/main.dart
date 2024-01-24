import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoctorGPT',
      theme: ThemeData(
        // color scheme for the entire app.
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(210, 16, 0, 35)),
        // material design language
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}
