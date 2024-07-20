import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../controller/cart_controller.dart';


class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  static const String serverUrl = 'https://api.ekinvest.in/payment_process.php';
  final cart = Get.find<CartController>();
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Successful: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Error: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("External Wallet Selected: ${response.walletName}");
  }

  Future<void> _createOrder() async {
    final response = await http.post(Uri.parse(serverUrl));
    if (response.statusCode == 200) {
      final order = jsonDecode(response.body);
      _openCheckout(order['id'], order['amount']);
    } else {
      throw Exception('Failed to create order');
    }
  }

  void _openCheckout(String orderId, int amount) {
    var options = {
      'key': 'rzp_test_bq6lKsqM0YZXgU',
      'amount': "\$${cart.totalPrice()}",
      'name': 'Your App Name',
      'order_id': orderId,
      'description': 'Payment for the product',
      'prefill': {
        'contact': '918233997352',
        'email': 'jjat3335@example.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _createOrder,
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
