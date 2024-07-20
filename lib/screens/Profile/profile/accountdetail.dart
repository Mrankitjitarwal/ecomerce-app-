import 'dart:convert';
import 'package:ecomerce/screens/Profile/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';


class AccountDetailPage extends StatefulWidget {

  const AccountDetailPage({Key? key,}) : super(key: key);

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  var username;
  var email;
  var phoneNumber;

  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('UserID');
    setState(() {
      isLoading = true;
    });

    String apiUrl = 'https://jaatconnect.online/userdetail.php?userId=${userId}';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var userData = jsonDecode(response.body);

        setState(() {
          username = userData['username'];
          email = userData['email'];
          phoneNumber = userData['phone_number'];

          usernameController.text = username;
          phoneNumberController.text = phoneNumber;
        });
      } else {
        print('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateUserDetails() async {
    String apiUrl = 'https://jaatconnect.online/userdetail.php';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('UserID');

    var data = {
      "userId": userId,
      "username": usernameController.text,
      "phoneNumber": phoneNumberController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print(responseData['message']); // Print success message
        setState(() {
          username = usernameController.text;
          phoneNumber = phoneNumberController.text;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details updated successfully')),
        );
      } else {
        print('Failed to update user details. Server returned status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error updating user details: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Account Detail",
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
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Username:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(

                hintText: 'Enter username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              email ?? 'Loading...', // Handle null case with 'Loading...'
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Phone Number:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    updateUserDetails();
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}