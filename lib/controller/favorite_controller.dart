import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Modal/product_model.dart';

class FavoriteController extends GetxController {
  final List<Product> _favorites = <Product>[].obs;

  List<Product> get favorites => _favorites;

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String?  userId = prefs.getString('UserID');
      if (userId != null) {
        final url = 'https://jaatconnect.online/displaywishlist.php';
        final response = await http.post(
          Uri.parse(url),
          body: {'userid': userId},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success' && data['products'] is List) {
            _favorites.clear();
            _favorites.addAll(
              (data['products'] as List).map((item) {
                print('Fav ID String: ${item['id']}');
                print('Fav image String: ${item['image_url']}');
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
                  quantity: 0,
                );
              }).toList(),
            );
          } else {
            throw Exception('Failed to fetch favorite products');
          }
        } else {
          throw Exception('Failed to fetch favorite products');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error fetching favorite products: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      if (userId != null) {
        final url = 'https://jaatconnect.online/wishlist.php';
        final response = await http.post(
          Uri.parse(url),
          body: {'Pid': product.id.toString(), 'userid': userId},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            if (data['message'] == 'Product successfully added to wishlist') {
              _favorites.add(product);
            } else if (data['message'] == 'Product removed from wishlist') {
              _favorites.remove(product);
            } else {
              throw Exception('Unexpected message: ${data['message']}');
            }
          } else {
            throw Exception('Operation failed: ${data['message']}');
          }
        } else {
          throw Exception('Failed to toggle favorite: ${response.statusCode}');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  bool isExist(Product product) {
    return _favorites.any((fav) => fav.id == product.id);
  }

  void clearFavorites() {
    _favorites.clear();
  }

  static FavoriteController get to => Get.find();
}
