import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserWidget extends StatefulWidget {
  final Stream<QuerySnapshot<Object?>>? stream;

  const UserWidget({super.key, required this.stream});

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class UserBanInfo {
  DocumentSnapshot userDoc;
  bool isBanned;

  UserBanInfo({required this.userDoc, this.isBanned = false});
}

class _UserWidgetState extends State<UserWidget> {
  List<UserBanInfo> usersList = []; // Updated list to include ban status

  @override
  void initState() {
    super.initState();
    widget.stream?.listen((QuerySnapshot snapshot) {
      updateUsersList(snapshot.docs);
    });
  }

  Future<void> updateUsersList(List<DocumentSnapshot> docs) async {
    // Create a list of futures to check the ban status for all users concurrently
    var banStatusFutures = <Future<bool>>[];
    for (var doc in docs) {
      banStatusFutures.add(
        FirebaseFirestore.instance.collection('banned_users').doc(doc.id).get().then((doc) => doc.exists),
      );
    }
    // Wait for all futures to complete
    var banStatuses = await Future.wait(banStatusFutures);
    // Combine user documents with their ban statuses
    var newList = List.generate(docs.length, (index) {
      return UserBanInfo(userDoc: docs[index], isBanned: banStatuses[index]);
    });
    // Update the state once with the new list
    if (mounted) {
      setState(() {
        usersList = newList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildUserTable(),
        const SizedBox(
          height: 40.0,
        ),
      ],
    );
  }

  Widget buildUserTable() {
    List<DataRow> userWidgets = usersList.map((userBanInfo) {
      final user = userBanInfo.userDoc;
      final email = user.get('Email')?.toString() ?? 'N/A';
      final firstName = user.get('FirstName')?.toString() ?? 'N/A';
      final lastName = user.get('LastName')?.toString() ?? 'N/A';
      final phone = user.get('Phone')?.toString() ?? 'N/A';
      final userID = user.get('UserId')?.toString() ?? 'N/A';

      return DataRow(cells: [
        DataCell(Text(userID)),
        DataCell(Text(firstName)),
        DataCell(Text(lastName)),
        DataCell(Text(email)),
        DataCell(Text(phone)),
        DataCell(ElevatedButton(
          onPressed: () => userBanInfo.isBanned
              ? _showUnbanConfirmationDialog(context, userBanInfo, userID)
              : _showConfirmationDialog(context, userBanInfo, userID),
          child: Text(userBanInfo.isBanned ? 'Unban' : 'Ban'),
        )),
      ]);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text("User ID")),
                DataColumn(label: Text("First Name")),
                DataColumn(label: Text("Last Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Actions")),
              ],
              rows: userWidgets,
            ),
          ),
        );
      },
    );
  }



  Future<void> _showConfirmationDialog(BuildContext context,
      UserBanInfo userBanInfo, String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Ban User'),
          content: Text('Are you sure you want to ban this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(), // Dismiss dialog
            ),
            TextButton(
              child: Text('Ban'),
              onPressed: () {
                banUser(userBanInfo, userId);
                Navigator.of(dialogContext)
                    .pop(); // Dismiss dialog and proceed to ban
              },
            ),
          ],
        );
      },
    );
  }

  void banUser(UserBanInfo userBanInfo, String userId) async {
    final email = userBanInfo.userDoc.get('Email') as String? ?? 'no-email';
    try {
      await FirebaseFirestore.instance.collection('banned_users').doc(userId).set({
        'bannedOn': FieldValue.serverTimestamp(),
        'Email': email, // Add the email to banned_users collection
      });
      if (mounted) {
        setState(() {
          userBanInfo.isBanned = true;
        });
      }
    } catch (e) {
      // Handle the error or show an error message
    }
  }

  void unbanUser(UserBanInfo userBanInfo, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('banned_users').doc(userId).delete();
      if (mounted) {
        setState(() {
          userBanInfo.isBanned = false;
        });
      }
    } catch (e) {
      // Handle the error or show an error message
    }
  }


  Future<void> updateBanStatusForUsers() async {
    List<Future<void>> banStatusUpdates = [];

    for (var userBanInfo in usersList) {
      banStatusUpdates.add(
          FirebaseFirestore.instance
              .collection('banned_users')
              .doc(userBanInfo.userDoc.id)
              .get()
              .then((banDoc) {
            // Check mounted to avoid calling setState if the widget is no longer in the tree
            if (mounted) {
              setState(() {
                userBanInfo.isBanned = banDoc.exists;
              });
            }
          })
      );
    }

    await Future.wait(banStatusUpdates);
  }
  Future<void> _showUnbanConfirmationDialog(BuildContext context, UserBanInfo userBanInfo, String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Unban User'),
          content: Text('Are you sure you want to unban this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(), // Dismiss dialog
            ),
            TextButton(
              child: Text('Unban'),
              onPressed: () {
                unbanUser(userBanInfo, userId);
                Navigator.of(dialogContext).pop(); // Dismiss dialog and proceed to unban
              },
            ),
          ],
        );
      },
    );
  }
}


