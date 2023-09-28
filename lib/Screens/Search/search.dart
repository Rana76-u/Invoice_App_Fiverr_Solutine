import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoice/Components/bottom_nav_bar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CRUD Saved Invoice/view_invoice.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String phnNumber = '';
  int invoiceNumber = 0;
  DateTime selectedDate = DateTime.now();

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Create a text controller and reference it
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  String searchedText = '';

  // A list to hold the search results
  List<DocumentSnapshot> _searchResults = [];

  // A flag to determine if the search has completed
  bool _isSearching = false;
  bool isTyping = false;
  bool isFilterOpen = false;
  bool isDateSelected = false;

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
        performSearch(_searchController.text);
        isDateSelected = true;
        numberController.clear();
      });
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

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
      invoiceNumber = prefs.getInt('invoiceNumber')!;
    });

    final userData =
    await FirebaseFirestore
        .instance
        .collection('userData')
        .doc(phnNumber)
        .get();

    invoiceNumber = userData.get('invoiceNumber');
    prefs.setInt('invoiceNumber', invoiceNumber);

    performSearch('');
  }

  void performSearch(String searchItem) async {

    // Convert the search query to uppercase
    searchItem = searchItem.toUpperCase();

      // Get a reference to the products collection
      var ref = FirebaseFirestore
          .instance
          .collection('/userData')
          .doc(phnNumber)
          .collection('/invoices');

      // Build a query for shippingMark filtering
      var shippingMarkQuery = ref.where('shippingMark', isGreaterThanOrEqualTo: searchItem);
      var shippingMarkQuerySnapshot = await shippingMarkQuery.get();
      var filteredDocs = shippingMarkQuerySnapshot.docs;

      // Filter documents based on deliveryDate using Dart code
      if(isDateSelected){
        var filteredByDate = filteredDocs.where((doc) {
          Timestamp deliveryDate = doc['deliveryDate'];
          return deliveryDate.toDate().isAtSameMomentAs(selectedDate);
        }).toList();

        // Update the search results
        setState(() {
          _searchResults = filteredByDate;
          _isSearching = false;
        });
      }
      else {
        // Update the search results
        setState(() {
          _searchResults = filteredDocs;
          _isSearching = false;
        });
      }

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
            color: Colors.purple
        ),
      ),
    );
  }

  Future<bool> onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height*0.05,),

                // Search TextField
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(
                      color: Colors.grey
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          //TextField
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.9 - 40,//24
                            child: TextField(
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: "Search by Shipping Mark",
                                hintStyle: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey.shade500,
                                    fontFamily: 'Urbanist'
                                ),
                                prefixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        FocusScope.of(context).unfocus();
                                        _searchController.clear();
                                        isTyping = false;
                                        isFilterOpen = false;
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => BottomBar(bottomIndex: 0),),
                                        );
                                      });
                                    },
                                    child: const Icon(Icons.arrow_back_rounded)
                                ),
                                suffixIcon: _focusNode.hasFocus ?
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _searchController.clear();
                                        _isSearching = true;
                                        performSearch(_searchController.text);
                                        isTyping = false;
                                      });
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      size: 15,
                                      color: Colors.grey.shade400,
                                    )
                                )
                                :
                                GestureDetector(
                                    onTap: () {
                                      if(_searchController.text != ''){
                                        setState(() {
                                          _isSearching = true;
                                          performSearch(_searchController.text);
                                          isTyping = false;
                                        });
                                      }
                                    },
                                    child: const Icon(
                                      Icons.search_rounded
                                    )
                                ),
                              ),
                              controller: _searchController,
                              onChanged: (value) {
                                // Start the search when the user enters a value in the text field
                                setState(() {
                                  isTyping = true;
                                  searchedText = _searchController.text;
                                  isFilterOpen = false;
                                  numberController.clear();
                                });
                                // Perform the search
                                performSearch(value);
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  _isSearching = true;
                                  performSearch(value);
                                  isTyping = false;
                                });
                              },
                            ),
                          ),
                          //Filter
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if(isFilterOpen == true){
                                  isFilterOpen = false;
                                  isDateSelected = false;
                                  numberController.clear();
                                  selectedDate = DateTime.now();
                                  performSearch(_searchController.text);
                                }else{
                                  isFilterOpen = true;
                                }
                              });
                            },
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: _focusNode.hasFocus ? Colors.purple : Colors.grey ,
                            ),
                          ),
                        ],
                      ),
                      // A loading indicator while the search is in progress
                      _isSearching ? const LinearProgressIndicator()
                          : const SizedBox(
                        height: 0,
                        width: 0,
                      ),
                    ],
                  ),
                ),

                //Filter
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isFilterOpen ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text
                      const Padding(
                        padding: EdgeInsets.only(left: 5, top: 5),
                        child: Text(
                            'Filter By',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.clip,
                          ),
                        ),
                      ),

                      //Cards
                      Row(
                        children: [
                          //Date picker
                          GestureDetector(
                            onTap: (){
                              _selectDate(context);
                            },
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.grey
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.date_range,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 5,),
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
                                              fontSize: 13,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Cancel Date Select
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDateSelected = false;
                                selectedDate = DateTime.now();
                                performSearch(_searchController.text);
                              });
                            },
                            child: const Icon(
                                Icons.cancel,
                              color: Colors.grey,
                              size: 17,
                            ),
                          ),

                          const SizedBox(width: 8,),

                          //Sort by Number
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                  color: Colors.grey
                              ),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.3,//24
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  //focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "Invoice Number",
                                    hintStyle: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.grey.shade500,
                                        fontFamily: 'Urbanist'
                                    ),
                                  ),
                                  controller: numberController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      isTyping = true;
                                    });
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      isTyping = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          //Cancel Date Select
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                numberController.clear();
                                performSearch(_searchController.text);
                              });
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 17,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                      :
                  const SizedBox(),
                ),

                //Search Result
                Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: subTextWidget('Search Result')
                ),

                //Show Search Result Invoices
                if(numberController.text.isEmpty)...[
                  ListView.builder(
                    itemCount: _searchResults.length, //invoiceNumber
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore
                            .instance
                            .collection('userData')
                            .doc(phnNumber)
                            .collection('invoices')
                            .doc(_searchResults[index].id).get(), //'${invoiceNumber - index}'
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                onTap: () {
                                  Get.to(
                                      ViewInvoice(invoiceNumber: int.parse(_searchResults[index].id)), //invoiceNumber - index
                                      transition: Transition.fade
                                  );
                                },
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(
                                    snapshot.data!.get('supplierImage'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(snapshot.data!.get('shippingMark'),),
                                subtitle: Text(
                                    '${DateFormat('EE, dd MMM,yy').format(snapshot.data!.get('deliveryDate').toDate())}\nInvoice no. ${invoiceNumber - index}'
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                tileColor: Colors.blue.shade50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                              ),
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
                      );
                    },
                  )
                ]
                else...[
                  FutureBuilder(
                    future: FirebaseFirestore
                        .instance
                        .collection('userData')
                        .doc(phnNumber)
                        .collection('invoices')
                        .doc(numberController.text).get(), //'${invoiceNumber - index}'
                    builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: ListTile(
                            onTap: () {
                              Get.to(
                                  ViewInvoice(invoiceNumber: int.parse(numberController.text)), //invoiceNumber - index
                                  transition: Transition.fade
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                snapshot.data!.get('supplierImage'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(snapshot.data!.get('shippingMark'),),
                            subtitle: Text(
                                '${DateFormat('EE, dd MMM,yy').format(snapshot.data!.get('deliveryDate').toDate())}\nInvoice no. ${numberController.text}'
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            tileColor: Colors.blue.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
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
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
