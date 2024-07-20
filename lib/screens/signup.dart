import 'dart:convert';
import 'package:ecomerce/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PasswordController1 extends GetxController {
  var obscureText = true.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }
}

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  var password = TextEditingController();
  final passwordController1 = Get.put(PasswordController1());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> Signup() async {
    final String apiUrl = 'https://jaatconnect.online/register.php';
    final response = await http.post(Uri.parse(apiUrl), body: {
      'username': usernameController.text,
      'email': emailController.text,
      'password': password.text,
    });

    if (response.statusCode == 200) {
      try {
        // Debugging step: print the raw response body
        print('Response body: ${response.body}');

        // Clean up the response body to extract the JSON part
        String jsonStr = response.body;
        int jsonStartIndex = jsonStr.indexOf('{');
        if (jsonStartIndex != -1) {
          jsonStr = jsonStr.substring(jsonStartIndex);
        }

        Map<String, dynamic> jsonmap = json.decode(jsonStr);
        if (jsonmap['status'] == 'success') {
          Get.snackbar('Msg', 'Registered Successfully');
          // Navigate to the login page after successful registration
          Get.to(() => LoginPage());
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
                  gradient: LinearGradient(colors: [
                    Color(0xFF000000),
                    Color(0xFF3533CD),
                  ])),
              child: Padding(
                padding: EdgeInsets.only(top: 30, left: 15),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 100, left: 15),
              child: Text(
                'Create an account to get started',
                style: TextStyle(fontSize: 19, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 210),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40)),
                    color: Colors.white),
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 80, left: 10, right: 10),
                    child: Column(
                      children: [
                        TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_circle),
                              suffixIcon: Icon(
                                Icons.check,
                                color: Colors.grey,
                              ),
                              label: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            suffixIcon: Icon(
                              Icons.mail,
                            ),
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(height: 20),
                        Obx(() => TextFormField(
                          controller: password,
                          obscureText: passwordController1.obscureText.value,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordController1.obscureText.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: passwordController1.toggleObscureText,
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
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF000000),
                                Color(0xFF3533CD),
                              ],
                            ),
                          ),
                          child: Center(
                            child: TextButton(
                              onPressed: Signup,
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Get.to(() => LoginPage());
                                  },
                                  child: Text(
                                    "Already have an account?\nLog In ",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 51, 51, 205),
                                        fontSize: 13),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}