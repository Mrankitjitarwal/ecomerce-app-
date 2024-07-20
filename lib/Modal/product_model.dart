import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String title;
  final String description;
  final String image;
  final String review;
  final String seller;
  final double price;
  final String category;
  final double rate;
  int quantity;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.review,
    required this.seller,
    required this.price,
    required this.category,
    required this.rate,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'https://jaatconnect.online/'; // Base URL for images
    return Product(
      id: int.parse(json['id'].toString()),
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      image: baseUrl + (json['image_url'] ?? ''), // Complete image URL
      review: json['review'] ?? '',
      seller: json['seller'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      category: json['category'] ?? '',
      rate: double.tryParse(json['rate'].toString()) ?? 0.0,
      quantity: int.parse(json['quantity'].toString()),
    );
  }
}

// Define a global list to store the products
List<Product> all = [];
List<Product> shoes = [];
List<Product> beauty = [];
List<Product> womenFashion = [];
List<Product> jewelry = [];
List<Product> menFashion = [];

Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://jaatconnect.online/displayproduct.php'));

  if (response.statusCode == 200) {
    final List<dynamic> productsJson = jsonDecode(response.body);

    List<Product> products = productsJson.map((json) {
      return Product.fromJson(json);
    }).toList();

    // Store the products in the global list
    all = products;

    print('Fetched products: ${all.length}'); // Log the number of fetched products

    return products;
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<Product>> fetchProductsByCategory(String category) async {
  final response = await http.post(
    Uri.parse('https://jaatconnect.online/displaycategory.php'),
    body: {
      'category': category,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseJson = jsonDecode(response.body);
    if (responseJson['status'] == 'success') {
      final List<dynamic> productsJson = responseJson['products'];
      List<Product> products = productsJson.map((json) {
        return Product.fromJson(json);
      }).toList();

      // Log to check the fetched products
      print('Fetched ${products.length} products for category $category');

      return products;
    } else {
      throw Exception(responseJson['message']);
    }
  } else {
    throw Exception('Failed to load products');
  }
}
