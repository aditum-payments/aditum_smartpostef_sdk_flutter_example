import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              TextFormField(
                decoration: InputDecoration(labelText: 'DOC TEF'),
                keyboardType: TextInputType.number, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o DOC TEF';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _docTef = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _formKey.currentState!.validate() 
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
      final String result = await platform.invokeMethod(method, {'docTef': docTef});
      print('Result: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}