import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/pay_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cancelation_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_state.dart';

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
    final cartState = Provider.of<CartState>(context);
    final cart = cartState.cart;
    final total = cartState.total;
    final cartCount = cartState.cartCount;

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
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartScreen(
                  removeFromCart: cartState.removeFromCart, // ajuste conforme necessário
                ),
              ),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Principal',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Confirmação',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Cancelamento',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrinho',
          ),
        ],
        type: BottomNavigationBarType.fixed,
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