import 'package:flutter/material.dart';

import '../../nav_bar_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  CustomAppBar({
    required this.title,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: textColor),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => const BottomNavBar(),
          ));
        },
      ),
    );
  }
}
