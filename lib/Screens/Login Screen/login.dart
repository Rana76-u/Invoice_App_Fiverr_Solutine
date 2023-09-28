import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool isLoading = false;
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

              //Login Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
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
                        final userData =
                            await FirebaseFirestore
                            .instance
                            .collection('userData')
                            .doc(phnNumberController.text)
                            .get();

                        //Checks if Phone Number is Correct or not
                        if (userData.exists) {
                          final password = await userData.get('password');

                          //Checks if Password is Correct or not
                          if(password == passwordController.text){
                            setState(() {
                              isLoading = true;
                            });

                            //saveDataInternally
                            String vendorType = await userData.get('vendorType');
                            String businessCardURL = await userData.get('businessCardURL');
                            String shopName = await userData.get('shopName');
                            String whatsApp = await userData.get('whatsApp');
                            String line = await userData.get('line');
                            String viber = await userData.get('viber');
                            int invoiceNumber = await userData.get('invoiceNumber');

                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                            await prefs.setString('vendorType', vendorType);
                            await prefs.setString('businessCardURL', businessCardURL);
                            await prefs.setString('shopName', shopName);
                            await prefs.setString('phoneNumber', phnNumberController.text);
                            await prefs.setString('password', passwordController.text);
                            await prefs.setString('whatsApp', whatsApp);
                            await prefs.setString('line', line);
                            await prefs.setString('viber', viber);
                            await prefs.setInt('invoiceNumber', invoiceNumber);

                            Get.to(
                                BottomBar(bottomIndex: 0),
                                transition: Transition.leftToRight
                            );
                          }
                          else{
                            messenger.showSnackBar(
                                const SnackBar(content: Text(
                                  'Password isn\'t Correct',
                                ))
                            );
                          }
                        }
                        else {
                          messenger.showSnackBar(
                              const SnackBar(content: Text(
                                'Phone Number isn\'t Correct',
                              ))
                          );
                        }
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
