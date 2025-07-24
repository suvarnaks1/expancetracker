import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../resources/colors.dart';

class SignupPage extends StatelessWidget {
  final FirebaseAuthService _auth = FirebaseAuthService();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lightPink1, AppColors.lightPink2],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
                _buildTextField(emailCtrl, 'Email', Icons.email),
                const SizedBox(height: 16),
                _buildTextField(passCtrl, 'Password', Icons.lock, obscure: true),
                const SizedBox(height: 32),
                _buildButton(
                  text: 'Register',
                  onPressed: () async {
                    final email = emailCtrl.text.trim();
                    final password = passCtrl.text.trim();
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter all fields")),
                      );
                      return;
                    }
                    try {
                      final user = await _auth.registerWithEmailAndPassword(email, password);
                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Registration Successful")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => BottomNav()),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Registration Failed: $e")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
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
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
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

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final gradient = LinearGradient(
      colors: [AppColors.mediumPink, AppColors.deepPink],
    );

    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
