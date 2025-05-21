import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/pay_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_state.dart';

class CancelationScreen extends StatefulWidget {
  @override
  _CancelationScreenState createState() => _CancelationScreenState();
}

class _CancelationScreenState extends State<CancelationScreen> {
  static const platform = MethodChannel('br.com.aditum.payment');
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
        title: Text('Cancelamento'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'DOC TEF',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _docTef.isNotEmpty && _formKey.currentState!.validate()
                      ? () {
                          _invokeMethod('cancelation', _docTef);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // 1 = CancelationScreen (agora só 3 itens)
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PayScreen()),
            );
          } else if (index == 1) {
            // Já está na CancelationScreen, não faz nada
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartScreen(
                  removeFromCart: cartState.removeFromCart
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
      final bool result = await platform.invokeMethod(
          method, {'nsu': docTef, 'isReversal': false});
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result ? 'Sucesso' : 'Cancelamento negado'),
          content: Text(result
              ? 'Cancelamento realizado com sucesso!'
              : 'Não foi possível cancelar a transação.'),
          backgroundColor: result ? Colors.green[50] : Colors.red[50],
          titleTextStyle: TextStyle(
            color: result ? Colors.green[900] : Colors.red[900],
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          contentTextStyle: TextStyle(
            color: result ? Colors.green[900] : Colors.red[900],
            fontSize: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Falha ao cancelar'),
          content: Text('Erro: ${e.message ?? 'Erro desconhecido.'}'),
          backgroundColor: Colors.red[50],
          titleTextStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          contentTextStyle: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}