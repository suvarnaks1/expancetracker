import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/about/about.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:expance_tracker_app/view/privacy/privacy.dart';
import 'package:flutter/material.dart';

class SignoutPage extends StatelessWidget {
  const SignoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
        appBar: AppBar(
        title: Center(child:  Text('Signout')),
        backgroundColor: AppColors.deepPink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        
        child: Column(
          children: [
           

      

            const SizedBox(height: 8),
            // General settings tiles
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 24),
                  // "Account" section
                  Text('Signout',
                      style: TextStyle(
                          color: AppColors.deepPink.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  

                

               
              
                  _buildTile(
                    icon: Icons.logout,
                    title: 'SignOut',
                    onTap: () async {
                      await FirebaseAuthService().signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: AppColors.deepPink),
        title: Text(title, style: TextStyle(color: AppColors.deepPink)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12))
            : null,
        trailing: Icon(Icons.chevron_right, color: AppColors.deepPink),
        onTap: onTap,
      ),
    );
  }
}
