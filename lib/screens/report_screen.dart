import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Components/packages_based_on_status.dart';
import '../Components/packages_based_on_type.dart';
import '../Components/packages_by_customer.dart';
import '../Components/payments_based_on_status.dart';
import 'dashboard_screen.dart';

class ReportScreen extends StatefulWidget {
  static const String route = "report-screen";
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isExpanded = false;

  void basedOnStatusAndTwoDates(String firstDate, String secondDate) async {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(
        DateTime.parse(firstDate).microsecondsSinceEpoch);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(
        DateTime.parse(secondDate).microsecondsSinceEpoch);

    final instance = FirebaseFirestore.instance;

    var packagesbtw = instance
        .collection('packages')
        .where('ArrivalDate', isGreaterThan: firstStamp)
        .where('ArrivalDate', isLessThan: secondStamp)
        .where('Status', whereIn: ['Delivered', 'Delayed', 'Lost']).orderBy(
            'Status',
            descending: false);

    await packagesbtw.get().then((packages) {
      if (packages.docs.isEmpty) {
        return;
      }
      var delivereds = [];
      var delayeds = [];
      var losts = [];
      for (var package in packages.docs) {
        if (package.get("Status") == "Delivered") {
          delivereds.add(package);
        }
        if (package.get("Status") == "Delayed") {
          delayeds.add(package);
        }
        if (package.get("Status") == "Lost") {
          losts.add(package);
        }
      }
      print("--------- Two Dates ---------");
      print("Delivereds: ${delivereds.length}");
      print("Delayeds: ${delayeds.length}");
      print("Losts: ${losts.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          //Let's start by adding the Navigation Rail
          NavigationRail(
              extended: isExpanded,
              backgroundColor: const Color.fromRGBO(0, 0, 139, 1),
              unselectedIconTheme:
                  const IconThemeData(color: Colors.white, opacity: 1),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.white,
              ),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart),
                  label: Text("Reports"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text("Profile"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text("Log out"),
                ),
              ],
              onDestinationSelected: (value) {
                if (value == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                  );
                }
              },
              selectedIndex: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //let's add the navigation menu for this project
                    IconButton(
                      onPressed: () {
                        //let's trigger the navigation expansion
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      icon: const Icon(Icons.menu),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const TypesBtwDates(),
                    const StatusBtwDates(),
                    const PaymentsStatusReport(),
                    const PackagesByCustomer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      //Center(
      //  child: BtwDates(),
      //),
    );
  }
}
