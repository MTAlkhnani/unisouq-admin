import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TypesBtwDates extends StatefulWidget {
  const TypesBtwDates({super.key});

  @override
  State<TypesBtwDates> createState() => _TypesBtwDatesState();
}

class _TypesBtwDatesState extends State<TypesBtwDates> {
  int _home = 0;
  int _electronics = 0;
  int _clothing = 0;
  int _books = 0;
  int _furniture = 0;

  // Stream<QuerySnapshot>? getStreamAllItems() {
  //   return FirebaseFirestore.instance.collection('Item').snapshots();
  // }

  void basedOnTypesAndTwoDates(int firstDate, int secondDate) async {
    Timestamp firstStamp = Timestamp.fromMicrosecondsSinceEpoch(firstDate);
    Timestamp secondStamp = Timestamp.fromMicrosecondsSinceEpoch(secondDate);

    final instance = FirebaseFirestore.instance;
    var itemsBTD = instance
        .collection('Item')
        .where('timestamp', isGreaterThan: firstStamp)
        .where('timestamp', isLessThan: secondStamp);

    await itemsBTD.get().then((items) {
      if (items.docs.isEmpty) {
        setState(() {
          _home = 0;
          _electronics = 0;
          _clothing = 0;
          _books = 0;
          _furniture = 0;
        });
        return;
      }
      var homes = [];
      var electronics = [];
      var clothings = [];
      var books = [];
      var furnitures = [];

      for (var item in items.docs) {
        if (item.get("category") == "Electronics") {
          electronics.add(item);
        }
        if (item.get("category") == "Books") {
          books.add(item);
        }
        if (item.get("category") == "Clothing") {
          clothings.add(item);
        }
        if (item.get("category") == "Home") {
          homes.add(item);
        }
        if (item.get("category") == "Furniture") {
          furnitures.add(item);
        }
      }
      setState(() {
        _home = homes.length;
        _electronics = electronics.length;
        _clothing = clothings.length;
        _books = books.length;
        _furniture = furnitures.length;
      });
    });
  }
  // final itemCollection = instance.collection('Item');

  // final itemSnapshot = await itemCollection.get();

  // if (itemSnapshot.docs.isEmpty) {
  //   setState(() {
  //     _home = 0;
  //     _electronics = 0;
  //     _clothing = 0;
  //     _books = 0;
  //     _furniture = 0;
  //   });
  //   return;
  // }

  // int homeCount = 0;
  // int electronicsCount = 0;
  // int clothingCount = 0;
  // int booksCount = 0;
  // int furnitureCount = 0;

  // for (var itemDoc in itemSnapshot.docs) {
  //   final category = itemDoc.get('category');
  //   switch (category) {
  //     case 'Home':
  //       homeCount++;
  //       break;
  //     case 'Electronics':
  //       electronicsCount++;
  //       break;
  //     case 'Clothing':
  //       clothingCount++;
  //       break;
  //     case 'Books':
  //       booksCount++;
  //       break;
  //     case 'Furniture':
  //       furnitureCount++;
  //       break;
  //     default:
  //       break;
  //   }
  // }

  // setState(() {
  //   _home = homeCount;
  //   _electronics = electronicsCount;
  //   _clothing = clothingCount;
  //   _books = booksCount;
  //   _furniture = furnitureCount;
  // });
// }
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
