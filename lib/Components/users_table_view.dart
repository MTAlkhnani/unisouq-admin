import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatelessWidget {
  final Stream<QuerySnapshot<Object?>>? stream;
  const UserWidget({super.key, required this.stream});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: ((context, snapshot) {
              List<DataRow> userWidgets = [];
              if (snapshot.hasData) {
                final users = snapshot.data!.docs;
                for (var user in users) {
                  final email = user.get('Email');
                  final firstName = user.get('FirstName');
                  final lastName = user.get('LastName');
                  final phone = user.get('Phone');
                  final userID = user.get('UserId');

                  final packageWidget = DataRow(cells: [
                    DataCell(Text(userID.toString())),
                    DataCell(Text(firstName.toString())),
                    DataCell(Text(lastName.toString())),
                    DataCell(Text(email.toString())),
                    DataCell(Text(phone.toString())),
                  ]);
                  userWidgets.add(packageWidget);
                }
              }
              userWidgets;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.grey.shade200),
                  columns: const [
                    DataColumn(label: Text("User ID")),
                    DataColumn(label: Text("First Name")),
                    DataColumn(label: Text("Last Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Phone")),
                  ],
                  rows: userWidgets,
                ),
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
