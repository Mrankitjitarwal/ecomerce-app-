import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../../Modal/product_model.dart';
import 'deleverystatus.dart';

class OrdersPage extends StatefulWidget {
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<List<Order>>? futureOrders;

  Future<List<Order>> fetchRecentOrders() async {
    const String serverUrl = 'https://jaatconnect.online/recentproducts.php';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          'fetch_orders': 'true',
          'userid': userId,
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          List orders = result['orders'];
          return orders.map<Order>((json) => Order.fromJson(json)).toList();
        } else {
          throw Exception('Failed to fetch orders: ${result['message']}');
        }
      } else {
        throw Exception('Failed to fetch orders with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    futureOrders = fetchRecentOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Orders'),
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching orders: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          } else {
            final orders = snapshot.data!;
            return  ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildRecentOrderItem(order);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildRecentOrderItem(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeliveryStatus(order: order),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: kcontentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  order.productImage,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    order.paymentStatus,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${order.amount}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Order {
  final String orderId;
  final String username;
  final String date;
  final String paymentStatus;
  final int productId;
  final String productName;
  final double amount;
  final String productImage;

  Order({
    required this.orderId,
    required this.username,
    required this.date,
    required this.paymentStatus,
    required this.productId,
    required this.productName,
    required this.amount,
    required this.productImage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'https://jaatconnect.online/';
    return Order(
      orderId: json['order_id'].toString(), // Ensure orderId is parsed as a String
      username: json['username'],
      date: json['date'],
      paymentStatus: json['payment_status'],
      productId: json['product_id'],
      productName: json['product_name'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      productImage: baseUrl + (json['product_image'] ?? ''),
    );
  }

}
