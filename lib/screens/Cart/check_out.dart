import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../controller/cart_controller.dart';

import 'adresspage.dart';

class CheckOutBox extends StatefulWidget {
  const CheckOutBox({Key? key}) : super(key: key);

  @override
  _CheckOutBoxState createState() => _CheckOutBoxState();
}

class _CheckOutBoxState extends State<CheckOutBox> {
  static const String serverUrl =
      'https://jaatconnect.online/payment_process.php';
  final cart = Get.find<CartController>();

  late Razorpay _razorpay;
  final TextEditingController _discountCodeController = TextEditingController();
  double _discount = 0;

  String _loggedInUserEmail = ''; // To store logged-in user's email
  String _phoneNumberFromAddress =
      ''; // To store phone number from address page

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _getUserEmail(); // Fetch logged-in user's email on initialization
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('emailid');
    setState(() {
      _loggedInUserEmail = userEmail ?? '';
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "SUCCESS PAYMENT: ${response.paymentId}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR handle: ${response.code} - ${response.message}",
      timeInSecForIosWeb: 4,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "EXTERNAL_WALLET: ${response.walletName}",
      timeInSecForIosWeb: 4,
    );
  }

  Future<void> _applyDiscountCode() async {
    final code = _discountCodeController.text.trim();
    if (code.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a discount code",
        timeInSecForIosWeb: 4,
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://jaatconnect.online/discount.php?discount_code=$code'));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            _discount =
                (cart.totalPrice() * result['discount_percentage'] / 100);
          });
          Fluttertoast.showToast(
            msg: "Discount code applied successfully!",
            timeInSecForIosWeb: 4,
          );
        } else {
          Fluttertoast.showToast(
            msg: result['message'],
            timeInSecForIosWeb: 4,
          );
        }
      } else {
        throw Exception('Failed to validate discount code');
      }
    } catch (e) {
      print('Error validating discount code: $e');
      Fluttertoast.showToast(
        msg: "Failed to validate discount code",
        timeInSecForIosWeb: 4,
      );
    }
  }

  Future<void> _createOrder(String address, String phoneNumber) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      print("userid is: $userId");
      if (userId == null || userId.isEmpty) {
        throw Exception('UserID not found in SharedPreferences');
      }

      final requestBody = {
        'amt': (cart.totalPrice() - _discount).toString(),
        'userid': userId,
        'address': address,
        'phone_number': phoneNumber,
        'payment_status': 'success', // Added payment status parameter
        'product_ids': cart.cart
            .map((product) => {'id': product.id, 'quantity': product.quantity})
            .toList(),
      };


      print("Request body: ${json.encode(requestBody)}");

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(requestBody),
      );

      print("Server response: ${response.body}");

      if (response.statusCode == 200) {
        final order = jsonDecode(response.body);
        if (order['status'] == 'success') {
          String orderId = order['order_id'].toString();
          _openCheckout(orderId, (cart.totalPrice() - _discount).toString(), phoneNumber);
          cart.clearCart();
        } else {
          throw Exception('Failed to create order: ${order['message']}');
        }
      } else {
        throw Exception('Failed to create order: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating order: $e');
      Fluttertoast.showToast(
        msg: "Failed to create order: $e",
        timeInSecForIosWeb: 4,
      );
    }
  }
  void _openCheckout(String orderId, String amount, String phoneNumber) {
    double parsedAmount = double.parse(amount);
    int roundedAmount = parsedAmount.round();

    var options = {
      'key': 'rzp_test_bq6lKsqM0YZXgU', // Replace with your Razorpay key ID
      'amount': (roundedAmount * 100).toString(),
      'name': 'Dmart',
      'description': 'Payment for some random product',
      'prefill': {
        'contact': phoneNumber,
        'email': _loggedInUserEmail, // Use logged-in user's email
      },
      'order ID': orderId, // Corrected key from 'order ID' to 'order_id'
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _discountCodeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
                filled: true,
                fillColor: kcontentColor,
                hintText: "Enter Discount Code",
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                suffixIcon: TextButton(
                  onPressed: _applyDiscountCode,
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                      color: kprimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "\$${cart.totalPrice()}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            if (_discount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Discount",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "- \$$_discount",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${cart.totalPrice() - _discount}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (cart.cart.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Cart is empty",
                    timeInSecForIosWeb: 4,
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressPage(
                      onAddressSubmit: (address, phoneNumber) {
                        setState(() {
                          _phoneNumberFromAddress = phoneNumber;
                        });
                        _createOrder(address, phoneNumber);
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "Check out",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
