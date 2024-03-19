import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServingScreen extends StatelessWidget {
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serving Screen'),
      ),
      body: StreamBuilder(
        stream: customersCollection.where('status', isEqualTo: 'Now Serving').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No customer currently being served"));
          }

          final servingNumber = snapshot.data!.docs.first['number'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currently Serving: $servingNumber',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
