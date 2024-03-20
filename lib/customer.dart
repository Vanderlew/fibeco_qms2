import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class CustomerScreen extends StatelessWidget {
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers'); // Reference to the 'customers' collection

  @override
  Widget build(BuildContext context) {
    String name = '';
    String email = '';
    String contact = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Queue Management System'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name:'),
              onChanged: (value) => name = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Email:'),
              onChanged: (value) => email = value,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Contact Number:'),
              onChanged: (value) => contact = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Fetch the latest number from Firestore and increment by 1
                customersCollection.orderBy('number', descending: true).limit(1).get().then((querySnapshot) {
                  int latestNumber = 0;
                  if (querySnapshot.docs.isNotEmpty) {
                    latestNumber = querySnapshot.docs.first['number'] + 1;
                  } else {
                    latestNumber = 1;
                  }

                  // Add data to Firestore under the 'customers' collection
                  customersCollection.add({
                    'name': name,
                    'email': email,
                    'contact': contact,
                    'number': latestNumber, // Add the incremented number to the data
                  }).then((value) {
                    // Data added successfully
                    print('Data added successfully');
                    
                    // Show the generated number in a dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Your Number'),
                        content: Text('Your number is $latestNumber.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }).catchError((error) {
                    // Handle any errors that occur during the process
                    print('Failed to add data: $error');
                  });
                });
              },
              child: Text('Get Number'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CustomerScreen(),
  ));
}
