import 'package:expance_tracker_app/core/auth_gate.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'view/auth/login_page.dart';
import 'view/auth/signup_page.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth Demo',
     
      initialRoute: '/authgate',
      routes: {
        '/authgate':(context)=>AuthGate(),
        '/bottomnav':(context)=>BottomNav(),
        '/login': (context) =>  LoginPage(),
        '/signup': (context) =>SignupPage(),
        
      },
    );
  }
}
