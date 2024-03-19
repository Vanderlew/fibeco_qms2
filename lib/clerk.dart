import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ClerkScreen extends StatefulWidget {
  @override
  _ClerkScreenState createState() => _ClerkScreenState();
}

class _ClerkScreenState extends State<ClerkScreen> {
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers'); // Reference to the 'customers' collection

  String _currentNumber = '';

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
                    _getNextNumber();
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

  void _getNextNumber() {
    print('Fetching current number...');
    customersCollection
        .where('status', isEqualTo: 'Now Serving')
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final servingNumber = querySnapshot.docs.first['number'].toString();
        setState(() {
          _currentNumber = servingNumber;
        });
        print('Current number fetched: $_currentNumber');
      } else {
        setState(() {
          _currentNumber = 'No customers being served';
        });
        print('No customers being served');
      }
    }).catchError((error) {
      print('Error fetching current number: $error');
    });
  }

  void serveCustomer(String customerId) async {
  try {
    // Update customer status to 'Now Serving'
    await customersCollection.doc(customerId).update({'status': 'Now Serving'});
    // Fetch the document snapshot
    DocumentSnapshot<Map<String, dynamic>> docSnapshot =
        (await customersCollection.doc(customerId).get()) as DocumentSnapshot<Map<String, dynamic>>;
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



}
