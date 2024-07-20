import 'package:ecomerce/controller/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Modal/product_model.dart';
import '../../controller/favorite_controller.dart';
import 'Widget/product_cart.dart';
import 'Widget/search_bar.dart';
import '../../Modal/category.dart';
import 'Widget/home_app_bar.dart';
import 'Widget/image_slider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecomerce/screens/Cart/cart_screen.dart';
import 'package:ecomerce/screens/Favorite/favorite.dart';
import 'package:ecomerce/screens/Profile/profile.dart';
import 'package:ecomerce/screens/Privacyhelpetc/privacy & policy.dart';
import 'package:ecomerce/screens/WelcomeScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentSlider = 0;
  int selectedIndex = 0;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchProducts();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('emailid');
      name = prefs.getString('Username'); // Adjust according to your saved data
    });
  }

  Future<void> _fetchProducts() async {
    try {
      List<Product> allProducts = await fetchProducts();
      List<Product> shoesProducts = await fetchProductsByCategory('shoes');
      List<Product> beautyProducts = await fetchProductsByCategory('beauty');
      List<Product> womenFashionProducts = await fetchProductsByCategory('womenFashion');
      List<Product> jewelryProducts = await fetchProductsByCategory('jewelry');
      List<Product> menFashionProducts = await fetchProductsByCategory('menFashion');

      setState(() {
        all = allProducts;
        shoes = shoesProducts;
        beauty = beautyProducts;
        womenFashion = womenFashionProducts;
        jewelry = jewelryProducts;
        menFashion = menFashionProducts;
      });

      // Log to check if the products are set correctly
      print('All products: ${all.length}');
      print('Shoes products: ${shoes.length}');
      print('Beauty products: ${beauty.length}');
      print('Women Fashion products: ${womenFashion.length}');
      print('Jewelry products: ${jewelry.length}');
      print('Men Fashion products: ${menFashion.length}');
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<List<Product>> selectcategories = [
      all,
      shoes,
      beauty,
      womenFashion,
      jewelry,
      menFashion
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name ?? 'Loading...'),
              accountEmail: Text(email ?? 'Loading...'),
            ),
            InkWell(
              onTap: () {
                Get.to(() => HomeScreen());
              },
              child: ListTile(
                leading: Icon(LineIcons.home),
                title: Text('HomePage'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => Favorite());
              },
              child: ListTile(
                leading: Icon(LineIcons.heart),
                title: Text('Wishlist'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => CartScreen());
              },
              child: ListTile(
                leading: Icon(LineIcons.shoppingCart),
                title: Text('Cart'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => Profile());
              },
              child: ListTile(
                leading: Icon(LineIcons.user),
                title: Text('Account'),
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => PrivacyPolicyPage());
              },
              child: ListTile(
                leading: Icon(Icons.privacy_tip_rounded),
                title: Text('Privacy & Policy'),
              ),
            ),
            InkWell(
              onTap: () async {
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
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              // for custom appbar
              CustomAppBar(scaffoldKey: scaffoldKey),
              const SizedBox(height: 20),
              // for search bar
             // const MySearchBAR(),
              const SizedBox(height: 20),
              ImageSlider(
                currentSlide: currentSlider,
                onChange: (value) {
                  setState(() {
                    currentSlider = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // for category selection
              categoryItems(),
              const SizedBox(height: 20),
              //if (selectedIndex == 0)
                /*const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Special For You",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),*/
              // for shopping items
             // const SizedBox(height: 10),
              GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: selectcategories[selectedIndex].length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: selectcategories[selectedIndex][index],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox categoryItems() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoriesList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              setState(() {
                selectedIndex = index;
              });
              // Fetch products for the selected category
              List<Product> selectedCategoryProducts = [];
              if (index == 1) {
                selectedCategoryProducts = await fetchProductsByCategory('shoes');
                setState(() {
                  shoes = selectedCategoryProducts;
                });
              } else if (index == 2) {
                selectedCategoryProducts = await fetchProductsByCategory('beauty');
                setState(() {
                  beauty = selectedCategoryProducts;
                });
              } else if (index == 3) {
                selectedCategoryProducts = await fetchProductsByCategory('womenFashion');
                setState(() {
                  womenFashion = selectedCategoryProducts;
                });
              } else if (index == 4) {
                selectedCategoryProducts = await fetchProductsByCategory('jewelry');
                setState(() {
                  jewelry = selectedCategoryProducts;
                });
              } else if (index == 5) {
                selectedCategoryProducts = await fetchProductsByCategory('menFashion');
                setState(() {
                  menFashion = selectedCategoryProducts;
                });
              } else {
                selectedCategoryProducts = await fetchProducts();
                setState(() {
                  all = selectedCategoryProducts;
                });
              }

              // Log to check if the selected category products are updated correctly
              print('Selected category $index products: ${selectedCategoryProducts.length}');
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: selectedIndex == index
                    ? Colors.blue[200]
                    : Colors.transparent,
              ),
              child: Column(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(categoriesList[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    categoriesList[index].title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }
}
