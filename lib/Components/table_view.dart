import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/package_page.dart';

class TableView extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;
  const TableView({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: ((context, snapshot) {
              List<DataRow> itemWidgets = [];
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

                  /*
                  other data for the item as well
                  */

                  final condition = item.get('condition');
                  // final desc = item.get('description');
                  // final discPrice = item.get('discountedPrice');
                  // final imageUrls = item.get('imageURLs');

                  final packageWidget = DataRow(cells: [
                    DataCell(Text(sellerID.toString())),
                    DataCell(Text(category)),
                    DataCell(Text(status
                        // style: TextStyle(color: statusColor),
                        )),
                    DataCell(Text(user)),
                    DataCell(
                      TextButton(
                        child: const Text("Show Details"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemPage(
                                      itemID: itemID,
                                    )),
                          );
                        },
                      ),
                    ),
                  ]);
                  itemWidgets.add(packageWidget);
                }
              }
              itemWidgets;
              return DataTable(
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Seller Email")),
                  DataColumn(label: Text("")),
                ],
                rows: itemWidgets,
              );
            })),
        const SizedBox(
          height: 40.0,
        ),
      ],
    );
  }
}
