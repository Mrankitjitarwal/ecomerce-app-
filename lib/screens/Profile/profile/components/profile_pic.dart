import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreenController extends GetxController {
  var image = Rx<String?>(null); // Use Rx for observability

  @override
  void onInit() {
    super.onInit();
    // Initialize the profile image when the controller is created
    _loadProfileImage();
  }

  void updateImagePath(String imagePath) {
    image.value = imagePath; // Update the observable variable
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedImagePath = prefs.getString('ProfileImage'); // Load the stored image path
    if (storedImagePath != null && storedImagePath.isNotEmpty) {
      updateImagePath(storedImagePath);
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    try {
      final uri = Uri.parse('https://jaatconnect.online/profilepic.php');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('UserID');
      if (userId == null) {
        print('User ID is not available');
        return;
      }

      final request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId // Add the user ID
        ..files.add(await http.MultipartFile.fromPath('profile_pic', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        if (responseBody.isNotEmpty) {
          updateImagePath(responseBody); // Update the observable variable
          // Store the image path in SharedPreferences
          prefs.setString('ProfileImage', responseBody);
        } else {
          print('Server response is empty');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
    }
  }

}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileScreenController profileScreenController = Get.find<ProfileScreenController>();

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Obx(() {
          final image = profileScreenController.image.value; // Access observable value
          print('Image URL: $image'); // Debug log
          return CircleAvatar(
            backgroundImage: image != null && image.isNotEmpty
                ? NetworkImage(image) // Use NetworkImage to load the image from URL
                : AssetImage("images/all/g.jpeg") as ImageProvider,
          );
        }),

          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {
                  _showBottomSheet(context);
                },
                child: SvgPicture.asset("images/icons/Camera Icon.svg"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    final ProfileScreenController profileScreenController = Get.find<ProfileScreenController>();
    final mq = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: mq.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      final file = File(image.path);
                      await profileScreenController.uploadProfilePicture(file);
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/add_image.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      final file = File(image.path);
                      await profileScreenController.uploadProfilePicture(file);
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('images/camera.png'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
