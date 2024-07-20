import 'package:ecomerce/screens/WelcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nav_bar_screen.dart';

class Controller extends GetxController {
  bool islogedin = false;

  initSharedPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    islogedin = preferences.getBool('isLoggedIn') ?? false;
    update(); // Notify listeners of the change
  }

  @override
  void onInit() {
    super.onInit();
    initSharedPrefs();
  }

  void navigate() async {
    await Future.delayed(
      const Duration(seconds: 4),
          () => Get.offAll(() => islogedin ? const BottomNavBar() : const WelcomeScreen()),
    );
  }
}

class Splash extends StatelessWidget {
  Splash({super.key});

  final Controller c1 = Get.put(Controller(), permanent: true);

  @override
  Widget build(BuildContext context) {
    // Call the navigate method to initiate navigation after a delay
    c1.navigate();

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF3533CD)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/M.gif'),fit: BoxFit.fill
                  ),
                ),
              ),
            ),
            const Text(
              'Online Shopping Mart',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
