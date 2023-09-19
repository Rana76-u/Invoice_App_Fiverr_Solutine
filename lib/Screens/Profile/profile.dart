import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../Components/bottom_nav_bar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String chosenVendorType = '';
  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  bool confirmPassMatch = false;

  TextEditingController shopNameController = TextEditingController();
  TextEditingController phnNumberController = TextEditingController();
  TextEditingController whatsAppController = TextEditingController();
  TextEditingController lineController = TextEditingController();
  TextEditingController viberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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

              //Edit Profile
              const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 10,),

              //Choose text
              textWidget('Choose vendor type*'),

              const SizedBox(height: 10,),

              //Vendor type Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Shop Button
                  SizedBox(
                    height: 165,
                    width: MediaQuery.of(context).size.width*0.38,
                    child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            chosenVendorType = 'Shop';
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => chosenVendorType == 'Shop' ? Colors.purple.shade50 : Colors.white
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business,
                              color: chosenVendorType == 'Shop' ? Colors.white : Colors.purple,
                            ),
                            Text(
                              'Shop/Company',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: chosenVendorType == 'Shop' ? Colors.white : Colors.purple
                              ),
                            )
                          ],
                        )
                    ),
                  ),

                  //Individual Button
                  SizedBox(
                    height: 165,
                    width: MediaQuery.of(context).size.width*0.38,
                    child: ElevatedButton(
                        onPressed: (){
                          setState(() {
                            chosenVendorType = 'Individual';
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                                  (states) => chosenVendorType == 'Individual' ? Colors.blue.shade50 : Colors.white
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
                                      color: Colors.blue,
                                      width: 2
                                  )
                              )
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              color: chosenVendorType == 'Individual' ? Colors.white : Colors.blue,
                            ),
                            Text(
                              'Individual',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: chosenVendorType == 'Individual' ? Colors.white : Colors.blue
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20,),

              textWidget('Upload Picture of Business Card/ID Card*'),
              const SizedBox(height: 5,),

              //Chosen Image
              GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return  AlertDialog(
                        title: const Text('Pick Image From'),
                        content: const Text('Choose One'),
                        actions: [
                          // The "Camera" button
                          TextButton(
                              onPressed: () async {
                                image = await _imagePicker.pickImage(source: ImageSource.camera);
                                setState(() {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text('Camera')),
                          TextButton(
                              onPressed: () async {
                                image = await _imagePicker.pickImage(source: ImageSource.gallery);
                                setState(() {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text('Gallery')
                          ),
                          TextButton(
                              onPressed: () {
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,//150, 0.38
                  height: 181,
                  child: Stack(
                    children: [
                      //Image
                      Positioned(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: image != null ?
                          Image.file(
                            File(image!.path),
                            fit: BoxFit.cover,
                          )
                              :
                          Lottie.asset(
                            'assets/Lottie/upload_image.json',
                          ),
                        ),
                      ),

                      //black overlay
                      Positioned(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              height: 181,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.black.withOpacity(0.3),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 83),
                                child: Text(
                                  'Click to Change/Upload Image',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Type in Name*
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Type in Name*')
              ),
              //Name text field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: shopNameController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.store,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter Shop/Company/Individual Name",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  cursorColor: Colors.green,
                ),
              ),

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
                  onChanged: (value) {
                    if(value != confirmPasswordController.text){
                      setState(() {
                        confirmPassMatch = false;
                      });
                    }else{
                      setState(() {
                        confirmPassMatch = true;
                      });
                    }
                  },
                ),
              ),

              //Confirm Password
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Confirm Password*')
              ),
              //Confirm Password field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: confirmPasswordController,
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
                    fillColor: confirmPassMatch ? Colors.green[50] : Colors.red[50],
                    labelText: "Confirm Password",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  onChanged: (value) {
                    if(value != passwordController.text){
                      setState(() {
                        confirmPassMatch = false;
                      });
                    }else{
                      setState(() {
                        confirmPassMatch = true;
                      });
                    }
                  },
                  keyboardType: TextInputType.visiblePassword,
                  cursorColor: Colors.green,
                ),
              ),

              //WhatsApp Number*
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('WhatsApp Number (optional)')
              ),
              //WhatsApp Number field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: whatsAppController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.chat_outlined,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter WhatsApp Number",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(),
                  cursorColor: Colors.green,
                ),
              ),


              //Line
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Line Contact (optional)')
              ),
              //Line Number field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: lineController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.message_outlined,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter Line Contact",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(),
                  cursorColor: Colors.green,
                ),
              ),

              //Viber Number
              Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 5),
                  child: textWidget('Viber Contact (optional)')
              ),
              //Viber Number field
              SizedBox(
                height: 60,
                child: TextFormField(
                  controller: viberController,
                  decoration: InputDecoration(
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.message_outlined,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.green[50],
                    labelText: "Enter Viber Contact",
                    labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 14
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(),
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

                      if(chosenVendorType == ''){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                                'Choose A Vendor Type'
                            ))
                        );
                      }
                      else if(image == null){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                              'Image of Business Card/ID card is Required',
                            ))
                        );
                      }
                      else if(shopNameController.text.isEmpty){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                              'Name Required',
                            ))
                        );
                      }
                      else if(phnNumberController.text.isEmpty){
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
                      else if(confirmPassMatch == false){
                        messenger.showSnackBar(
                            const SnackBar(content: Text(
                              'Confirm Password Didn\'t Match',
                            ))
                        );
                      }
                      else{
                        Get.to(
                            BottomBar(bottomIndex: 0),
                            transition: Transition.rightToLeft
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

              const SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
}
