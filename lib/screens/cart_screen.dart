import 'package:flutter/material.dart';
import '../screens/pay_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'cart_state.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class CartScreen extends StatelessWidget {
  final void Function(Product) removeFromCart;

  const CartScreen({
    Key? key,
    required this.removeFromCart,
  }) : super(key: key);

  // Método centralizado para pagamento
  static Future<void> onPay(BuildContext context, String method, double amount) async {
    try {
      const platform = MethodChannel('br.com.aditum.payment');
      final int intAmount = (amount * 100).round();
      final result = await platform.invokeMethod(
        method,
        {'amount': intAmount},
      );

      // Se o result vier como String, faça o parse:
      final Map<String, dynamic> resultMap = result is String
          ? json.decode(result)
          : Map<String, dynamic>.from(result);

      final paymentResult = PaymentResult.fromJson(resultMap);

      if (paymentResult.isApproved) {
        await _processApiAfterPayment(context, paymentResult);
      }

      if (context.mounted) {
        await _showPaymentDialog(context, paymentResult);
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao pagar: ${e.message}')),
        );
      }
    }
  }

  // Adicione este método auxiliar para exibir o loading com mensagem dinâmica:
  static Future<void> _showLoading(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  // Atualize o método _processApiAfterPayment para exibir o loading nos passos:
  static Future<void> _processApiAfterPayment(
      BuildContext context, PaymentResult paymentResult) async {
    // Confirmação da transação
    const platform = MethodChannel('br.com.aditum.payment');
    final bool confirmationResult =
        await platform.invokeMethod('confirm', {'nsu': paymentResult.charge.nsu});
    print(confirmationResult);

    // 1. Autenticando
    await _showLoading(context, 'Autenticando...');
    final authResponse = await http.post(
      Uri.parse('https://portal-dev.aditum.com.br/v1/Login/GenerateToken'),
      headers: {
        'MerchantToken': 'mk_jHa8Jfx3bkOdKovfJMHfMQ',
      },
    );

    if (authResponse.statusCode == 200) {
      final authJson = json.decode(authResponse.body);
      final String token = authJson['generatedToken'];

      // 2. Consultando Transação
      Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading anterior
      await _showLoading(context, 'Consultando Transação...');
      final nsu = paymentResult.charge.nsu;
      final consultaUri =
          Uri.parse('https://authorizer-api-dev.aditum.com.br/v1/charge/$nsu');
      final consultaResponse = await http.get(
        consultaUri,
        headers: {
          'Authorization': 'Bearer $token',
          'x-aditum-source': '13',
        },
      );

      if (consultaResponse.statusCode == 200) {
        final consultaJson = json.decode(consultaResponse.body);
        final chargeQueryResult = ChargeQueryResult.fromJson(consultaJson);
        final chargeId = chargeQueryResult.id;

        // 3. Atualizando Recebedores
        Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading anterior
        await _showLoading(context, 'Atualizando Recebedores...');
        final cartState = Provider.of<CartState>(context, listen: false);
        final cart = cartState.cart;

        String generateRandomSku() {
          const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
          final rand = Random();
          return List.generate(8, (index) => chars[rand.nextInt(chars.length)]).join();
        }

        final products = cart.entries.map((entry) {
          return {
            "amount": (entry.key.price * 100).round(),
            "name": entry.key.name,
            "sku": generateRandomSku(),
            "merchantId": "25bc768c-77fc-436e-9d2a-8bdf24c1df31",
            "quantity": entry.value,
            "receivers": [
              {
                "id": "f49e87fa-4bcd-4da7-b58c-b000efb8d267",
                "percentageComission": 100
              }
            ]
          };
        }).toList();

        final uri = Uri.parse(
            'https://payment-dev.aditum.com.br/v2/charge/split/$chargeId');
        final putBody = {
          "products": products,
          "receivers": ["2400e608-c3d8-4a19-a78a-ecaf091e2ab6"]
        };

        await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(putBody),
        );
        Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading final
      } else {
        Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading se falhar
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading se falhar
    }
  }

  static Future<void> _showPaymentDialog(BuildContext context, PaymentResult paymentResult) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text(paymentResult.isApproved ? 'Sucesso' : 'Erro'),
            content: Text(paymentResult.isApproved
                ? 'Pagamento aprovado!'
                : 'Pagamento não aprovado!'),
            backgroundColor: paymentResult.isApproved ? Colors.green[50] : Colors.red[50],
            titleTextStyle: TextStyle(
              color: paymentResult.isApproved ? Colors.green[900] : Colors.red[900],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            contentTextStyle: TextStyle(
              color: paymentResult.isApproved ? Colors.green[900] : Colors.red[900],
              fontSize: 16,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (paymentResult.isApproved) {
        Provider.of<CartState>(context, listen: false).clear();
        // Retorna para a tela principal após limpar o carrinho
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = Provider.of<CartState>(context);
    final cart = cartState.cart;
    final total = cartState.total;

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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: cart.isNotEmpty
                    ? () => CartScreen.onPay(context, 'pay', total)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Finalizar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Classes de modelo
class Charge {
  final String acquirer;
  final String aid;
  final int amount;
  final String authorizationCode;
  final String authorizationResponseCode;
  final String brand;
  final String cardNumber;
  final String cardholderName;
  final List<String> cardholderReceipt;
  final String chargeStatus;
  final String creationDateTime;
  final int currency;
  final int installmentNumber;
  final String installmentType;
  final bool isApproved;
  final bool isCanceled;
  final String merchantChargeId;
  final List<String> merchantReceipt;
  final String nsu;
  final String origin;
  final String paymentType;
  final String transactionId;

  Charge({
    required this.acquirer,
    required this.aid,
    required this.amount,
    required this.authorizationCode,
    required this.authorizationResponseCode,
    required this.brand,
    required this.cardNumber,
    required this.cardholderName,
    required this.cardholderReceipt,
    required this.chargeStatus,
    required this.creationDateTime,
    required this.currency,
    required this.installmentNumber,
    required this.installmentType,
    required this.isApproved,
    required this.isCanceled,
    required this.merchantChargeId,
    required this.merchantReceipt,
    required this.nsu,
    required this.origin,
    required this.paymentType,
    required this.transactionId,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      acquirer: json['acquirer'] ?? '',
      aid: json['aid'] ?? '',
      amount: json['amount'] ?? 0,
      authorizationCode: json['authorizationCode'] ?? '',
      authorizationResponseCode: json['authorizationResponseCode'] ?? '',
      brand: json['brand'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
      cardholderReceipt: List<String>.from(json['cardholderReceipt'] ?? []),
      chargeStatus: json['chargeStatus'] ?? '',
      creationDateTime: json['creationDateTime'] ?? '',
      currency: json['currency'] ?? 0,
      installmentNumber: json['installmentNumber'] ?? 0,
      installmentType: json['installmentType'] ?? '',
      isApproved: json['isApproved'] ?? false,
      isCanceled: json['isCanceled'] ?? false,
      merchantChargeId: json['merchantChargeId'] ?? '',
      merchantReceipt: List<String>.from(json['merchantReceipt'] ?? []),
      nsu: json['nsu'] ?? '',
      origin: json['origin'] ?? '',
      paymentType: json['paymentType'] ?? '',
      transactionId: json['transactionId'] ?? '',
    );
  }
}

class PaymentResult {
  final Charge charge;
  final bool isApproved;

  PaymentResult({required this.charge, required this.isApproved});

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      charge: Charge.fromJson(json['charge'] ?? {}),
      isApproved: json['isApproved'] ?? false,
    );
  }
}

class ChargeQueryResult {
  final String id;

  ChargeQueryResult({required this.id});

  factory ChargeQueryResult.fromJson(Map<String, dynamic> json) {
    return ChargeQueryResult(
      id: json['charge']?['id'] ?? '',
    );
  }
}