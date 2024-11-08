import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class PrintScreen extends StatefulWidget {
  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  static const platform = MethodChannel('br.com.aditum.payment');
  final _formKey = GlobalKey<FormState>();
  String _docTef = ''; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Texto para Impressão'),
                keyboardType: TextInputType.text, 
                onChanged: (value) {
                  setState(() {
                    _docTef = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _docTef.isNotEmpty && _formKey.currentState!.validate() 
                    ? () {
                        _invokeMethod('print', _docTef);
                      }
                    : null, 
                child: Text('Imprimir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _invokeMethod(String method, String docTef) async {
    try {
      final String result = await platform.invokeMethod(method, {'nsu': docTef});
      print('Result: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}