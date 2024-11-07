import 'package:flutter/material.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/init_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MethodChannel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitScreen(),
    );
  }
}