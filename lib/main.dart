import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';



import 'screens/create_page.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_page.dart';
import 'screens/report_screen.dart';

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyCz7XWBdkHsqqkTiOVZMISQ0antQrM-8WE",
    authDomain: "uni-souq.firebaseapp.com",
    projectId: "uni-souq",
    storageBucket: "uni-souq.appspot.com",
    messagingSenderId: "1091791953567",
    appId: "1:1091791953567:web:963d4240c1e2a20cc94caa",
    measurementId: "G-84R8B45G72",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(), //change this LogInPage() later
      routes: {
        ReportScreen.route: (context) => const ReportScreen(),
        LogInPage.route: (context) => const LogInPage(),
        

        // CreatePackage.route: (context) => CreatePackage(),
      },
    );
  }
}
