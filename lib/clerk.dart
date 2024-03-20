import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ClerkScreen extends StatefulWidget {
  @override
  _ClerkScreenState createState() => _ClerkScreenState();
}

class _ClerkScreenState extends State<ClerkScreen> {
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers'); // Reference to the 'customers' collection

  String _currentNumber = '';
  AsyncSnapshot<QuerySnapshot>? _currentSnapshot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Queue Management System - Clerk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Now Serving: $_currentNumber',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 200), // Add spacing between "Now Serving" and the button
                ElevatedButton(
                  onPressed: () {
                    // Update the "Now Serving" number to the next number in the queue
                    _getNextNumber(_currentSnapshot!);
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: customersCollection.snapshots(), // Listen to changes in the 'customers' collection
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No data available"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final customerData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(customerData['name']),
                      subtitle: Text(customerData['address']),
                      trailing: Text('Number: ${customerData['number']}'), // Display the number
                      onTap: () {
                        // Show dialog to confirm serving this customer
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Serve Customer?'),
                            content: Text('Do you want to serve ${customerData['name']}?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Serve the customer
                                  serveCustomer(snapshot.data!.docs[index].id);
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text('Serve'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _getNextNumber(AsyncSnapshot<QuerySnapshot>? snapshot) {
    if (snapshot != null && snapshot.hasData) {
      customersCollection
          .where('status', isEqualTo: 'Waiting')
          .orderBy('number')
          .limit(1)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final nextNumber = querySnapshot.docs.first['number'].toString();
          setState(() {
            _currentNumber = nextNumber;
            snapshot.data!.docs.removeAt(0); // Remove the current customer from the list
          });
          print('Next number fetched: $_currentNumber');
          customersCollection.doc(querySnapshot.docs.first.id).update({'status': 'Now Serving'});
          // Notify the customer
          notifyCustomer(querySnapshot.docs.first as QueryDocumentSnapshot<Map<String, dynamic>>);


        } else {
          setState(() {
            _currentNumber = 'No customers waiting';
          });
          print('No customers waiting');
        }
      }).catchError((error) {
        print('Error fetching next number: $error');
      });
    } else {
      setState(() {
        _currentNumber = 'No customers being served';
      });
      print('No customers being served');
    }
  }

  void serveCustomer(String customerId) async {
    try {
      // Update customer status to 'Now Serving'
      await customersCollection.doc(customerId).update({'status': 'Now Serving'});
      // Fetch the document snapshot
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await customersCollection.doc(customerId).get() as DocumentSnapshot<Map<String, dynamic>>;
      // Retrieve the "number" field from the snapshot data
      String servingNumber = docSnapshot.data()!['number'].toString();
      // Update _currentNumber
      setState(() {
        _currentNumber = servingNumber;
      });
      print('Serving customer with ID: $customerId');
    } catch (error) {
      print('Error serving customer: $error');
    }
  }

  void notifyCustomer(QueryDocumentSnapshot<Map<String, dynamic>> customerDoc) async {
    final String? email = customerDoc.data()['email'] as String?;
    final String? contact = customerDoc.data()['contact'] as String?;


    if (email != null && contact != null) {
    // Send email notification
    final smtpServer = gmail('your@gmail.com', 'yourPassword');
    final message = Message()
      ..from = Address('your@gmail.com', 'Your Name')
      ..recipients.add(email)
      ..subject = 'Your Turn to Be Served!'
      ..text = 'Please proceed to the counter for assistance. Your contact: $contact';

    try {
      await send(message, smtpServer);
      print('Email notification sent to: $email');
    } catch (e) {
      print('Error sending email notification: $e');
    }

    // Send message notification
    // Add your message notification implementation here using the contact information
  } else {
    print('Email or contact is null');
}
}
}