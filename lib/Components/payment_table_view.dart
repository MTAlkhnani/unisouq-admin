import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentWidget extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;
  const PaymentWidget({super.key, required this.stream});
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
                  final cost = package.get('Cost');
                  final packageID = package.get('PackageID');
                  final paymentID = package.get('PaymentID');
                  final status = package.get('Status');
                  final custEmail = package.get('CustomerEmail');

                  final packageWidget = DataRow(cells: [
                    DataCell(Text(packageID.toString())),
                    DataCell(Text(paymentID.toString())),
                    DataCell(Text(custEmail)),
                    DataCell(Text(cost.toString())),
                    DataCell(Text(status)),
                  ]);
                  packageWidgets.add(packageWidget);
                }
              }
              packageWidgets;
              return DataTable(
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("Package ID")),
                  DataColumn(label: Text("Payment ID")),
                  DataColumn(label: Text("Customer Email")),
                  DataColumn(label: Text("cost")),
                  DataColumn(label: Text("Status")),
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
