import 'dart:convert';
import 'package:ecomerce/screens/Home/Widget/SkeletonLoader.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart'; // Import Skeletonizer

class ImageSlider extends StatefulWidget {
  final Function(int) onChange;
  final int currentSlide;

  const ImageSlider({
    Key? key,
    required this.currentSlide,
    required this.onChange,
  }) : super(key: key);

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  List<String> imageUrls = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    try {
      final response = await http.get(Uri.parse('http://jaatconnect.online/displaybanner.php'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            imageUrls = List<String>.from(json.decode(response.body).map((url) => 'http://jaatconnect.online/$url'));
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load image URLs. Status code: ${response.statusCode}');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
        });
      }
      print('Error fetching image URLs: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isLoading)
          SizedBox(height: 220,
            width: double.infinity,
            child: SkeletonLoader(),
          )

        else if (errorMessage != null)
          Center(child: Text('Error: $errorMessage'))
        else
          SizedBox(
            height: 220,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Skeletonizer(
                enabled: isLoading,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  onPageChanged: widget.onChange,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final imageUrl = imageUrls[index];
                    print('Loading image: $imageUrl'); // Log the URL
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SkeletonLoader();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Failed to load image: $error'); // Log the error
                        return const Center(child: Text('Failed to load image'));
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        Positioned.fill(
          bottom: 10,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.currentSlide == index ? 15 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.currentSlide == index ? Colors.black : Colors.transparent,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
