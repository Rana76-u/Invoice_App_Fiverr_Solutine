import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';
import 'package:invoice/Components/model/invoice.dart';
import 'package:invoice/Components/model/supplier.dart';
import 'package:invoice/Screens/CRUD%20Saved%20Invoice/add_item_to_saved_invoices.dart';
import 'package:invoice/Screens/viewpdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import '../../Components/api/pdf_invoice_api.dart';
import '../../Components/model/customer.dart';
import 'edit_product_details_screen.dart';

class ViewInvoice extends StatefulWidget {
  final int invoiceNumber;
  const ViewInvoice({super.key, required this.invoiceNumber});

  @override
  State<ViewInvoice> createState() => _ViewInvoiceState();
}

class _ViewInvoiceState extends State<ViewInvoice> {

  final ImagePicker _imagePicker = ImagePicker();
  DateTime selectedDate = DateTime.now();
  bool isDeleting = false;
  double total = 0.0;
  File? viewPdfFile;
  String shopName = '';
  String vendorType = '';
  String phnNumber = '';
  String cardImageLink = '';
  String shopSupplierImageLink = '';
  String itemImageLink = '';
  bool isLoading = false;
  bool isDateSelectedByPicker = false;
  bool seeTotalTaped = false;
  bool isShippingMarkChanged = false;
  TextEditingController shippingMarkController = TextEditingController();

  XFile? shopSupplierImage;
  
  //For PDF purpose only
  List<String> productDescriptions = [];
  List<String> productBrandNames = [];
  List<String> productSizes = [];
  List<double> productUnits = [];
  List<double> productRates = [];

  @override
  void initState() {
    getLocallySavedData();
    super.initState();
  }

