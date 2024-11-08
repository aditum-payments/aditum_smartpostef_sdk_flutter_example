import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/home_screen.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  static const platform = MethodChannel('br.com.aditum.payment'); // Nome do canal
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  String _activationCode = ''; // Variável para armazenar o código de ativação

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Init'),
      ),
      body: Form(
        key: _formKey, // Associa a chave ao Form
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Código de Ativação'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Permite apenas dígitos
                  LengthLimitingTextInputFormatter(9), // Limita a 9 dígitos
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código de ativação';
                  }
                  if (value.length != 9) {
                    return 'O código de ativação deve ter 9 dígitos';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _activationCode = value; // Atualiza o código de ativação
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _activationCode.length == 9 && _formKey.currentState!.validate() 
                    ? () {
                        _invokeMethod('init', _activationCode);
                      }
                    : null, // Habilita o botão se o código tiver 9 dígitos
                child: Text('Iniciar'),
              ), 
              SizedBox(height: 20),
              ElevatedButton( // Adiciona o botão Desativar
                onPressed: () {
                  _invokeMethod('deactivate', ""); // Chama o método deactivate
                },
                child: Text('Desativar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _invokeMethod(String method, String activationCode) async {
    try {
      final Map<String, dynamic> arguments = activationCode != null
          ? {'activationCode': activationCode}
          : {};
      final result = await platform.invokeMethod(method, arguments);
      print('Result: $result');
      // Navegue para a HomeScreen
      if (method == 'init') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        ); 
      }
    } on PlatformException catch (e) {
      print('Failed to invoke: ${e.message}');
    }
  }
}