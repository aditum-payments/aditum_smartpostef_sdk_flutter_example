import 'package:flutter/material.dart';
import '../screens/pay_screen.dart';

class CartScreen extends StatelessWidget {
  final Map<Product, int> cart;
  final double total;
  final void Function(Product) removeFromCart;
  final Future<void> Function(String, double) onPay;

  const CartScreen({
    Key? key,
    required this.cart,
    required this.total,
    required this.removeFromCart,
    required this.onPay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrinho')),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_shopping_cart, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Seu carrinho está vazio',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: cart.entries.map((entry) => ListTile(
                      leading: Image.network(
                        entry.key.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      title: Text(entry.key.name),
                      subtitle: Text(
                        'Qtd: ${entry.value} - R\$ ${(entry.key.price * entry.value).toStringAsFixed(2)}'
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () {
                          removeFromCart(entry.key);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    )).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: cart.isNotEmpty ? () => onPay('pay', total) : null,
              child: Text('Pagar'),
            ),
          ),
        ],
      ),
    );
  }
}