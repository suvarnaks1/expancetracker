import 'package:expance_tracker_app/core/auth_service.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/auth/login_page.dart';
import 'package:flutter/material.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: SafeArea(
        child: Column(
          children: [
            // Top header with back and settings icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios, color: AppColors.deepPink),
                  Icon(Icons.settings, color: AppColors.deepPink),
                ],
              ),
            ),

            // Avatar, name, email, and "Edit Profile"
            CircleAvatar(
              radius: 48,
              backgroundImage: const AssetImage(
                  'assets/littlebigcolours-ferret-female-hacker-wearing-hoodie-dark-spotlight-glowing-elem-a3fc19e5-5ea3-481d-b8ce-70a30262d15a.jpg'),
            ),
            const SizedBox(height: 12),
            const Text('Jacob Timberline',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('JacobTimber@gmail.com',
                style: TextStyle(color: AppColors.deepPink.withOpacity(0.7))),
            TextButton(
              onPressed: () {},
              child: Text('Edit Profile',
                  style: TextStyle(color: AppColors.mediumPink)),
            ),

            const SizedBox(height: 24),
            // "General" section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'General',
                  style: TextStyle(
                      color: AppColors.deepPink.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 8),
            // General settings tiles
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTile(
                      icon: Icons.location_on_outlined,
                      title: 'Bank Location',
                      subtitle: '7307 Grand, Ava, Flushing NY1347'),
                  _buildTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'My wallet',
                      subtitle: 'Manage your saved wallet'),

                  const SizedBox(height: 24),
                  // "Account" section
                  Text('Account',
                      style: TextStyle(
                          color: AppColors.deepPink.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  _buildTile(
                    icon: Icons.person_outline,
                    title: 'My Account',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {},
                  ),
                  _buildTile(
                    icon: Icons.logout,
                    title: 'SignOut',
                    onTap: () async {
                      await FirebaseAuthService().signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) =>  LoginPage()),
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
