import 'package:ecomerce/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';



class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don’t have an account? ",
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: () => Get.to(SignupPage()),
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 16, color: kColor),
          ),
        ),
      ],
    );
  }
}
