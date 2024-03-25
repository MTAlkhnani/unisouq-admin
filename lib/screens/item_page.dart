import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../Components/in_transit_path.dart';

class ItemPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String itemID;
  late final Stream<QuerySnapshot> snapshots;

  ItemPage({super.key, required this.itemID}) {
    snapshots = _firestore
        .collection('Item')
        .where('itemID', isEqualTo: itemID)
        .snapshots();
  }
  final _locatedAtController = TextEditingController();
  Future openDialog(BuildContext context) => showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Edit the package'),
              content: TextField(
                decoration: const InputDecoration(
                    hintText: 'Enter where the package will be delivered next'),
                controller: _locatedAtController,
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('Item')
                        .where('itemID', isEqualTo: itemID)
                        .get()
                        .then((value) {
                      if (value.docs.isNotEmpty) {
                        // final newLocationAt =
                        //     value.docs.first.get('Destination');
                        // final id = value.docs.first.id;

                        // _firestore.collection('packages').doc(id).update({
                        //   'LocatedAt': newLocationAt,
                        //   'Destination': _locatedAtController.text.trim()
                        // });

                        // _firestore
                        //     .collection('Location History')
                        //     .where('PackageID', isEqualTo: packageID)
                        //     .where('Status', isEqualTo: "In")
                        //     .get()
                        //     .then((history) {
                        //   _firestore
                        //       .collection('Location History')
                        //       .doc(history.docs.first.id)
                        //       .update({
                        //     'Status': "Out",
                        //   });
                        //   _firestore.collection('Location History').add({
                        //     'PackageID': packageID,
                        //     'Location': newLocationAt,
                        //     'LocatedNumber':
                        //         history.docs.first.get('LocatedNumber') + 1,
                        //     'Status': 'In',
                        //   });
                        // });

                        //.update({}).;
                      }
                    });

                    _locatedAtController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Submit'),
                ),
                TextButton(
                    onPressed: () async {
                      await _firestore
                          .collection('Item')
                          .where('itemID', isEqualTo: itemID)
                          .get()
                          .then((value) {
                        if (value.docs.isNotEmpty) {
                          final id = value.docs.first.id;
                          FirebaseFirestore.instance
                              .collection('Item')
                              .doc(id)
                              .delete();

                          // _firestore
                          //     .collection('Location History')
                          //     .where('PackageID', isEqualTo: packageID)
                          //     .get()
                          //     .then((history) {
                          //   history.docs.forEach((element) {
                          //     element.reference.delete();
                          //   });
                          // });

                          // FirebaseFirestore.instance
                          //     .collection("Payments")
                          //     .where('PackageID', isEqualTo: packageID)
                          //     .where('Status', isEqualTo: 'Incompleted')
                          //     .get()
                          //     .then((payments) {
                          //   if (payments.docs.isNotEmpty) {
                          //     FirebaseFirestore.instance
                          //         .collection("Payments")
                          //         .doc(payments.docs.first.id)
                          //         .delete();
                          //   }
                          // });
                        }
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _locatedAtController.clear();
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            )),
      );
  // Future sendEmail({
  //   required String name,
  //   required String email,
  //   required String id,
  //   required String status,
  // }) async {
  //   final serviceId = 'service_ktkrkvd';
  //   final templateId = 'template_trprxb2';
  //   final userId = 'MZ6rv3LfKqF9jDjp5';
  //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       'service_id': serviceId,
  //       'template_id': templateId,
  //       'user_id': userId,
  //       'template_params': {
  //         'user_name': name,
  //         'user_email': email,
  //         'status': status,
  //         'id': id,
  //       }
  //     }),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back)),
              ),
              Center(
                child: StreamBuilder<QuerySnapshot>(
                  stream: snapshots,
                  builder: (context, snapshot) {
                    List<DataRow> itemWidgets = [];
                    String desc = ""; // Default description
                    List<String> imageUrls =
                        []; // Default empty list for images

                    if (snapshot.hasData) {
                      final items = snapshot.data!.docs;
                      for (var item in items) {
                        final sellerID = item.get('sellerID');
                        final itemID = item.get('itemID');
                        final category = item.get('category');
                        final status = item.get('status');
                        final user = item.get('user');
                        final itemName = item.get('title');
                        final price = item.get('price');
                        final condition = item.get('condition');
                        desc = item.get(
                            'description'); // Assuming single item for simplicity
                        final discPrice = item.get('discountedPrice');
                        imageUrls = List.from(
                            item.get('imageURLs')); // Make sure it's a list

                        final itemWidget = DataRow(cells: [
                          DataCell(Text(itemID.toString())),
                          DataCell(Text(sellerID)),
                          DataCell(Text(status)),
                          DataCell(Text(category)),
                          DataCell(Text(user)),
                          DataCell(Text(itemName)),
                          DataCell(Text(price.toString())),
                          DataCell(Text(discPrice.toString())),
                          DataCell(Text(condition)),
                          DataCell(
                            TextButton(
                              child: const Text("Delete Item"),
                              onPressed: () {
                                openDialog(context);
                              },
                            ),
                          ),
                        ]);
                        itemWidgets.add(itemWidget);
                      }
                    }

                    return Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis
                                  .horizontal, // Enable horizontal scrolling
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: constraints
                                        .maxWidth), // Ensures it spans the min screen width
                                child: DataTable(
                                  headingRowColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) => Colors.grey.shade200),
                                  columns: const [
                                    DataColumn(label: Text("Item ID")),
                                    DataColumn(label: Text("Seller ID")),
                                    DataColumn(label: Text("Status")),
                                    DataColumn(label: Text("Category")),
                                    DataColumn(label: Text("Seller Email")),
                                    DataColumn(label: Text("Item Name")),
                                    DataColumn(label: Text("Price")),
                                    DataColumn(label: Text("Discounted Price")),
                                    DataColumn(label: Text("Condition")),
                                    DataColumn(label: Text("")),
                                  ],
                                  rows: itemWidgets,
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Description: $desc",
                            style: TextStyle(
                              fontSize: 18, // Make the font larger
                              fontWeight: FontWeight.bold, // Make the font bold
                            ),
                          ),
                        ),

                        // Title for Images Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: Text(
                            "Images",
                            style: TextStyle(
                              fontSize: 16, // Size for the "Images" title
                              fontWeight: FontWeight
                                  .bold, // Bold for the "Images" title
                            ),
                          ),
                        ),

                        // Images Display Section
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: imageUrls.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: imageUrls.map((url) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Image.network(
                                        url,
                                        width: 400,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child; // Image is fully loaded
                                          return Center(
                                            // Display a CircularProgressIndicator while the image is loading
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Text("No images available"),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Center(
              //   child: ElevatedButton(
              //       onPressed: () async {
              //         var status = '';
              //         var packageIDD = '';
              //         var email = '';
              //         var name = '';

              //         await _firestore
              //             .collection('packages')
              //             .where('PackageID', isEqualTo: packageID)
              //             .get()
              //             .then((value) {
              //           if (value.docs.isNotEmpty) {
              //             final id = value.docs.first.id;
              //             FirebaseFirestore.instance
              //                 .collection('packages')
              //                 .doc(id)
              //                 .get()
              //                 .then((value) {
              //               status = value.get("Status");
              //               packageIDD = value.get("PackageID").toString();
              //               email = value.get('CustomerEmail');
              //             });
              //           }
              //         });
              //         await _firestore
              //             .collection('Customer')
              //             .where('Email', isEqualTo: email.toLowerCase())
              //             .get()
              //             .then((value) {
              //           if (value.docs.isNotEmpty) {
              //             final id = value.docs.first.id;
              //             FirebaseFirestore.instance
              //                 .collection('Customer')
              //                 .doc(id)
              //                 .get()
              //                 .then((value) {
              //               name = value.get('CustomerName');
              //             });
              //           }
              //         });
              //         sendEmail(
              //             name: name,
              //             email: email,
              //             id: packageIDD,
              //             status: status);
              //       },
              //       child: const Text('Notify User')),
              // ),
              //Now let's set the pagination
              const SizedBox(
                height: 40.0,
              ),
              // InTransitPath(packageID: packageID, status: status),
              // Item Description Section
              // Text(
              //   "Item Description",
              //   style: Theme.of(context).textTheme.headline6,
              // ),
              // SizedBox(height: 10),
              // StreamBuilder<QuerySnapshot>(
              //   stream: snapshots,
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       final items = snapshot.data!.docs;

              //       // Here's where you'd start working with each item
              //       items.forEach((item) {
              //         // Extract 'description' and 'imageURLs' from each item
              //         final desc = item.get('description');
              //         final imageUrls = List.from(item
              //             .get('imageURLs')); // Assuming 'imageURLs' is a list

              //         // Here you can do something with `desc` and `imageUrls`
              //         // For example, display them in the UI
              //       });

              //       // Build your widget based on items here
              //       return ListView.builder(
              //         itemCount: items.length,
              //         itemBuilder: (context, index) {
              //           final item = items[index];
              //           final desc = item.get('description');
              //           final imageUrls = List.from(
              //               item.get('imageURLs')); // Ensure this is a List

              //           // For simplicity, let's just display the description here
              //           // And the first image from the 'imageURLs' list if available
              //           return ListTile(
              //             title: Text(desc),
              //             // leading: imageUrls.isNotEmpty
              //             //     ? Image.network(imageUrls.first, width: 100)
              //             //     : null,
              //           );
              //         },
              //       );
              //     } else if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     }

              //     // Loading state
              //     return CircularProgressIndicator();
              //   },
              // )
            ],
          ),
        ),
      ),
    );
  }
}
