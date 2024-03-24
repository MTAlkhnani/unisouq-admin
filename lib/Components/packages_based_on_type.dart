import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TypesBtwDates extends StatefulWidget {
  const TypesBtwDates({super.key});

  @override
  State<TypesBtwDates> createState() => _TypesBtwDatesState();
}

class _TypesBtwDatesState extends State<TypesBtwDates> {
  int _regularsCount = 0;
  int _fragilesCount = 0;
  int _liquidsCount = 0;
  int _chemicalsCount = 0;

  void basedOnTypesAndTwoDates(int firstDate, int secondDate) async {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(firstDate);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(secondDate);

    final instance = FirebaseFirestore.instance;

    var packagesbtw = instance
        .collection('packages')
        .where('ArrivalDate', isGreaterThan: firstStamp)
        .where('ArrivalDate', isLessThan: secondStamp);

    await packagesbtw.get().then((packages) {
      if (packages.docs.isEmpty) {
        setState(() {
          _regularsCount = 0;
          _fragilesCount = 0;
          _liquidsCount = 0;
          _chemicalsCount = 0;
        });

        return;
      }
      var regulars = [];
      var fragiles = [];
      var liquids = [];
      var chemicals = [];

      for (var package in packages.docs) {
        if (package.get("Type") == "Regular") {
          regulars.add(package);
        }
        if (package.get("Type") == "Fragile") {
          fragiles.add(package);
        }
        if (package.get("Type") == "Liquid") {
          liquids.add(package);
        }
        if (package.get("Type") == "Chemical") {
          chemicals.add(package);
        }
      }
      setState(() {
        _regularsCount = regulars.length;
        _fragilesCount = fragiles.length;
        _liquidsCount = liquids.length;
        _chemicalsCount = chemicals.length;
      });
    });
  }

  void _show() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      currentDate: DateTime.now(),
      saveText: 'Done',
    );

    if (result != null) {
      // Rebuild the UI
      setState(() {
        result.start.microsecondsSinceEpoch;
        basedOnTypesAndTwoDates(result.start.microsecondsSinceEpoch,
            result.end.microsecondsSinceEpoch);
        //_selectedDateRange = result;
      });
    }
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
                Column(
                  children: [
                    const Text("Number of package types between two dates."),
                    IconButton(
                        onPressed: _show, icon: const Icon(Icons.date_range))
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text("Regular"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_regularsCount'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Fragile"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_fragilesCount'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Liquid"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_liquidsCount'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Chemical"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_chemicalsCount'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
