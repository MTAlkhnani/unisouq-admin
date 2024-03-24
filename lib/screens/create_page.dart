import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePackage extends StatelessWidget {
  static const String route = "create-package-screen";

  final _formKey = GlobalKey<FormBuilderState>();
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 50, 0, 0),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 500, vertical: 0),
              child: Center(
                child: FormBuilder(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add a package',
                          style: TextStyle(fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: FormBuilderTextField(
                            name: 'status',
                            decoration: const InputDecoration(
                              label: Text('Status'),
                            ),
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the status'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'arrivalDate',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the arrival date'),
                            decoration: const InputDecoration(
                              label: Text('Arrival Date'),
                              hintText: 'must be in yyyy-mm-dd',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'cost',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the cost'),
                            decoration: const InputDecoration(
                              label: Text('Cost'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'custEmail',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the email'),
                            decoration: const InputDecoration(
                              label: Text('Customer Email'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'dest',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the destination'),
                            decoration: const InputDecoration(
                              label: Text('Destination'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'fdd',
                            validator: FormBuilderValidators.required(
                                errorText:
                                    'Please enter the final destination'),
                            decoration: const InputDecoration(
                              label: Text('Final Destination'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'dim',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the dimension'),
                            decoration: const InputDecoration(
                              label: Text('Dimension'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'insurance',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the insurance'),
                            decoration: const InputDecoration(
                              label: Text('Insurance'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'locatedAt',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the located at'),
                            decoration: const InputDecoration(
                              label: Text('Located At'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'type',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the type'),
                            decoration: const InputDecoration(
                              label: Text('Type'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FormBuilderTextField(
                            name: 'weight',
                            validator: FormBuilderValidators.required(
                                errorText: 'Please enter the weight'),
                            decoration: const InputDecoration(
                              label: Text('Weight'),
                            ),
                          ),
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  final packages = await _firestore
                                      .collection('packages')
                                      .get();
                                  var data = _formKey.currentState!.value;
                                  List date =
                                      data['arrivalDate'].toString().split('-');
                                  int neWPackageID = packages.docs.length + 1;
                                  var timestamp =
                                      Timestamp.fromMicrosecondsSinceEpoch(
                                          DateTime(
                                                  int.parse(date[0]),
                                                  int.parse(date[1]),
                                                  int.parse(date[2]))
                                              .microsecondsSinceEpoch);
                                  _firestore.collection('packages').add({
                                    'PackageID': neWPackageID,
                                    'CustomerEmail': data['custEmail'],
                                    'Cost': data['cost'],
                                    'Status': data['status'],
                                    'Type': data['type'],
                                    'FDD': data['fdd'],
                                    'Destination': data['dest'],
                                    'Insurance': data['insurance'],
                                    'Dimension': data['dim'],
                                    'Weight': data['weight'],
                                    'LocatedAt': data['locatedAt'],
                                    'ArrivalDate': timestamp
                                  });

                                  _firestore.collection('Payments').add({
                                    'PaymentID': packages.docs.length + 1,
                                    'PackageID': neWPackageID,
                                    'CustomerEmail': data['custEmail'],
                                    'Cost': data['cost'],
                                    'Status': 'Incompleted',
                                  });

                                  _firestore
                                      .collection('Location History')
                                      .add({
                                    'PackageID': neWPackageID,
                                    'Location': data['locatedAt'],
                                    'LocatedNumber': 1,
                                    'Status': 'In',
                                  });
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Submit')),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
