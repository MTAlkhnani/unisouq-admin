import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unisouq_admin/Components/order_Stute.dart';
import 'package:unisouq_admin/Components/pie_chart_client.dart';

import '../Components/pie_chart.dart';
import '../Components/users_table_view.dart';
import '../Components/items_av_card.dart';
import '../Components/table_view.dart';
import 'create_page.dart';
import 'login_page.dart';
import 'report_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // updateUserEmailInItems();
  }

  Future<void> updateUserEmailInItems() async {
    print('Starting to update data...');
    final userCollection = FirebaseFirestore.instance.collection('User');
    final itemCollection = FirebaseFirestore.instance.collection('Item');

    // Retrieve all users
    final userSnapshot = await userCollection.get();
    for (var userDoc in userSnapshot.docs) {
      final userId =
          userDoc.id; // Assuming the document ID is used as the user ID
      final userEmail = userDoc.get('Email');

      // Query items related to this user
      final itemsSnapshot =
          await itemCollection.where('sellerID', isEqualTo: userId).get();

      // Update each item with the user's email
      for (var itemDoc in itemsSnapshot.docs) {
        await itemCollection.doc(itemDoc.id).update({'user': userEmail});
      }
    }
    print('Done');
  }

  //setting the expansion function for the navigation rail
  bool isExpanded = false;
  Stream<QuerySnapshot<Object?>>? getStreamAllItems() {
    return FirebaseFirestore.instance.collection('Item').snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamAllUsers() {
    return FirebaseFirestore.instance
        .collection('User')
        // .orderBy('PaymentID', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamAllClients() {
    return FirebaseFirestore.instance
        .collection('responses')
        // .orderBy('PaymentID', descending: false)
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
              backgroundColor: const Color.fromRGBO(142, 108, 239, 1),
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
                if (value == 2) {}

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
                    const ItemsAvCard(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TopSellerPieChart(
                                stream: getStreamAllItems(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TopClientPieChart(
                                stream: getStreamAllClients(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 400,
                                child: OrdersStatusCard(),

                                // Your widget content here
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Items",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    TableView(stream: getStreamAllItems()),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Users",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    UserWidget(stream: getStreamAllUsers()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
