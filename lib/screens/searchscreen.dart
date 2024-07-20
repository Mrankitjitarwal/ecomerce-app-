import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Modal/product_model.dart';
import '../constants.dart';
import 'Home/Widget/product_cart.dart';
import 'nav_bar_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _searchResults = [];
  bool _showSearchResults = false;

  void _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults.clear();
      });
      return;
    }

    final url = 'http://jaatconnect.online/search.php?search=$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> jsonResults = json.decode(response.body);
        _searchResults =
            jsonResults.map((json) => Product.fromJson(json)).toList();
        _showSearchResults = true;

        // Update the product lists for each category with search results
        shoes = _searchResults.where((product) => product.category == 'shoes').toList();
        beauty = _searchResults.where((product) => product.category == 'beauty').toList();
        womenFashion = _searchResults.where((product) => product.category == 'womenFashion').toList();
        jewelry = _searchResults.where((product) => product.category == 'jewelry').toList();
        menFashion = _searchResults.where((product) => product.category == 'menFashion').toList();
        all = _searchResults; // Update the 'all' list with search results
      });
    } else {
      setState(() {
        _showSearchResults = false;
        _searchResults.clear();
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to load products. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Search",
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
                builder: (context) => const BottomNavBar(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 4,
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Search...",
                          border: InputBorder.none,
                        ),
                        onChanged: _searchProducts,
                      ),
                    ),
                    Container(
                      height: 25,
                      width: 1.5,
                      color: Colors.grey,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (_showSearchResults)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _searchResults.isNotEmpty
                      ? GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ProductCard(product: product);
                    },
                  )
                      : Center(
                    child: Text('No Product found'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
