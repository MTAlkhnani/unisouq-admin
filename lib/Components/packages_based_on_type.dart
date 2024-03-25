import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TypesBtwDates extends StatefulWidget {
  const TypesBtwDates({Key? key}) : super(key: key);

  @override
  State<TypesBtwDates> createState() => _TypesBtwDatesState();
}

class _TypesBtwDatesState extends State<TypesBtwDates> {
  int _home = 0;
  int _electronics = 0;
  int _clothing = 0;
  int _books = 0;
  int _furniture = 0;

  Stream<QuerySnapshot>? getStreamAllItems() {
    return FirebaseFirestore.instance.collection('Item').snapshots();
  }

  void basedOnTypes(int firstDate, int secondDate) async {
    final instance = FirebaseFirestore.instance;
    final itemCollection = instance.collection('Item');

    final itemSnapshot = await itemCollection.get();

    if (itemSnapshot.docs.isEmpty) {
      setState(() {
        _home = 0;
        _electronics = 0;
        _clothing = 0;
        _books = 0;
        _furniture = 0;
      });
      return;
    }

    int homeCount = 0;
    int electronicsCount = 0;
    int clothingCount = 0;
    int booksCount = 0;
    int furnitureCount = 0;

    for (var itemDoc in itemSnapshot.docs) {
      final category = itemDoc.get('category');
      switch (category) {
        case 'Home':
          homeCount++;
          break;
        case 'Electronics':
          electronicsCount++;
          break;
        case 'Clothing':
          clothingCount++;
          break;
        case 'Books':
          booksCount++;
          break;
        case 'Furniture':
          furnitureCount++;
          break;
        default:
          break;
      }
    }

    setState(() {
      _home = homeCount;
      _electronics = electronicsCount;
      _clothing = clothingCount;
      _books = booksCount;
      _furniture = furnitureCount;
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
      setState(() {
        basedOnTypes(result.start.microsecondsSinceEpoch,
            result.end.microsecondsSinceEpoch);
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
                    const Text("Number of category types between two dates."),
                    IconButton(
                        onPressed: _show, icon: const Icon(Icons.date_range))
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text("Home"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_home'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Electronics"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_electronics'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Clothing"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_clothing'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Books"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_books'),
                  ],
                ),
                const SizedBox(
                  width: 80,
                ),
                Column(
                  children: [
                    const Text("Furniture"),
                    const SizedBox(
                      height: 15,
                    ),
                    Text('$_furniture'),
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
