import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  static const platform = MethodChannel('br.com.aditum.payment'); // Nome do canal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _invokeMethod('pay');
          },
          child: Text('Pagar'),
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