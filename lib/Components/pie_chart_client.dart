import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Assuming you have a method to retrieve all items, like getStreamAllItems()
Stream<QuerySnapshot<Object?>>? getStreamAllItems() {
  return FirebaseFirestore.instance.collection('responses').snapshots();
}

// Function to determine the top clients from the list of items
List<String> findTopClients(List<DocumentSnapshot> items, int count) {
  Map<String, int> clientCounts = {};

  // Count items bought by each client
  for (var item in items) {
    var clientID = item['clientId'] as String;
    clientCounts[clientID] = (clientCounts[clientID] ?? 0) + 1;
  }

  // Sort clients by count in descending order
  var sortedClients = clientCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Get the top 'count' clients
  var topClients = sortedClients.take(count).map((e) => e.key).toList();

  return topClients; // Return the list of top client IDs
}

class TopClientPieChart extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;

  const TopClientPieChart({Key? key, required this.stream}) : super(key: key);

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

          // Retrieve top 5 client IDs
          var topClientIDs = findTopClients(items, 5);

          // Fetch top clients' names
          var clientsFutureList = topClientIDs.map((clientID) =>
              FirebaseFirestore.instance
                  .collection('User')
                  .doc(clientID)
                  .get());

          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(clientsFutureList),
            builder: (context, clientSnapshots) {
              if (clientSnapshots.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                    width: 10, height: 10, child: CircularProgressIndicator());
              }
              if (clientSnapshots.hasError) {
                return Text('Error: ${clientSnapshots.error}');
              }

              // Extract top clients' names
              var topClientNames = clientSnapshots.data!
                  .map((snapshot) =>
                      '${snapshot.get('FirstName')} ${snapshot.get('LastName')}')
                  .toList();

              // Count items bought by each top client
              Map<String, int> clientCounts = {};
              for (var item in items) {
                var clientID = item['clientId'] as String;
                if (topClientIDs.contains(clientID)) {
                  clientCounts[clientID] = (clientCounts[clientID] ?? 0) + 1;
                }
              }

              // Create PieChartSectionData for each client with random colors
              List<PieChartSectionData> sections = [];
              var random = Random(); // Create an instance of Random class
              for (int i = 0; i < topClientIDs.length; i++) {
                var clientID = topClientIDs[i];
                var clientName = topClientNames[i];
                var count = clientCounts[clientID] ?? 0;
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
                        '$clientName\n$count $item', // Concatenate name and count
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
                    'Top Clients',
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
