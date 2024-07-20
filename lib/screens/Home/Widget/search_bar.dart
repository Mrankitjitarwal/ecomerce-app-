import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../searchscreen.dart';

const kcontentColor = Colors.white;

class MySearchBAR extends StatefulWidget {
  const MySearchBAR({Key? key}) : super(key: key);

  @override
  State<MySearchBAR> createState() => _MySearchBARState();
}

class _MySearchBARState extends State<MySearchBAR> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SearchScreen());
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kcontentColor,
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
              child: Text(
               "                      Search...                    ",
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
    );
  }
}


