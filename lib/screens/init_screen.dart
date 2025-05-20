import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/home_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/pay_screen.dart';

class InitScreen extends StatefulWidget {
  @override
  _InitScreenState createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  static const platform = MethodChannel('br.com.aditum.payment');
  final _formKey = GlobalKey<FormState>();
  String _activationCode = '433223068';
  bool _isLoading = false; // Adicione esta linha

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      // ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo do Bradesco
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Image.network(
                      'https://storage.googleapis.com/merchantcustomization.appspot.com/bradesco-dev.aditum.com.br/logo.png',
                      height: 80,
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Código de Ativação'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    initialValue: '433223068',
                    enabled: true,
                    onChanged: (value) {
                      setState(() {
                        _activationCode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código de ativação';
                      }
                      if (value.length != 9) {
                        return 'O código de ativação deve ter 9 dígitos';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _invokeMethod('init', _activationCode);
                          },
                          child: Text('Iniciar'),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _invokeMethod('deactivate', "");
                          },
                          child: Text('Desativar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _invokeMethod(String method, String activationCode) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, dynamic> arguments = activationCode != null
          ? {'activationCode': activationCode}
          : {};
      final result = await platform.invokeMethod(method, arguments);
      // print('Result: $result');
      if (method == 'init') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PayScreen()),
        );
      }
    } on PlatformException catch (e) {
      // print('Failed to invoke: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}