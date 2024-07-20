
import 'package:ecomerce/screens/signin.dart';
import 'package:ecomerce/screens/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
   final mq = MediaQuery.of(context).size;
    return Scaffold(
      body:
      Container(
        height: double.infinity,
        width: double.infinity,

       decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
            /*  Color(0xffB81736),
              Color(0xff281537),*/
              Color(0xFF000000), Color(0xFF3533CD),
            ]
          ),
        /*  image: DecorationImage(

              image: AssetImage('images/laptop.png')
          )*/
        ),

        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: Container(
              height: 390,

              decoration: BoxDecoration(
                image: DecorationImage(
                  scale: 1,
                  image: AssetImage("images/laptop.png"),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(10)),
          //SizedBox(height: 10,),
          Text('Welcome To Desi Mart',style: TextStyle(fontSize: 30,color: Colors.white),),
        SizedBox(height: 30,),
          GestureDetector(
            onTap: (){
              Get.to(() => LoginPage());
            },
            child:
            SingleChildScrollView(
              child: Container(
                height: 53,
                width: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white)
                ),

              child:
              SingleChildScrollView(
                child: Center(child:
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Log In',style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),),
                ),),
              ),
          ),
            ),),
          SizedBox(height: 30,),
          GestureDetector(
            onTap: (){
              Get.to(() => SignupPage());
            },
            child:Container(
              height: 53,
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),

              ),

              child: Center(child: Text('SIGN UP',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),),),

            ),),SizedBox(height: 10,),
         /* Text("⎯⎯⎯⎯⎯⎯⎯  Or⎯⎯⎯⎯⎯⎯⎯",style: TextStyle(fontSize: 25,color: Colors.white),),

          SizedBox(height: 15,),
          GestureDetector(

              child: Container(
                  height: 53,
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white),

                  ),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 115, 12, 37),
                        shape: const StadiumBorder(),
                        elevation: 1),
                    onPressed: () {
                     // _handleGoogleBtnClick();
                    },

                    //google icon
                    icon: Image.asset('images/Google.png', height: mq.height * .03),

                    //login with google label
                    label: RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          children: [
                            TextSpan(text: '    Login with '),
                            TextSpan(
                                text: 'Google',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                          ]),
                    )),
              )),*/
        ],

        ),
      ),
    );
  }
}
