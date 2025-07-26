import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../resources/colors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final result = await _auth.registerWithEmailAndPassword(
      emailCtrl.text.trim(),
      passCtrl.text.trim(),
    );
    setState(() => _isLoading = false);

    if (result.status == AuthStatus.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),
      );
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
      case AuthStatus.emailAlreadyInUse:
        return 'This email is already registered.';
      case AuthStatus.invalidEmail:
        return 'Invalid email address.';
      case AuthStatus.weakPassword:
        return 'Password is too weak.';
      default:
        return 'Registration failed. Try again.';
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
        decoration: const BoxDecoration(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _doRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            ),
                    child: Text(
                      "Already have an account? Sign in",
                      textAlign: TextAlign.center,
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
