import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'table_view.dart';

class PackagesByCustomer extends StatefulWidget {
  const PackagesByCustomer({super.key});

  @override
  State<PackagesByCustomer> createState() => _PackagesByCustomerState();
}

class _PackagesByCustomerState extends State<PackagesByCustomer> {
  bool _selected = false;
  final TextEditingController _emailcontroller = TextEditingController();
  String _email = "";

  Stream<QuerySnapshot<Object?>>? getPackagesOfParticularCustomer(
      String email) {
    return FirebaseFirestore.instance
        .collection('Item')
        .where('user', isEqualTo: email)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("List all items for a particular user"),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _selected = !_selected;
                        _emailcontroller.clear();
                      });
                    },
                    icon: Icon(!_selected
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded)),
                const SizedBox(
                  width: 50,
                )
              ],
            ),
            if (_selected)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: TextField(
                        controller: _emailcontroller,
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                      ),
                    ),
                    //PaymentWidget(stream: getStreamCompletedPayments()),
                    const Divider(),
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
                    TableView(stream: getPackagesOfParticularCustomer(_email)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
