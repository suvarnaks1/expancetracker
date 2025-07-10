import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
       builder: (context, snapshot){
if(snapshot.connectionState==ConnectionState.waiting){
  return Scaffold(body: Center(child: CircularProgressIndicator(

  ),),);
}else if(snapshot.hasData){
  return BottomNav();

}else{
  return LoginPage();
}

       });
  }
}