import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Modal/product_model.dart';

class CartController extends GetxController {
  final List<Product> _cart = <Product>[].obs;
  List<Product> get cart => _cart.toList();


  Future<void> fetchCartProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      if (userId != null) {
        final url = 'https://jaatconnect.online/displaycart.php';
        final response = await http.post(
          Uri.parse(url),
          body: {'userid': userId},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            if (data['products'] is List) {
              _cart.clear();
              _cart.addAll(
                (data['products'] as List).map((item) {
                  print('cart ID String: ${item['id']}');
                  print('cart image String: ${item['image_url']}');
                  return Product(
                    id: int.parse(item['id'].toString()),
                    title: item['name'],
                    image: 'https://jaatconnect.online/${item['image_url']}',
                    price: double.parse(item['price'].toString()),
                    category: item['category'],
                    description: '',
                    review: '',
                    seller: '',
                    rate: 0,
                    quantity: int.parse(item['quantity'].toString()),
                  );
                }).toList(),
              );
            } else {
              _cart.clear(); // Clear cart if no products are found
              print('No products found in the cart.');
            }
          } else if (data['message'] == 'No cart items found for the user') {
            _cart.clear(); // Clear cart if no products are found
            print('No products found in the cart.');
          } else {
            throw Exception('Failed to fetch cart products: ${data['message']}');
          }
        } else {
          throw Exception('Failed to fetch cart products: ${response.statusCode}');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error fetching cart products: $e');
    }
  }



  Future<void> addToCart(Product product, int quantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      if (userId != null) {
        final url = 'https://jaatconnect.online/addtocart.php';
        final response = await http.post(
          Uri.parse(url),
          body: {
            'userid': userId,
            'Pid': product.id.toString(),
            'Quan': quantity.toString(),
            'action': 'add'
          },
        );
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final message = responseData['message']; // Extract the message from response data
          if (message == 'Product successfully added to cart') {
            fetchCartProducts(); // Fetch the updated cart after adding
            showSnackBar("Successfully added!");
          } else if (message == 'Product already added to cart') {
            showSnackBar("Already added!");
          } else {
            print(message); // Print the actual message received from the server
          }
        } else {
          print('Failed to add product to cart: ${response.statusCode}');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error adding product to cart: $e');
    }
    update();
  }

  Future<void> removeFromCart(Product product) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      if (userId != null) {
        final url = 'https://jaatconnect.online/addtocart.php'; // Using the same endpoint
        final response = await http.post(
          Uri.parse(url),
          body: {
            'userid': userId,
            'Pid': product.id.toString(),
            'action': 'remove'
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            // Fetch updated cart products after removing the product
            fetchCartProducts();
          } else {
            throw Exception('Operation failed: ${data['message']}');
          }
        } else {
          throw Exception('Failed to remove product: ${response.statusCode}');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error removing product: $e');
      rethrow;
    }
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.white,
        ),
      ),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }

  void clearCart() {
    _cart.clear();
  }

  static CartController get to => Get.find();

  void incrementQuantity(int index) {
    _cart[index].quantity++;
    update(); // Notify UI about the quantity change
  }

  void decrementQuantity(int index) {
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
      update(); // Notify UI about the quantity change
    }
  }

  double totalPrice() {
    double total = 0.0;
    for (Product element in _cart) {
      total += element.price * element.quantity;
    }
    return total;
  }
}
