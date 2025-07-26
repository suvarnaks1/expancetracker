import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/auth/signup_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _isLoading = false;

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final email = v.trim();
    final pattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(?:com|in)$',
      caseSensitive: false,
    );
    if (!pattern.hasMatch(email)) return 'Email must end with .com or .in';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be ≥ 6 characters';
    return null;
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _auth.loginWithEmailAndPassword(
      emailCtrl.text.trim(),
      passCtrl.text,
    );
    setState(() => _isLoading = false);

    if (result.status == AuthStatus.success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
      );
    } else {
      final msg = result.message ?? _friendlyMessage(result.status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _friendlyMessage(AuthStatus status) {
    switch (status) {
      case AuthStatus.invalidEmail:
        return 'Please enter a valid email.';
      case AuthStatus.wrongPassword:
        return 'Incorrect password.';
      case AuthStatus.userNotFound:
        return 'No account found. Please sign up.';
      case AuthStatus.userDisabled:
        return 'This account is disabled.';
      case AuthStatus.tooManyRequests:
        return 'Too many attempts. Try again later.';
      default:
        return 'An unexpected error occurred. Try again.';
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightPink1, AppColors.lightPink2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: AppColors.deepPink),
                      labelText: 'Email',
                      filled: true,
                      fillColor: AppColors.lightPink1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: AppColors.deepPink),
                      labelText: 'Password',
                      filled: true,
                      fillColor: AppColors.lightPink1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupPage()),
                            ),
                    child: Text(
                      'New user? Sign up',
                      style: TextStyle(color: AppColors.deepPink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
