import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/Screens/Login%20Screen/loginscreen.dart';
import 'package:invoice/Screens/Profile/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {



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

  Widget subTextWidget(String text){
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.clip,
            color: Colors.grey
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

              //Profile
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 30,),

              //Edit Info
              SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      Get.to(
                        const EditProfile(),
                        transition: Transition.fade
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                              (states) => Colors.purple.shade50
                      ),
                      elevation:MaterialStateProperty.resolveWith<double>(
                            (Set<MaterialState> states) {
                          return 10.0;
                        },
                      ),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                  color: Colors.purple,
                                  width: 2
                              )
                          )
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.purple,
                        ),

                        SizedBox(width: 10,),

                        Text(
                          'Edit Info',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.purple
                          ),
                        ),

                        Expanded(child: SizedBox(width: 10,)),
                        
                        Icon(Icons.arrow_forward)
                      ],
                    )
                ),
              ),

              const SizedBox(height: 15,),

              //Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    setState(() {
                      prefs.remove('vendorType');
                      prefs.remove('businessCardURL');
                      prefs.remove('shopName');
                      prefs.remove('phoneNumber');
                      prefs.remove('password');
                      prefs.remove('whatsApp');
                      prefs.remove('line');
                      prefs.remove('viber');
                    });

                    Get.to(
                      const LoginScreen(),
                      transition: Transition.fade
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,//MaterialStateProperty.all(Colors.grey.shade200),
                    elevation: 0.0,
                  ),
                  child: const Text(
                    "Log out",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
