import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController phnNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget textWidget(String text){
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            overflow: TextOverflow.clip
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.04,),

              //Login
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height*0.3,),

              //Contact Number*
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Phone Number*')
              ),
              //Contact Number field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: phnNumberController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter Contact Number",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(),
                  cursorColor: Colors.green,
                ),
              ),

              //Password
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Password*')
              ),
              //Password field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.password,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter Password",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  cursorColor: Colors.green,
                ),
              ),

              const SizedBox(height: 20,),

              //Register Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      final messenger = ScaffoldMessenger.of(context);

                      if(phnNumberController.text.isEmpty){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                              'Phone Number Required',
                            ))
                        );
                      }
                      else if(passwordController.text.isEmpty){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                              'Password Required',
                            ))
                        );
                      }
                      else{
                        Get.to(
                            BottomBar(bottomIndex: 0),
                            transition: Transition.fade
                        );
                      }
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
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white
                      ),
                    )
                ),
              ),

              const SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
}
