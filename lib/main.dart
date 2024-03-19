import 'package:fibeco_qms/customer.dart';
import 'package:fibeco_qms/navigation.dart';
import 'package:fibeco_qms/serving.dart';
import 'package:flutter/material.dart';
import 'package:fibeco_qms/clerk.dart';

import 'package:firebase_core/firebase_core.dart';



Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC9EGZ91xtj17Chf92H3UjIJlI039dLEo8",
      appId: "1:66678153075:android:05b26a9ce78ae22e93ef06",
      messagingSenderId: "1:66678153075",
      projectId: "login-register-crud",
      authDomain: "login-register-crud.firebaseapp.com",
      storageBucket: "login-register-crud.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: NavigationScreen(),
    );
  }
}
