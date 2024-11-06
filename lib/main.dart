import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example.your_app_name.channel'); // Nome do canal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aditum SDK Android'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _invokeMethod('init');
              },
              child: const Text('Init'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _invokeMethod('pay');
              },
              child: const Text('Pay'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _invokeMethod('confirm');
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _invokeMethod('cancelation');
              },
              child: const Text('Cancelation'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _invokeMethod('print');
              },
              child: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invokeMethod(String method) async {
    try {
      final String result = await platform.invokeMethod(method);
      print('Result: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}