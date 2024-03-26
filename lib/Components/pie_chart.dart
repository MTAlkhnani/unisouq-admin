import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Import 'dart:math' to use Random class

// Assuming you have a method to retrieve all items, like getStreamAllItems()
Stream<QuerySnapshot<Object?>>? getStreamAllItems() {
  return FirebaseFirestore.instance.collection('Item').snapshots();
}

// Function to determine the top seller from the list of items
List<String> findTopSellers(List<DocumentSnapshot> items, int count) {
  Map<String, int> sellerCounts = {};

  // Count items sold by each seller
  for (var item in items) {
    var sellerID = item['sellerID'] as String;
    sellerCounts[sellerID] = (sellerCounts[sellerID] ?? 0) + 1;
  }

  // Sort sellers by count in descending order
  var sortedSellers = sellerCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Get the top 'count' sellers
  var topSellers = sortedSellers.take(count).map((e) => e.key).toList();

  return topSellers; // Return the list of top seller IDs
}

class TopSellerPieChart extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;

  const TopSellerPieChart({Key? key, required this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Set a specific height, adjust as needed
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                width: 10, height: 10, child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          var items = snapshot.data!.docs;

          // Retrieve top 5 seller IDs
          var topSellerIDs = findTopSellers(items, 5);

          // Fetch top sellers' names
          var sellersFutureList = topSellerIDs.map((sellerID) =>
              FirebaseFirestore.instance
                  .collection('User')
                  .doc(sellerID)
                  .get());

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(sellersFutureList),
            builder: (context, userSnapshots) {
              if (userSnapshots.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    width: 10, height: 10, child: CircularProgressIndicator());
              }
              if (userSnapshots.hasError) {
                return Text('Error: ${userSnapshots.error}');
              }

              // Extract top sellers' names
              var topSellerNames = userSnapshots.data!
                  .map((snapshot) =>
                      '${snapshot.get('FirstName')} ${snapshot.get('LastName')}')
                  .toList();

              // Count items sold by each top seller
              Map<String, int> sellerCounts = {};
              for (var item in items) {
                var sellerID = item['sellerID'] as String;
                if (topSellerIDs.contains(sellerID)) {
                  sellerCounts[sellerID] = (sellerCounts[sellerID] ?? 0) + 1;
                }
              }

              // Create PieChartSectionData for each seller with random colors
              List<PieChartSectionData> sections = [];
              var random = Random(); // Create an instance of Random class
              for (int i = 0; i < topSellerIDs.length; i++) {
                var sellerID = topSellerIDs[i];
                var sellerName = topSellerNames[i];
                var count = sellerCounts[sellerID] ?? 0;
                var item = "Items";
                sections.add(
                  PieChartSectionData(
                    value: count.toDouble(),
                    color: Color.fromRGBO(
                      random.nextInt(256), // Random red value (0 to 255)
                      random.nextInt(256), // Random green value (0 to 255)
                      random.nextInt(256), // Random blue value (0 to 255)
                      1, // Opacity (1 for fully opaque)
                    ),
                    title:
                        '$sellerName\n$count $item', // Concatenate name and count
                    radius: 100,
                    titlePositionPercentageOffset: 0.5, // Center the title
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white), // Style for the title
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Top Sellers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
