import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice/Components/global_variables.dart';
import 'package:invoice/Screens/Create%20Invoice/create_invoice.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class ProductDetailsScreen extends StatefulWidget {
  var selectedItemIndex;
  ProductDetailsScreen({
    super.key,
    /*String? description,
    String? brand,
    String? size,
    double? unit,
    double? rate,*/
    this.selectedItemIndex,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {

  final ImagePicker _imagePicker = ImagePicker();
  XFile? image;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController sizeController = TextEditingController();
  TextEditingController unitController = TextEditingController();
  TextEditingController rateController = TextEditingController();

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
  void initState() {
    if(widget.selectedItemIndex != null){
      image = productImages[widget.selectedItemIndex];
      descriptionController.text = descriptions[widget.selectedItemIndex];
      brandController.text = brandNames[widget.selectedItemIndex];
      sizeController.text = sizes[widget.selectedItemIndex];
      unitController.text = units[widget.selectedItemIndex].toString();
      rateController.text = rates[widget.selectedItemIndex].toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),

              //'Add Product Details'
              const Padding(
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

              //Add Product Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: (){
                      if(image?.path == null){
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select Image First'))
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
                        if(widget.selectedItemIndex != null){
                          //remove all the items in index
                          productImages.removeAt(widget.selectedItemIndex);
                          descriptions.removeAt(widget.selectedItemIndex);
                          brandNames.removeAt(widget.selectedItemIndex);
                          sizes.removeAt(widget.selectedItemIndex);
                          units.removeAt(widget.selectedItemIndex);
                          rates.removeAt(widget.selectedItemIndex);

                          //insert new values
                          productImages.insert(widget.selectedItemIndex, image!);
                          descriptions.insert(widget.selectedItemIndex, descriptionController.text);
                          brandNames.insert(widget.selectedItemIndex, brandController.text);
                          sizes.insert(widget.selectedItemIndex, sizeController.text);
                          units.insert(widget.selectedItemIndex, double.parse(unitController.text));
                          rates.insert(widget.selectedItemIndex, double.parse(rateController.text));
                          Get.to(
                              const CreateInvoice(),
                              transition: Transition.fade
                          );
                        }
                        else{
                          productImages.add(image!);
                          descriptions.add(descriptionController.text);
                          brandNames.add(brandController.text);
                          sizes.add(sizeController.text);
                          units.add(double.parse(unitController.text));
                          rates.add(double.parse(rateController.text));
                          Get.to(
                              const CreateInvoice(),
                              transition: Transition.fade
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
                    child: Text(
                    widget.selectedItemIndex != null ? 'Save Changes' : 'Add',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
}
