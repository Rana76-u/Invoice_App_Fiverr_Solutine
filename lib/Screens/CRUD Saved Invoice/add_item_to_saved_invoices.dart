import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice/Screens/CRUD%20Saved%20Invoice/view_invoice.dart';
import 'package:invoice/Screens/Create%20Invoice/create_invoice.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;


class AddItemToSavedInvoices extends StatefulWidget {
  final int invoiceNumber;

  const AddItemToSavedInvoices({
    super.key,
    required this.invoiceNumber,
  });

  @override
  State<AddItemToSavedInvoices> createState() => _AddItemToSavedInvoicesState();
}

class _AddItemToSavedInvoicesState extends State<AddItemToSavedInvoices> {

  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  String imageLink = '';
  String phnNumber = '';
  bool isLoading = false;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController rateController = TextEditingController();

  @override
  void initState() {
    loadAllDataFromPreviousPage();
    super.initState();
  }

  Future<void> loadAllDataFromPreviousPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phnNumber = prefs.getString('phoneNumber')!;
  }

  Future<void> updateInfo() async {

    //upload shop/supplier image into storage and get the shopSupplierImageLink
    if(image?.path != null){
      await _uploadItemImage();
    }

    //upload invoice info
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(phnNumber)
        .collection('invoices')
        .doc(widget.invoiceNumber.toString())
        .collection('items').doc()
        .set({
      'description': descriptionController.text,
      'brand': brandController.text,
      'size': sizeController.text,
      'quantity': double.parse(unitController.text),
      'rate': double.parse(rateController.text),
      'imageLink': imageLink
    });
  }

  Future<void> _uploadItemImage() async {
    final messenger = ScaffoldMessenger.of(context);
    Random random = Random();

    File compressedFile = await _compressImage(File(image!.path));
    Reference ref = FirebaseStorage
        .instance
        .ref()
        .child('Shop Media/$phnNumber/Invoice Media/${widget.invoiceNumber}/item${random.nextInt(100)}'); //DateTime.now().millisecondsSinceEpoch
    UploadTask uploadTask = ref.putFile(compressedFile);
    TaskSnapshot snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {
      String downloadURL = await snapshot.ref.getDownloadURL();
      imageLink = downloadURL;
    } else {
      messenger.showSnackBar(SnackBar(content: Text('An Error Occurred\n${snapshot.state}')));
      return;
    }
  }

  Future<File> _compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image != null) {
      img.Image compressedImage = img.copyResize(image, width: 1024);
      return File('${file.path}_compressed.jpg')..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 50));
    } else {
      return file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ?
          const Center(
            child: LinearProgressIndicator(),
          )
      :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),

              //'Add Product Details' Text
              GestureDetector(
                onTap: () {
                  Get.to(
                      const CreateInvoice(),
                      transition: Transition.fade
                  );
                },
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: Text(
                        'Add Product Details',
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            overflow: TextOverflow.clip
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15,),

              textWidget('Upload Picture of Product'),
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
                          // The "Gallery" button
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
                          // The "Cancel" button
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
                          imageLink != '' ?
                          Image.network(
                            imageLink,
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

              const SizedBox(height: 5,),
              textWidget('Product Description'),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 135,
                  maxHeight: 300,
                ),
                child: Card(
                  elevation: 3,
                  shadowColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: descriptionController,
                      style: const TextStyle(
                        //fontWeight: FontWeight.bold,
                          fontSize: 14,
                          overflow: TextOverflow.clip
                      ),
                      decoration: const InputDecoration(
                          hintText: 'Write description about product details . . . ',
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none
                          )
                      ),
                      cursorColor: Colors.green,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 7,),

              textWidget('Product Brand'),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: brandController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.abc,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: "Enter Brand Name",
                  ),
                  cursorColor: Colors.black,
                ),
              ),

              const SizedBox(height: 7,),

              textWidget('Size'),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: sizeController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.onetwothree,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: "Enter Size",
                  ),
                  cursorColor: Colors.black,
                ),
              ),

              const SizedBox(height: 7,),

              textWidget('Unit/Quantity'),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.onetwothree,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: "Enter Unit/Quantity",
                  ),
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                ),
              ),

              const SizedBox(height: 7,),

              textWidget('Rate'),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: rateController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.onetwothree,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: "Enter Rate",
                  ),
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                ),
              ),

              const SizedBox(height: 15,),

              //Add Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if(image!.path.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload Image, It\'s Required'))
                        );
                      }
                      else if(descriptionController.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Write Description'))
                        );
                      }
                      else if(brandController.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Write Brand Name'))
                        );
                      }
                      else if(sizeController.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter Size'))
                        );
                      }
                      else if(unitController.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter Unit/Quantity'))
                        );
                      }
                      else if(rateController.text.isEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter Rate'))
                        );
                      }
                      else {

                        setState(() {
                          isLoading = true;
                        });

                        await updateInfo();

                        Get.to(
                            ViewInvoice(invoiceNumber: widget.invoiceNumber),
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
                      'Add Item',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white
                      ),
                    )
                ),
              ),

              const SizedBox(height: 150,),
            ],
          ),
        ),
      ),
    );
  }

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
}
