import 'package:flutter/material.dart';
import 'package:invoice/Screens/Login%20Screen/login.dart';
import 'package:invoice/Screens/Login%20Screen/register.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Components/bottom_nav_bar.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  bool isLoading = true;

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  void checkLogin() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    if(prefs.getString('shopName') == null){
      setState(() {
        isLoading = false;
      });
    }
    else {
      Get.to(
          BottomBar(bottomIndex: 0),
          transition: Transition.fade
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: isLoading ?
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.4,
            child: const LinearProgressIndicator(),
          ),
        )
            :
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const Expanded(child: SizedBox()),

                const SizedBox(height: 20,),
                Lottie.asset('assets/Lottie/login.json'),

                const SizedBox(height: 80,),

                //Welcome
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                //to invoice App
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Text(
                    'to invoice app',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Urbanist'
                    ),
                  ),
                ),

                const SizedBox(height: 50,),

                //Register Button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (){
                        Get.to(
                            const RegisterScreen(),
                            transition: Transition.rightToLeft
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.deepOrangeAccent
                        ),
                        elevation:MaterialStateProperty.resolveWith<double>(
                              (Set<MaterialState> states) {
                            return 10.0;
                          },
                        ),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            )
                        ),
                      ),
                      child: const Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white
                        ),
                      )
                  ),
                ),

                const SizedBox(height: 10,),

                //Login Button
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: (){
                        Get.to(
                            const Login(),
                            transition: Transition.fade
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white
                        ),
                        shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2
                                )
                            )
                        ),
                      ),
                      child: const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepOrangeAccent
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
