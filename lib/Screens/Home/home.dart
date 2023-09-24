import 'package:flutter/material.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';
import 'package:invoice/Screens/Create%20Invoice/create_invoice.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 60,
        width: 200,
        child: FittedBox(
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.to(
                const CreateInvoice(),
                transition: Transition.fade,
              );
            },
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            label: const Text(
                'Create Invoice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),
            ),
              icon: const Icon(
                  Icons.document_scanner
              ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05,),

              //Top Profile Card
              topProfileCard(),

              //text
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 10),
                  child: textWidget('Recent Invoices')
              ),

              Container(
                height: 500,
                width: double.infinity,
                child: SfPdfViewer.network(
                    'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
                    scrollDirection: PdfScrollDirection.horizontal)
              ),

              ElevatedButton(
                onPressed: () {
                  SfPdfViewer.network(
                      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
                      canShowScrollHead: false,
                      canShowScrollStatus: false
                  );
                  print('clicked');
                },
                child: Text('PDF'),
              )

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
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 2),)
            );
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
                    textWidget('Shop/Company Name'),
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
}
