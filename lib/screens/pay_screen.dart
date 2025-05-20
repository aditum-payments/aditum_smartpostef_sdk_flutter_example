import 'package:aditum_smartpostef_sdk_flutter_example/screens/cart_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/confirm_screen.dart';
import 'package:aditum_smartpostef_sdk_flutter_example/screens/cancelation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=80&q=80',
    ),
    Product(
      name: 'Café Microlote 1kg',
      price: 85.0,
      imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=80&q=80',
    ),
    Product(
      name: 'Café Arábica 250g',
      price: 20.0,
      imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=80&q=80',
    ),
    Product(
      name: 'Café Arábica 1kg',
      price: 70.0,
      imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=80&q=80',
    ),
  ];

  final Map<Product, int> cart = {};

  double get total => cart.entries.fold(
      0, (sum, entry) => sum + entry.key.price * entry.value);

  void addToCart(Product product) {
    setState(() {
      cart[product] = (cart[product] ?? 0) + 1;
    });
    // Exibe um toast/snackbar ao adicionar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho!'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void removeFromCart(Product product) {
    setState(() {
      if (cart[product] != null && cart[product]! > 1) {
        cart[product] = cart[product]! - 1;
      } else {
        cart.remove(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int cartCount = cart.values.fold(0, (sum, qty) => sum + qty);

    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cart: cart,
                        total: total,
                        removeFromCart: removeFromCart,
                        onPay: _invokeMethod,
                      ),
                    ),
                  );
                },
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
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
                    Spacer(), // Empurra o botão para o final do card
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
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
                          onPressed: () => addToCart(product),
                          child: Text('Adicionar'),
                        ),
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
              MaterialPageRoute(builder: (_) => ConfirmScreen()),
            );
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

  Future<void> _invokeMethod(String method, double amount) async {
    try {
      final int intAmount = (amount * 100).round(); // Multiplica por 100 para centavos
      final result = await platform.invokeMethod(
        method,
        {'amount': intAmount},
      );
      // Considerando que result é um objeto com a propriedade booleana isApproved
      final bool isApproved = result.isApproved ?? false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApproved ? 'Pagamento aprovado!' : 'Pagamento não aprovado!'),
            backgroundColor: isApproved ? Colors.green : Colors.red,
          ),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao pagar: ${e.message}')),
        );
      }
    }
  }
}