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
              List<DataRow> packageWidgets = [];
              if (snapshot.hasData) {
                final packages = snapshot.data!.docs;
                for (var package in packages) {
                  final packageID = package.get('PackageID');
                  final type = package.get('Type');
                  final status = package.get('Status');
                  final fdd = package.get('FDD');
                  Color statusColor = Colors.black;
                  if (status.toString().toLowerCase() == 'received') {
                    statusColor = const Color.fromRGBO(0, 100, 0, 1);
                  } else if (status.toString().toLowerCase() == 'intransit') {
                    statusColor = Colors.blue;
                  } else if (status.toString().toLowerCase() == 'delayed') {
                    statusColor = Colors.orange;
                  } else if (status.toString().toLowerCase() == 'lost') {
                    statusColor = Colors.red;
                  } else if (status.toString().toLowerCase() == 'processing') {
                    statusColor = Colors.green;
                  } else if (status.toString().toLowerCase() == 'delivered') {
                    statusColor = Colors.green;
                  }
                  final packageWidget = DataRow(cells: [
                    DataCell(Text(packageID.toString())),
                    DataCell(Text(type)),
                    DataCell(Text(
                      status,
                      style: TextStyle(color: statusColor),
                    )),
                    DataCell(Text(fdd)),
                    DataCell(
                      TextButton(
                        child: const Text("Show Details"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PackagePage(
                                      packageID: packageID,
                                      status: status,
                                    )),
                          );
                        },
                      ),
                    ),
                  ]);
                  packageWidgets.add(packageWidget);
                }
              }
              packageWidgets;
              return DataTable(
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Final Destination")),
                  DataColumn(label: Text("")),
                ],
                rows: packageWidgets,
              );
            })),
        //Now let's set the pagination
        const SizedBox(
          height: 40.0,
        ),
      ],
    );
  }
}
