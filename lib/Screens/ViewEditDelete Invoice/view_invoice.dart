import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';
import 'package:invoice/Components/global_variables.dart';
import 'package:invoice/Components/model/customer.dart';
import 'package:invoice/Components/model/supplier.dart';
import 'package:invoice/Screens/Product%20Screen/product_details_screen.dart';
import 'package:invoice/Screens/viewpdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/api/pdf_invoice_api.dart';
import '../../Components/model/invoice.dart';
import 'package:image/image.dart' as img;

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
  TextEditingController shippingMarkController = TextEditingController();
  bool isDateSelectedByPicker = false;
  bool seeTotalTaped = false;

  @override
  void initState() {
    getLocallySavedData();
    super.initState();
  }

  void getLocallySavedData() async {
    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    setState(() {
      shippingMarkController.text = prefs.getString('shippingMark')!;

      vendorType = prefs.getString('vendorType')!;
      cardImageLink = prefs.getString('businessCardURL')!;
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

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //upload invoice info
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(phnNumber).collection('invoices').doc(widget.invoiceNumber.toString())
        .update({
      'shippingMark': prefs.getString('shippingMark'),
      'deliveryDate': selectedDate,
      'supplierImage': shopSupplierImageLink
    });

    //Remove global variables
    productImageLinks.clear();
    productImages.clear();
    descriptions.clear();
    brandNames.clear();
    sizes.clear();
    units.clear();
    rates.clear();

    //shopSupplierImage = null;
    shippingMarkController.clear();
    prefs.setString('shippingMark', '');
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
                /*showModalBottomSheet(
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
                );*/
                Get.to(
                    ProductDetailsScreen(),
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

                shippingMarkController.text = snapshot.data!.get('shippingMark');
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
                          SharedPreferences  prefs = await SharedPreferences.getInstance();
                          prefs.setString('shippingMark', shippingMarkController.text);
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

                                    productImageLinks.add(itemSnapshot.data!.docs[index].get('imageLink'));
                                    descriptions.add(itemSnapshot.data!.docs[index].get('description'));
                                    brandNames.add(itemSnapshot.data!.docs[index].get('brand'));
                                    units.add(itemSnapshot.data!.docs[index].get('quantity'));
                                    rates.add(itemSnapshot.data!.docs[index].get('rate'));
                                    sizes.add(itemSnapshot.data!.docs[index].get('size'));

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
                                                      /*description: descriptions[index],
                                        size: sizes[index],
                                        brand: brandNames[index],
                                        rate: rates[index],
                                        unit: units[index],*/
                                                      selectedItemIndex: index,
                                                      docID: itemSnapshot.data!.docs[index].id,
                                                      invoiceNumber: widget.invoiceNumber
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
                                                            descriptions[index],
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
                                                          'Brand: ${brandNames[index]}',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black54
                                                          ),
                                                        ),

                                                        //Size
                                                        Text(
                                                          'Size: ${sizes[index]}',
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.black54
                                                          ),
                                                        ),

                                                        //Quantity
                                                        Text(
                                                          'Quantity: ${units[index]}',
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
                                                            'Rate: ${rates[index]}',
                                                            style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors.black54,
                                                                fontWeight: FontWeight.bold
                                                            ),
                                                          ),
                                                        ),

                                                        //total
                                                        Text(
                                                          'Total: ${units[index]*rates[index]}',
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
                                                            onPressed: () {

                                                              productImages.removeAt(index);
                                                              descriptions.removeAt(index);
                                                              brandNames.removeAt(index);
                                                              sizes.removeAt(index);
                                                              units.removeAt(index);
                                                              rates.removeAt(index);

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
                    if(descriptions.isNotEmpty)...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Save Invoice Button
                          SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width*0.5-30,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if(shippingMarkController.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Write Description'))
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
                          pdfBtn()
                        ],
                      )
                    ],

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

  Widget pdfBtn() {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width*0.5-30,
      child: ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);

            if(shopSupplierImage?.path == null){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select Image First'))
              );
            }
            else if(shippingMarkController.text.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fill in Shipping Mark'))
              );
            }
            else {
              final invoice = Invoice(
                  supplier: const Supplier(
                      name: 'Rana',
                      phoneNumber: '01876678906',
                      whatsAppNumber: '',
                      lineNumber: '',
                      viberNumber: ''
                  ),
                  customer: const Customer(
                      shippingMark: 'Rana/Male'
                  ),
                  info: InvoiceInfo(
                    date: DateTime.now(),
                    dueDate: selectedDate,
                    number: '4562', //invoice number
                  ),
                  items:
                  List.generate(
                    productImages.length,
                        (index) {
                      return InvoiceItem(
                          description: descriptions[index],
                          brand: brandNames[index],
                          size: sizes[index],
                          quantity: units[index].toInt(),
                          unitPrice: rates[index]
                      );
                    },
                  )
              );
              final pdfFile = await PdfInvoiceApi.generate(invoice);

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
              //FileHandleApi.openFile(pdfFile);*/
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
    );
  }
}