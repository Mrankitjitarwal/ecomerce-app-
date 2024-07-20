/*
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class Phonepaypayment extends StatefulWidget {
  const Phonepaypayment({super.key});

  @override
  State<Phonepaypayment> createState() => _PhonepaypaymentState();
}

class _PhonepaypaymentState extends State<Phonepaypayment> {
  String environment = "UAT_SIM";
  String appId = "";
  String merchantId = "PGTESTPAYUAT";
  bool enableLogging = true;

  String checksum = "";
  String saltkey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String saltIndex = "1";
  String callbackUrl =
      "https://webhook.site/f63d1195-f001-474d-acaa-f7bc4f3bc4f3b20b1";
  String body = "";
  String apiEndPoint = "/pg/v1/pay";
  Object? result;

  getChecksum() {
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": 10000,
      "callbackUrl": callbackUrl,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };
    String base64body = base64Encode(utf8.encode(jsonEncode(requestData)));
    checksum='${sha256.convert(utf8.encode(base64body+apiEndPoint+saltkey)).toString()}### + $saltIndex';
    return base64body;
  }

  @override
  void initState() {
    super.initState();
    PhonePayInit();
    body=getChecksum().toString();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  void PhonePayInit() {
    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }

  void handleError(error) {
    setState(() {
      result = {"error": error};
    });
  }

  void startPgTransaction() async {
    try {
      var response =
          PhonePePaymentSdk.startTransaction(body, callbackUrl, checksum, "");
      response
          .then((val) => {
                setState(() {
                  if (val != null) {
                    String status = val['status'].toString();
                    String error = val['error'].toString();
                    if (status == "SUCCESS") {
                      result = "Flow Compelete - status : SUCCESS";
                    } else {
                      result =
                          "Flow Compelete - status : $status and error $error";
                    }
                  } else {
                    result = "Flow Incomplete";
                  }
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }
}
*/
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

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
    _razorpay.clear(); // Removes all listeners
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_bq6lKsqM0YZXgU', // Replace with your Razorpay key ID
      'amount': 100, // Amount in paise
      'name': 'Your Company Name',
      'description': 'Payment for some random product',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@razorpay.com',
      },
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    // Do something when an external wallet is selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment Gateway'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          child: Text('Pay with Razorpay'),
        ),
      ),
    );
  }
}
