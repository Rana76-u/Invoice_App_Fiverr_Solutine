import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class CreateInvoice extends StatefulWidget {
  const CreateInvoice({super.key});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {

  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;
  DateTime selectedDate = DateTime.now();

  TextEditingController shippingMarkController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController rateController = TextEditingController();

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 60,
          width: 200,
          child: FittedBox(
            child: FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                    shape: const RoundedRectangleBorder( // <-- SEE HERE
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22.0),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context){
                      return FractionallySizedBox(
                        heightFactor: 0.9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height*0.55, //420
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 25,),

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
                                      controller: shippingMarkController,
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
                                      controller: shippingMarkController,
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

                                  const SizedBox(height: 7,),

                                  textWidget('Delivery Date'),
                                  // Date Picker
                                  SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: (){

                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateColor.resolveWith(
                                                  (states) => Colors.white
                                          ),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                                side: BorderSide.none,
                                              )
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.date_range,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Select a day',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),

                                                GestureDetector(
                                                  onTap: () => _selectDate(context),
                                                  child: Text(
                                                    '${selectedDate.toLocal()}'.split(' ')[0],
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                    ),
                                  ),

                                  const SizedBox(height: 15,),

                                  //Add Product Button
                                  SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: (){

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
                                          'Add',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white
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
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              label: const Text(
                'Add Product',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
              icon: const Icon(
                  Icons.add_circle
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),

              textWidget('Create Invoice'),

              const SizedBox(height: 20,),

              topProfileCard(),

              const SizedBox(height: 20,),

              textWidget('Upload Picture of Shop/Supplier'),
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

              const SizedBox(height: 15,),

              textWidget('Shipping Mark'),
              SizedBox(
                height: 60,
                child: TextField(
                  controller: shippingMarkController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder:  OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    prefixIcon: const Icon(
                      Icons.edit,
                      color: Colors.green,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: "Enter Shipping Mark",
                  ),
                  cursorColor: Colors.black,
                ),
              ),

              const SizedBox(height: 200,)
            ],
          ),
        ),
      ),
    );
  }

  Widget topProfileCard() {
    return SizedBox(
      height: 165,
      width: double.infinity,
      child: ElevatedButton(
          onPressed: (){

          },
          style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Colors.white
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Lottie.asset('assets/Lottie/upload_image.json'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textWidget('Shop/Supplier Name'),
                    subTextWidget('+8801876678906'),
                    subTextWidget('Vendor Type: Shop'),
                  ],
                ),
              )
            ],
          )
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

  Widget subTextWidget(String text){
    return Padding(
      padding: const EdgeInsets.only(left: 3, bottom: 3),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.clip,
            color: Colors.black
        ),
      ),
    );
  }
}
