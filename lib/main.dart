import 'dart:ui';
import 'package:ecomerce/controller/cart_controller.dart';
import 'package:ecomerce/controller/favorite_controller.dart';
import 'package:ecomerce/screens/Profile/profile/components/profile_pic.dart';
import 'package:ecomerce/screens/Splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final FavoriteController favoriteController = Get.put(FavoriteController());
    final CartController cartController = Get.put(CartController());
    Get.put(ProfileScreenController());

    // Fetch favorite products
    favoriteController.fetchFavoriteProducts();
    cartController.fetchCartProducts();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.mulishTextTheme(),
      ),
      home: Splash(),
      initialBinding: BindingsBuilder(() {
        Get.put<CartController>(CartController());
        Get.put<FavoriteController>(FavoriteController());
      }),
    );
  }
}