  void getLocallySavedData() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    setState(() {
      phnNumber = prefs.getString('phoneNumber')!;
      shopName = prefs.getString('shopName')!;
      phnNumber = prefs.getString('phoneNumber')!;
    });
  }

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

  Future<void> updateInfo() async {

    //upload shop/supplier image into storage and get the shopSupplierImageLink
    if(shopSupplierImage?.path != null){
      await _uploadShopSupplierImage();
    }

    //SharedPreferences prefs = await SharedPreferences.getInstance();

    //upload invoice info
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(phnNumber).collection('invoices').doc(widget.invoiceNumber.toString())
        .update({
      'shippingMark': shippingMarkController.text,//prefs.getString('shippingMark'),
      'deliveryDate': selectedDate,
      'supplierImage': shopSupplierImageLink
    });
  }

  Future<void> _uploadShopSupplierImage() async {
    final messenger = ScaffoldMessenger.of(context);

    File compressedFile = await _compressImage(File(shopSupplierImage!.path));
    Reference ref = FirebaseStorage
        .instance
        .ref()
        .child('Shop Media/$phnNumber/Invoice Media/${widget.invoiceNumber}/shopSupplierImage'); //DateTime.now().millisecondsSinceEpoch
    UploadTask uploadTask = ref.putFile(compressedFile);
    TaskSnapshot snapshot = await uploadTask;
    if (snapshot.state == TaskState.success) {
      String downloadURL = await snapshot.ref.getDownloadURL();
      shopSupplierImageLink = downloadURL;
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

  Future<void> deleteItem(String docID) async {
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(phnNumber)
        .collection('invoices')
        .doc(widget.invoiceNumber.toString())
        .collection('items').doc(docID)
        .delete();
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a Firebase Storage reference from the image URL
      Reference storageReference = FirebaseStorage.instance.refFromURL(imageUrl);

      // Delete the image
      await storageReference.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
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
          width: MediaQuery.of(context).size.width,//200
          child: FittedBox(
            child: FloatingActionButton.extended(
              onPressed: () {
                Get.to(
                    AddItemToSavedInvoices(invoiceNumber: widget.invoiceNumber),
                    transition: Transition.fade
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
      body:  isLoading || phnNumber == ''?
      Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width*0.4,
          child: const LinearProgressIndicator(),
        ),
      )
          :
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FutureBuilder(
            future: FirebaseFirestore
                .instance
                .collection('userData')
                .doc(phnNumber)
                .collection('invoices')
                .doc('${widget.invoiceNumber}').get(),
            builder: (context, snapshot) {
              if(snapshot.hasData){

                if(!isShippingMarkChanged){
                  shippingMarkController.text = snapshot.data!.get('shippingMark');
                }
                shopSupplierImageLink = snapshot.data!.get('supplierImage');
                
                if(isDateSelectedByPicker == false){
                  selectedDate = snapshot.data!.get('deliveryDate').toDate();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                    GestureDetector(
                      onTap: () {
                        Get.to(
                            BottomBar(bottomIndex: 0),
                            transition: Transition.fade
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                          ),
                          textWidget('Viewing Invoice'),
                        ],
                      ),
                    ),

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
                                      shopSupplierImage = await _imagePicker.pickImage(source: ImageSource.camera);
                                      setState(() {
                                        // Close the dialog
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: const Text('Camera')),
                                TextButton(
                                    onPressed: () async {
                                      shopSupplierImage = await _imagePicker.pickImage(source: ImageSource.gallery);
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
                                child: shopSupplierImage != null ?
                                Image.file(
                                  File(shopSupplierImage!.path),
                                  fit: BoxFit.cover,
                                )
                                    :
                                Image.network(
                                  snapshot.data!.get('supplierImage'),
                                  fit: BoxFit.contain,
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
                        onChanged: (value) async {
                          setState(() {
                            isShippingMarkChanged = true;
                          });
                        },
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

                    textWidget('Delivery Date'),
                    // Date Picker
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: (){
                            setState(() {
                              isDateSelectedByPicker = true;
                            });
                              _selectDate(context);
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
                                color: Colors.green,
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

                                  //Picked Date
                                  Text(
                                    DateFormat('EE, dd MMM,yy').format(selectedDate.toLocal()),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                      ),
                    ),

                    const SizedBox(height: 15,),

                    /*if(seeTotalTaped == false)...[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            seeTotalTaped = true;
                          });
                        },
                        child: const Text(
                          'Tap to See Total',
                          style: TextStyle(
                              fontSize: 12
                          ),
                        ),
                      ),
                    ],

                    if(seeTotalTaped)...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textWidget('Items ${descriptions.length}'),
                            textWidget('Grand Total: $total'),
                          ],
                        ),
                      ),
                    ],*/

                    FutureBuilder(
                      future: FirebaseFirestore
                          .instance
                          .collection('userData')
                          .doc(phnNumber)
                          .collection('invoices')
                          .doc('${widget.invoiceNumber}').collection('items').get(),
                      builder: (context, itemSnapshot) {
                        if(itemSnapshot.hasData){
                          return Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: isDeleting ?
                                const Center(
                                  child: LinearProgressIndicator(),
                                ) :
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: itemSnapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    
                                    productDescriptions.add(itemSnapshot.data!.docs[index].get('description'));
                                    productBrandNames.add(itemSnapshot.data!.docs[index].get('brand'));
                                    productUnits.add(itemSnapshot.data!.docs[index].get('quantity'));
                                    productRates.add(itemSnapshot.data!.docs[index].get('rate'));
                                    productSizes.add(itemSnapshot.data!.docs[index].get('size'));

                                    total = total + (itemSnapshot.data!.docs[index].get('quantity') * itemSnapshot.data!.docs[index].get('rate'));
                                    //SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));

                                    return SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Card(
                                        elevation: 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Get.to(
                                                    EditSavedProductDetailsScreen(
                                                      selectedItemIndex: index,
                                                      docID: itemSnapshot.data!.docs[index].id,
                                                      invoiceNumber: widget.invoiceNumber,

                                                      imageLink: itemSnapshot.data!.docs[index].get('imageLink'),
                                                      description: itemSnapshot.data!.docs[index].get('description'),
                                                      brand: itemSnapshot.data!.docs[index].get('brand'),
                                                      size: itemSnapshot.data!.docs[index].get('size'),
                                                      quantity: itemSnapshot.data!.docs[index].get('quantity'),
                                                      rate: itemSnapshot.data!.docs[index].get('rate'),
                                                    ),
                                                    transition: Transition.fade
                                                );
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  //Image
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width*0.38 - 25,//0.40, 0.38 - 25 0.32 - 10
                                                      height: 124, //137 127 120
                                                      decoration: BoxDecoration(
                                                        /*border: Border.all(
                                                                  width: 0, //4
                                                                  color: Colors.transparent
                                                              ),*/
                                                          borderRadius: BorderRadius.circular(20)
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(15),
                                                        child:  Image.network(
                                                          itemSnapshot.data!.docs[index].get('imageLink'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  //Texts
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.45 - 10,//200,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        //Description
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 7),
                                                          child: Text(
                                                            itemSnapshot.data!.docs[index].get('description'),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        //Brand
                                                        Text(
                                                          'Brand: ${itemSnapshot.data!.docs[index].get('brand')}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black54
                                                          ),
                                                        ),

                                                        //Size
                                                        Text(
                                                          'Size: ${itemSnapshot.data!.docs[index].get('size')}',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black54
                                                          ),
                                                        ),

                                                        //Quantity
                                                        Text(
                                                          'Quantity: ${itemSnapshot.data!.docs[index].get('quantity')}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black54
                                                          ),
                                                        ),

                                                        //Rate
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 2),
                                                          child: Text(
                                                            'Rate: ${itemSnapshot.data!.docs[index].get('rate')}',
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors.black54,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                        ),

                                                        //total
                                                        Text(
                                                          'Total: ${total.toStringAsFixed(2)}',
                                                          style: const TextStyle(
                                                              fontSize: 15,
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            //Delete
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return  AlertDialog(
                                                      title: const Text('Please Confirm'),
                                                      content: const Text('Are you sure you want to delete this item?'),
                                                      actions: [
                                                        // The "Yes" button
                                                        TextButton(
                                                            onPressed: () async {
                                                              await deleteImage(itemSnapshot.data!.docs[index].get('imageLink'));

                                                              await deleteItem(itemSnapshot.data!.docs[index].id);

                                                              setState(() {
                                                                Navigator.of(context).pop();
                                                              });
                                                            },
                                                            child: const Text('Yes')
                                                        ),
                                                        TextButton(
                                                            onPressed: () {
                                                              // Close the dialog
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text('No'))
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 10),
                                                child: SizedBox(
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        else if(itemSnapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: LinearProgressIndicator(),
                          );
                        }
                        else{
                          return const Center(
                            child: Text('Error Loading Data'),
                          );
                        }
                      },
                    ),


                    const SizedBox(height: 20,),

                    //Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //update Invoice Button
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.5-30,
                          child: ElevatedButton(
                              onPressed: () async {
                                if(shippingMarkController.text.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fill in Shipping Mark'))
                                  );
                                }
                                else {

                                  setState(() {
                                    isLoading = true;
                                  });

                                  await updateInfo();

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
                                'Update Invoice',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white
                                ),
                              )
                          ),
                        ),
                        const SizedBox(width: 10,),
                        SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.5-30,
                          child: ElevatedButton(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);

                                if(shippingMarkController.text.isEmpty){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Fill in Shipping Mark'))
                                  );
                                }
                                else {
                                  final invoice = Invoice(
                                      supplier: Supplier(
                                          name: shopName,
                                          phoneNumber: phnNumber,
                                          whatsAppNumber: '',
                                          lineNumber: '',
                                          viberNumber: ''
                                      ),
                                      customer: Customer(
                                          shippingMark: shippingMarkController.text
                                      ),
                                      info: InvoiceInfo(
                                        date: DateTime.now(),
                                        dueDate: selectedDate,
                                        number: widget.invoiceNumber.toString(), //invoice number
                                      ),
                                      items:
                                      List.generate(
                                        productDescriptions.length,
                                            (index) {
                                          return InvoiceItem(
                                              description: productDescriptions[index],
                                              brand: productBrandNames[index],
                                              size: productSizes[index],
                                              quantity: productUnits[index].toInt(),
                                              unitPrice: productRates[index]
                                          );
                                        },
                                      )
                                  );
                                  final pdfFile = await PdfInvoiceApi.generate(invoice, 'Invoice no.${widget.invoiceNumber}.pdf');

                                  messenger.showSnackBar(
                                      const SnackBar(
                                          content: Text('Invoice Saved into Downloads Folder')
                                      )
                                  );

                                  //PdfApi.openFile(pdfFile);
                                  //final pdfFile = await PdfInvoiceApi.generate();

                                  setState(() {
                                    viewPdfFile = pdfFile;
                                  });

                                  Get.to(
                                      ViewPDF(pdf: pdfFile),
                                      transition: Transition.fade
                                  );
                                  //FileHandleApi.openFile(pdfFile);
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
                                'Generate PDF',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white
                                ),
                              )
                          ),
                        )
                      ],
                    ),

                    if(viewPdfFile != null)...[
                      GestureDetector(
                        onTap: () {
                          Get.to(
                              ViewPDF(pdf: viewPdfFile!),
                              transition: Transition.fade
                          );
                        },
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(top: 30, right: 10),
                                child: Text(
                                  'Invoice PDF saved into Downloads Folder',
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                      overflow: TextOverflow.clip
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'Click to View',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrangeAccent,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                    overflow: TextOverflow.clip
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],

                    const SizedBox(height: 200,)
                  ],
                );
              }
              else if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: LinearProgressIndicator(),
                );
              }
              else{
                return const Center(
                  child: Text('Error Loading Data'),
                );
              }
            },
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
