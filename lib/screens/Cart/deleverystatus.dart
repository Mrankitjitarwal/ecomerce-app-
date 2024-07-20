import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'orderpage.dart';

class DeliveryStatus extends StatefulWidget {
  final Order order;

  const DeliveryStatus({Key? key, required this.order}) : super(key: key);

  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  String _deliveryStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchDeliveryStatus();
  }

  Future<void> _fetchDeliveryStatus() async {
    try {
      final response = await http.post(
        Uri.parse('https://jaatconnect.online/fetch_delivery_status.php'), // Replace with your API endpoint
        body: jsonEncode({
          'order_id': widget.order.orderId, // Pass the order ID to fetch delivery status
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _deliveryStatus = data['delivery_status']; // Issue might be here
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to fetch delivery status');
      }
    } catch (e) {
      print('Error fetching delivery status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentStep = _getCurrentStep(_deliveryStatus);

    List<Step> steps = [
      Step(
        title: Text('Ordered'),
        content: Text('Your order has been placed.'),
        isActive: currentStep >= 0,
      ),
      Step(
        title: Text('Shipped'),
        content: Text('Your order is on the way.'),
        isActive: currentStep >= 1,
      ),
      Step(
        title: Text('Delivered'),
        content: Text('Your order has been delivered.'),
        isActive: currentStep >= 2,
        state: currentStep >= 2 ? StepState.complete : StepState.indexed,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.order.productImage),
              SizedBox(height: 16),
              Text(
                widget.order.productName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "\$${widget.order.amount}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Order Status: $_deliveryStatus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Stepper(
                currentStep: currentStep,
                steps: steps,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return 0;
      case 'shipped':
        return 1;
      case 'delivered':
        return 2;
      default:
        return 0;
    }
  }
}
