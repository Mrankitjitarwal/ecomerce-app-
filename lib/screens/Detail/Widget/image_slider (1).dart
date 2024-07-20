import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

import '../../Home/Widget/SkeletonLoader.dart';

class MyImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final String image;
  const MyImageSlider({
    super.key,
    required this.image,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child:
      PageView.builder(
        onPageChanged: onChange,
        itemBuilder: (context, index) {
          return Hero(
            tag: image,
            child: Image.network(
              image,
              //width: double.infinity,
              //height: double.infinity,
             // fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, size: 150);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SkeletonLoader();
              },
            ),
          );
        },
      ),
    );
  }
}
