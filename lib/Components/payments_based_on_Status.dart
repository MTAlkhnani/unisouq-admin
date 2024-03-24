import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'payment_table_view.dart';

class PaymentsStatusReport extends StatefulWidget {
  const PaymentsStatusReport({super.key});

  @override
  State<PaymentsStatusReport> createState() => _PaymentsStatusReportState();
}

class _PaymentsStatusReportState extends State<PaymentsStatusReport> {
  bool _selected = false;

  Stream<QuerySnapshot<Object?>>? getStreamCompletedPayments() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .where('Status', isEqualTo: 'Completed')
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamInCompletedPayments() {
    return FirebaseFirestore.instance
        .collection('Payments')
        .where('Status', isEqualTo: 'Incompleted')
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
                const Text("List of payments between beased on Status"),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _selected = !_selected;
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
                      child: const Text(
                        "Completed Payments",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    PaymentWidget(stream: getStreamCompletedPayments()),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Incompleted Payments",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    PaymentWidget(stream: getStreamInCompletedPayments()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
