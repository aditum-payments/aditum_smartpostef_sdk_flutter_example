import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/pay_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cancelation_screen.dart';

class ConfirmScreen extends StatefulWidget {
  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  static const platform = MethodChannel('br.com.aditum.payment'); // Nome do canal
  final _formKey = GlobalKey<FormState>();
  String _docTef = ''; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm'),
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
                keyboardType: TextInputType.number, // Define o tipo de teclado como numérico
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
              ElevatedButton(
                onPressed: _docTef.isNotEmpty && _formKey.currentState!.validate() 
                    ? () {
                        _invokeMethod('confirm', _docTef);
                      }
                    : null, 
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 1 = ConfirmScreen
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PayScreen()),
            );
          } else if (index == 1) {
            // Já está na ConfirmScreen, não faz nada
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CancelationScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Confirmação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Cancelamento',
          ),
        ],
      ),
    );
  }

  Future<void> _invokeMethod(String method, String docTef) async {
    try {
      final bool result = await platform.invokeMethod(method, {'nsu': docTef});
      print('Result: $result');
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}