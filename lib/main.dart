import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invoice/Screens/Login%20Screen/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        //fontFamily: 'Urbanist'
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen()//BottomBar(bottomIndex: 0),
    );
  }
}

