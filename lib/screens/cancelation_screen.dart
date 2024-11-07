import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CancelationScreen extends StatefulWidget {
  @override
  _CancelationScreenState createState() => _CancelationScreenState();
}

class _CancelationScreenState extends State<CancelationScreen> {
  static const platform = MethodChannel('br.com.aditum.payment'); 
  final _formKey = GlobalKey<FormState>();
  String _docTef = '';
  bool _isReversal = false; // Variável para o checkbox

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancelation'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'DOC TEF'),
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
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Reversal?'),
                value: _isReversal,
                onChanged: (value) {
                  setState(() {
                    _isReversal = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _docTef.isNotEmpty && _formKey.currentState!.validate()
                    ? () {
                        _invokeMethod('cancelation', _docTef, _isReversal);
                      }
                    : null,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _invokeMethod(String method, String docTef, bool isReversal) async {
    try {
      final bool result = await platform.invokeMethod(
          method, {'nsu': docTef, 'isReversal': isReversal});
      print('Result: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}