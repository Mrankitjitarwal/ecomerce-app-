import 'package:ecomerce/screens/Privacyhelpetc/Terms_&_condition.dart';
import 'package:ecomerce/screens/Privacyhelpetc/privacy%20&%20policy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controller/cart_controller.dart';
import '../../../controller/favorite_controller.dart';
import '../../Cart/orderpage.dart';
import '../../Privacyhelpetc/help&support.dart';
import '../../WelcomeScreen.dart';
import 'accountdetail.dart';
import 'components/profile_menu.dart';
import 'components/profile_pic.dart';


class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: "images/icons/User Icon.svg",
              press: () => {
                Get.to(AccountDetailPage())
              },
            ),ProfileMenu(
              text: "Order history",
              icon: "images/icons/Cart Icon.svg",
              press: () => {
                Get.to(OrdersPage())
              },
            ),
            ProfileMenu(
              text: "PrivacyPolicy",
              icon: "images/icons/privacy-policy-icon.svg",
              press: () {
                Get.to(PrivacyPolicyPage());
              },
            ),
            ProfileMenu(
              text: "Terms & Conditions",
              icon: "images/icons/agreement-terms-icon.svg",
              press: () {
                Get.to(TermsConditionsPage());
              },
            ),
            ProfileMenu(
              text: "Help Center",
              icon: "images/icons/Question mark.svg",
              press: () {
                Get.to(HelpAndSupportPage());
              },
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "images/icons/Log out.svg",
              press: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLoggedIn', false); // Set the logged in flag to false
                await prefs.remove('name');
                await prefs.remove('email');
                await prefs.remove('userid');
                FavoriteController.to.clearFavorites();
                CartController.to.clearCart();

                Get.to(() => WelcomeScreen());
                Get.snackbar('Logout success', 'Logout successfully');
              },
            ),
          ],
        ),
      ),
    );
  }

}
