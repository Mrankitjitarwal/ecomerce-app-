import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Modal/product_model.dart';
import '../../../constants.dart';
import '../../../controller/favorite_controller.dart';
import '../../Detail/detail_screen.dart';
import 'SkeletonLoader.dart'; // Import the skeleton loader widget

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FavoriteController controller = Get.find<FavoriteController>();

    return GestureDetector(
      onTap: () {
        Get.to(() => DetailScreen(product: product));
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kcontentColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Center(
                  child: Hero(
                    tag: product.image,
                    child: Image.network(
                      product.image,
                      width: 150,
                      height: 150,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error, size: 150);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SkeletonLoader(); // Use the skeleton loader here
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "\$${product.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  // Toggle the favorite status
                  await controller.toggleFavorite(product);
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Obx(() {
                    // Use Obx to rebuild the icon when the favorite status changes
                    final isFavorite = controller.isExist(product);
                    return Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: Colors.white,
                      size: 22,
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
