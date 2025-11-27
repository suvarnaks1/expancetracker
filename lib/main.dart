
import 'package:expance_tracker_app/view/profile_settings/account_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// 1. Import Device Preview
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. Wrap the root widget (MyApp) with DevicePreview
  runApp(DevicePreview(
    enabled: true, // Set to false for production release
    builder: (context) => const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Add Device Preview settings to MaterialApp
      //useInheritedMediaQuery: true, // Use MediaQuery from DevicePreview
      locale: DevicePreview.locale(context), // Apply Device Preview's locale
      builder: DevicePreview.appBuilder, // Apply Device Preview's builder

      debugShowCheckedModeBanner: false,
      home: AccountPage(),
      // title: 'Flutter Auth Demo',
      // initialRoute: '/authgate',
      // routes: {
      //   '/authgate': (context) => const AuthGate(),
      //   '/bottomnav': (context) => const BottomNav(),
      //   '/login': (context) => const LoginPage(),
      //   '/signup': (context) => const SignupPage(),
     // },
    );
  }
}
