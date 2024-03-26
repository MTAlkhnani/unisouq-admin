import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle onTap actions here
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    _buildOrderIcon(),
                  ],
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildOrderSection(
                    title: "Orders in Progress",
                    status: "in_progress",
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildOrderSection(
                    title: "Shipped Orders",
                    status: "shipped",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderIcon() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.description, color: Colors.purple),
      ),
    );
  }

  Widget _buildOrderSection({required String title, required String status}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _getStream(status),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              int count = snapshot.data!.docs.length;
              return _buildCountContainer(count);
            }
          },
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getStream(String status) {
    if (status == "in_progress") {
      return FirebaseFirestore.instance.collection('requests').snapshots();
    } else if (status == "shipped") {
      return FirebaseFirestore.instance
          .collection('responses')
          .where('status', isEqualTo: "accepted")
          .snapshots();
    } else {
      throw ArgumentError("Invalid status: $status");
    }
  }

  Widget _buildCountContainer(int count) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        "$count",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
