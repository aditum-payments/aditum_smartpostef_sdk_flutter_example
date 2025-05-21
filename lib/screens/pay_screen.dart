import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cancelation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cart_state.dart';

class Product {
  final String name;
  final double price;
  final String imageUrl; // Caminho ou URL da imagem

  Product({required this.name, required this.price, required this.imageUrl});
}

class PayScreen extends StatefulWidget {
  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  static const platform = MethodChannel('br.com.aditum.payment');

  final List<Product> products = [
    Product(
      name: 'Café Microlote 250g',
      price: 25.0,
      imageUrl: 'https://images.unsplash.com/photo-1645119917964-1b0763695ec7?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0', // Café em grãos
    ),
    Product(
      name: 'Café Microlote 1kg',
      price: 85.0,
      imageUrl: 'https://images.unsplash.com/photo-1604355224421-5645eb99fd25?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0', // Saco de café
    ),
    Product(
      name: 'Café Arábica 250g',
      price: 20.0,
      imageUrl: 'https://images.unsplash.com/photo-1695675010422-fcb2ea6120e0?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0', // Xícara de café
    ),
    Product(
      name: 'Café Arábica 1kg',
      price: 70.0,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80', // Café torrado
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    final cart = cartState.cart;
    final total = cartState.total;
    final cartCount = cartState.cartCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bradesco Store'),
        // Remova o ícone do carrinho do AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: products.map((product) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagem maior
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    // Remove Spacer e Align, botão já fica colado no fim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => cartState.addToCart(product),
                        child: Text('Adicionar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 = PayScreen
        onTap: (index) {
          if (index == 0) {
            // Já está na PayScreen, não faz nada
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CancelationScreen()),
            );
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
}