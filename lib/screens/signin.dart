import 'dart:convert';

import 'package:ecomerce/controller/favorite_controller.dart';
import 'package:ecomerce/screens/Home/home_screen.dart';
import 'package:ecomerce/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'forgot_password/forgot_password_screen.dart';
import 'nav_bar_screen.dart';

class PasswordController extends GetxController {
  var obscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key});

  final email = TextEditingController();
  var password = TextEditingController();

  final PasswordController passwordController = Get.put(PasswordController());

  Future<void> login() async {
    final String apiUrl = 'https://jaatconnect.online/login.php';
    final response = await http.post(Uri.parse(apiUrl), body: {
      'email': email.text,
      'password': password.text,
    });

    if (response.statusCode == 200) {
      try {
        // Debugging step: print the raw response body
        print('Response body: ${response.body}');

        // Decode the JSON response directly
        Map<String, dynamic> jsonmap = json.decode(response.body);

        if (jsonmap['status'] == 'success') {
          String? userId = jsonmap['userid'];
          String username = jsonmap['username'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true); // Set the logged in flag to true
          prefs.setString('emailid', email.text);
          prefs.setString('UserID', userId ?? ''); // Handle nullable properly
          prefs.setString('Username', username);

          Get.snackbar('Msg', 'Login Successfully');
          // Navigate to the main page after successful login
          Get.to(() => BottomNavBar());
        } else {
          Get.snackbar('Msg', jsonmap['message']);
        }
      } catch (e) {
        // More detailed error logging
        print('Error parsing JSON: $e');
        Get.snackbar('Msg', 'Server Error: $e');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      Get.snackbar('Message', 'Invalid Information filled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color(0xFF000000), Color(0xFF3533CD),
                    ]
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 30, left: 15),
                child: Text(
                  'Log in',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 100, left: 15),
              child: Text(
                'Hey there! Welcome back',
                style: TextStyle(
                    fontSize: 19,
                    color: Colors.white
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 230),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)
                    ),
                    color: Colors.white
                ),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80, left: 10, right: 10),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: email,
                          decoration: InputDecoration(
                            focusColor: Colors.red,
                            fillColor: Colors.black,
                            prefixIcon: Icon(Icons.mail),
                            suffixIcon: Icon(Icons.mail, color: Colors.grey,),
                            label: Text(
                              'Email', style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == 0) {
                              return "Please Enter The Email ID";
                            }
                            String emailValue = value.toString(); // Convert to string if necessary
                            bool emailValid = RegExp(r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailValue);
                            if (emailValue.isEmpty) {
                              return "Please Enter The Email ID";
                            } else if (!emailValid) {
                              return "Please Enter Valid Email ID";
                            }
                            return null; // Return null if validation passes
                          },
                        ),
                        const SizedBox(height: 20,),
                        const SizedBox(height: 20),
                        Obx(() =>
                            TextFormField(
                              controller: password,
                              obscureText: passwordController.obscureText.value,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordController.obscureText.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: passwordController.toggleObscureText,
                                ),
                                label: Text(
                                  'Password',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )),
                        SizedBox(height: 20,),
                        InkWell(
                          onTap: login,
                          child: Container(
                            height: 50,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF000000), Color(0xFF3533CD),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text('Log In', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white
                              ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 700,),
            Align(
              alignment: Alignment.bottomLeft,
              child:
              Padding(
                padding: const EdgeInsets.only(top: 530),
                child: Column(
                  children: [
                    TextButton(onPressed: () {
                      Get.to(ForgotPasswordScreen());
                    }, child: const Text("Forget Password", style: TextStyle(
                        color:kColor,
                        fontSize: 13
                    ),))
                  ],
                ),
              ),
            ),
            //SizedBox(height: 800,),

            Align(
              alignment: Alignment.bottomRight,
              child:
              Padding(
                padding: const EdgeInsets.only(top: 530),
                child: Column(
                  children: [
                    TextButton(onPressed: () {
                      Get.to(SignupPage());
                    }, child: const Text("Don't have account?\nSign Up ", style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 13
                    ),))
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}
