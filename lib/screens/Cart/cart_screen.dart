import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Modal/product_model.dart';
import '../../constants.dart';
import '../../controller/cart_controller.dart';
import '../nav_bar_screen.dart';
import 'check_out.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = Get.put(CartController(), permanent: true);

  @override
  void initState() {
    super.initState();
    // Defer the state changes to avoid calling during the build phase
    Future.delayed(Duration.zero, () {
      _cartController.fetchCartProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
        bottomSheet: _cartController.cart.isEmpty ? null : CheckOutBox(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavBar(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const Text(
                    "My Cart",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final List<Product> finalList = _cartController.cart;
                if (finalList.isEmpty) {
                  return Center(
                    child: Text(
                      'No product in your cart',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: finalList.length,
                          itemBuilder: (context, index) {
                            final Product cartItems = finalList[index];
                            return _buildCartItem(cartItems, index);
                          },
                        ),
                      ),
                      SizedBox(height: 300), // Adjust height according to your bottom sheet content
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Product product, int index) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 100,
                  width: 90,
                  decoration: BoxDecoration(
                    color: kcontentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    product.image,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${product.price}",
                      style: const TextStyle(
                        fontSize: 14,
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
          top: 35,
          right: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  _cartController.removeFromCart(product);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: kcontentColor,
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    _productQuantity(Icons.add, index),
                    const SizedBox(width: 10),
                    Text(
                      product.quantity.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _productQuantity(Icons.remove, index),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _productQuantity(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          icon == Icons.add
              ? _cartController.incrementQuantity(index)
              : _cartController.decrementQuantity(index);
        });
      },
      child: Icon(
        icon,
        size: 20,
      ),
    );
  }
}
