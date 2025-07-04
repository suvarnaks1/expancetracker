import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late StreamSubscription<User?> _sub;
  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    _sub = AuthService().authStateChanges.listen((user) {
      if (user != null && !user.emailVerified) {
        _startReloadTimer();
      } else {
        _stopReloadTimer();
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _stopReloadTimer();
    super.dispose();
  }

  void _startReloadTimer() {
    _reloadTimer ??= Timer.periodic(Duration(seconds: 5), (_) {
      AuthService().reloadUser();
    });
  }

  void _stopReloadTimer() {
    _reloadTimer?.cancel();
    _reloadTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snap.data;
        if (user != null && user.emailVerified) {
          return const BottomNav();
        }
        // Unverified or null—send to login/signup flow
        return const LoginPage();
      },
    );
  }
}
