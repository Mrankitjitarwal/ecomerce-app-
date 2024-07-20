import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Modal/product_model.dart';
import '../../../controller/favorite_controller.dart';

class DetailAppBar extends StatelessWidget {
  final Product product;
  const DetailAppBar({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final FavoriteController controller = Get.put(FavoriteController());

    final isFavorite = controller.isExist(product).obs;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(15),
            ),
            onPressed: () {

              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          const Spacer(),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(15),
            ),
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 10),
          Obx(() {
            return IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () {
                // Toggle the favorite status
                controller.toggleFavorite(product);
                // Update isFavorite after toggling
                isFavorite.value = controller.isExist(product);
              },
              icon: Icon(
                // Use the value of isFavorite for the icon
                isFavorite.value ? Icons.favorite : Icons.favorite_outline,
                color: Colors.black,
                size: 22,
              ),
            );
          }),
        ],
      ),
    );
  }
}
