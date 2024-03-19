import 'package:fibeco_qms/clerk.dart';
import 'package:fibeco_qms/customer.dart';
import 'package:fibeco_qms/serving.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:ojt_monitoring_sys/screens/welcomScreen.dart';


class NavigationScreen extends StatelessWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: Text("Navigation"),
            backgroundColor: Colors.grey[800], // Set the background color to dark grey
            actions: [],
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: Text('Customers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Clerk'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClerkScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Serving'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServingScreen()),
                );
              },
            ),

            // Add other ListTile items for additional functionalities if needed
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255), // Set the background color to blue
      body: Center(
        // Your body content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your existing body content goes here
          ],
        ),
      ),
    );
  }

  
}

void main() {
  runApp(MaterialApp(
    home: NavigationScreen(),
  ));
}
