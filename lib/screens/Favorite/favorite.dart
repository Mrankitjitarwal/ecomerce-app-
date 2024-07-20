import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Modal/product_model.dart';
import '../../constants.dart';
import '../../controller/favorite_controller.dart';
import '../Detail/detail_screen.dart';
import '../Home/Widget/CustomAppBAr.dart';
import '../nav_bar_screen.dart';


class Favorite extends StatefulWidget {
  const Favorite({Key? key}) : super(key: key);

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  @override
  void initState() {
    super.initState();
    // Defer the state changes to avoid calling during the build phase
    Future.delayed(Duration.zero, () {
      FavoriteController.to.fetchFavoriteProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Favorite",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavBar(),
              ),
            );
          },
        ),
      ),
      body: Obx(() {
        final favorites = FavoriteController.to.favorites;
        if (favorites.isEmpty) {
          // Show a message or placeholder when there are no favorite products
          return Center(
            child: Text(
              'No favorite products found.',
              style: const TextStyle(fontSize: 18),
            ),
          );
        } else {
          // Show the list of favorite products
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favoritItem = favorites[index];
              return _buildFavoriteItem(favoritItem);
            },
          );
        }
      }),
    );
  }

  Widget _buildFavoriteItem(Product favoritItem) {
    return GestureDetector(

      onTap: () {
        // Navigate to the product detail page here
        // You can pass the product data to the detail page if needed
        Get.to(() => DetailScreen(product: favoritItem));
      },
      child: Stack(
        children: [
          Padding(
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
                      favoritItem.image,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favoritItem.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        favoritItem.category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "\$${favoritItem.price}",
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
          Positioned(
            top: 50,
            right: 40,
            child: GestureDetector(
              onTap: () {
                // Toggle favorite status when delete icon is tapped
                FavoriteController.to.toggleFavorite(favoritItem);
              },
              child: const Icon(
                Icons.delete,
                color: Colors.red,
                size: 25,
              ),
            ),
          )
        ],
      ),
    );
  }
}
