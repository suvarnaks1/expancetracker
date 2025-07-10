import 'package:flutter/material.dart';
import 'package:expance_tracker_app/resources/colors.dart'; // Make sure this path is correct

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aboutTexts = [
      "💡 This app helps you easily track your daily expenses and incomes.",
      "📊 You can view your total balance, category-wise spending, and detailed transaction history.",
      "📅 Use filters to analyze your spending habits weekly or monthly.",
      "🔐 Your data is secured using Firebase Authentication and stored safely in Firestore.",
      "🚀 Designed with a clean, responsive interface using Flutter.",
      "📥 Add, update, or delete your expenses with just a few taps.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
        backgroundColor: AppColors.deepPink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightPink2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "📱 Expense Tracker",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...aboutTexts.map(
            (text) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPink1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightPink2),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              "Made with ❤️ using Flutter",
              style: TextStyle(
                color: AppColors.deepPink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
