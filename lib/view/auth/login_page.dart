import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/auth/signup_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuthService _auth = FirebaseAuthService();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

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
            child: Column(
              children: [
                Text('Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    )),
                const SizedBox(height: 16),
                _buildTextField(emailCtrl, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(passCtrl, 'Password', Icons.lock, obscure: true),
                const SizedBox(height: 24),
                _buildButton(
                  context,
                  text: 'Login',
                  onPressed: () async {
                    // your auth logic
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => SignupPage())),
                  child: Text('New user? Sign up',
                      style: TextStyle(color: AppColors.deepPink)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.deepPink),
        labelText: label,
        filled: true,
        fillColor: AppColors.lightPink1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext ctx,
      {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPink,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
