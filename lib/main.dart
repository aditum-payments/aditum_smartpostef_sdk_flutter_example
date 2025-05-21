import 'package:flutter/material.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/init_screen.dart';
import 'package:provider/provider.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aditum Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitScreen(),
    );
  }
}