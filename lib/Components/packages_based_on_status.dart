import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'table_view.dart';

class StatusBtwDates extends StatefulWidget {
  const StatusBtwDates({super.key});

  @override
  State<StatusBtwDates> createState() => _StatusBtwDatesState();
}

class _StatusBtwDatesState extends State<StatusBtwDates> {
  bool _selected = false;
  bool _selectedArrow = false;

  var _firstDate;
  var _secondDate;

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      setState(() {
        _firstDate = result.start.microsecondsSinceEpoch;
        _secondDate = result.end.microsecondsSinceEpoch;
        _selected = true;
      });
    }
  }

  Stream<QuerySnapshot<Object?>>? getStreamPackagesDeliveredAndTwoDates() {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(_firstDate);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(_secondDate);

    return FirebaseFirestore.instance
        .collection('packages')
        .where('Status', isEqualTo: 'Delivered')
        .where('ArrivalDate', isGreaterThan: firstStamp)
        .where('ArrivalDate', isLessThan: secondStamp)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamPackagesLostAndTwoDates() {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(_firstDate);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(_secondDate);

    return FirebaseFirestore.instance
        .collection('packages')
        .where('Status', isEqualTo: 'Lost')
        .where('ArrivalDate', isGreaterThan: firstStamp)
        .where('ArrivalDate', isLessThan: secondStamp)
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>>? getStreamPackagesDelayedAndTwoDates() {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(_firstDate);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(_secondDate);

    return FirebaseFirestore.instance
        .collection('packages')
        .where('Status', isEqualTo: 'Delayed')
        .where('ArrivalDate', isGreaterThan: firstStamp)
        .where('ArrivalDate', isLessThan: secondStamp)
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
                const Text(
                    "List of package between two dates beased on Status"),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedArrow = !_selectedArrow;
                      });
                    },
                    icon: Icon(!_selectedArrow
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded)),
                const SizedBox(
                  width: 50,
                )
              ],
            ),
            if (_selectedArrow)
              Row(
                children: [
                  const Text(""),
                  const Spacer(),
                  IconButton(
                      onPressed: _show, icon: const Icon(Icons.date_range)),
                  const SizedBox(
                    width: 50,
                  )
                ],
              ),
            if (_selected && _selectedArrow)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Delivered Packages",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TableView(stream: getStreamPackagesDeliveredAndTwoDates()),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Delayed Packages",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TableView(stream: getStreamPackagesDelayedAndTwoDates()),
                    const Divider(),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 0),
                      child: const Text(
                        "Lost Packages",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(0, 0, 139, 1),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TableView(stream: getStreamPackagesLostAndTwoDates()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    ;
  }
}
