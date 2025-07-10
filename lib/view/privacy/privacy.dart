import 'package:flutter/material.dart';
import 'package:expance_tracker_app/resources/colors.dart'; // Make sure this path is correct

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final privacyStatements = [
      "🔐 Your data is stored securely and is never shared with third parties without your consent.",
      "🛡️ All your financial records and transactions are private and visible only to you.",
      "🔒 We use Firebase Authentication and Firestore to ensure your data is encrypted and safely stored.",
      "📁 We do not collect or store any personal financial data outside your account without your permission.",
      "👤 Your email and profile information are only used to personalize your experience in the app.",
      "🗑️ You can delete your account and associated data at any time from the settings menu.",
      "✅ This app complies with industry-standard data protection practices.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.deepPink,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: privacyStatements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightPink1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightPink2),
          ),
          child: Text(
            privacyStatements[index],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
