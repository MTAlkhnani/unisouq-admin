import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/Components/payment_table_view.dart';
import '../Components/packages_av_card.dart';
import '../Components/table_view.dart';
import 'create_page.dart';
import 'login_page.dart';
import 'report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //setting the expansion function for the navigation rail
  bool isExpanded = false;

  Stream<QuerySnapshot<Object?>>? getStreamAllPackages() {
    return FirebaseFirestore.instance
        .collection('packages')
        .orderBy('PackageID', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamAllPayments() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .orderBy('PaymentID', descending: false)
        .snapshots();
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
                if (value == 1) {
                  Navigator.of(context)
                      .pushReplacementNamed(ReportScreen.route);
                }
                if (value == 3) {
                  Navigator.of(context).pushReplacementNamed(LogInPage.route);
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
                      height: 20.0,
                    ),
                    //Now let's start with the dashboard main
                    const PackagesAvCard(),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Packages",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TableView(stream: getStreamAllPackages()),
                    // TableView(
                    //     stream:
                    //         getPackagesOfParticularCustomer("test@test.com")),

                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Payments",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    PaymentWidget(stream: getStreamAllPayments()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      //let's add the floating action button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(0, 0, 139, 1),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePackage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
