import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants.dart';

class AddressPage extends StatefulWidget {
  final Function(String address, String phoneNumber) onAddressSubmit;

  const AddressPage({Key? key, required this.onAddressSubmit}) : super(key: key);

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentAddressFromPrefs();
  }

  Future<void> _loadCurrentAddressFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentAddress = prefs.getString('current_address');
    String? phoneNumber = prefs.getString('phone_number');
    if (currentAddress != null) {
      setState(() {
        _addressController.text = currentAddress;
        _phoneNumberController.text = phoneNumber ?? '';
      });
    }
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    try {
      Position position =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
        setState(() {
          _addressController.text = address;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('current_address', address);
        Fluttertoast.showToast(msg: 'Current address loaded');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get location: $e');
    }
  }

  Future<void> _submitAddress() async {
    String address = _addressController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    if (address.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter an address",
        timeInSecForIosWeb: 4,
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a phone number",
        timeInSecForIosWeb: 4,
      );
      return;
    }

    widget.onAddressSubmit(address, phoneNumber);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('current_address', address);
    prefs.setString('phone_number', phoneNumber);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Address"),
        backgroundColor: kprimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter your address",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Enter your phone number",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text("Use Current Address"),
              onPressed: _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text(
                "Submit Address",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
