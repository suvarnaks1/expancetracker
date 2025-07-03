import 'package:expance_tracker_app/resources/colors.dart' show AppColors;
import 'package:flutter/material.dart';


class FinanceDashboard extends StatelessWidget {
  const FinanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CircleAvatar(backgroundImage: AssetImage('assets/littlebigcolours-ferret-female-hacker-wearing-hoodie-dark-spotlight-glowing-elem-a3fc19e5-5ea3-481d-b8ce-70a30262d15a.jpg')),
                    const SizedBox(width: 8),
                    const Text('Hey, Jacob!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  ]),
                  Icon(Icons.notifications_none, color: AppColors.deepPink),
                ],
              ),
              const SizedBox(height: 24),
              
              // Total Balance
              const Text('\$4,586.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text('Total Balance', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              // Income & Expense cards
              Row(
                children: [
                  _buildInfoCard('Income', '\$2,450.00', Colors.green.shade100, Icons.arrow_upward),
                  const SizedBox(width: 16),
                  _buildInfoCard('Expense', '-\$710.00', Colors.red.shade100, Icons.arrow_downward),
                ],
              ),

              const SizedBox(height: 24),
              const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Sample list
              Expanded(
                child: ListView(
                  children: [
                    _buildTransaction('Shoes', 'Sneakers Nike', '-\$40.00', AppColors.lightPink1, Icons.shopping_bag),
                    const SizedBox(height: 8),
                    _buildTransaction('Transport', 'Topup Uber', '-\$20.00', AppColors.lightPink2, Icons.directions_car),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String amount, Color bgColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
          const SizedBox(width: 12),
          Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildTransaction(String title, String subtitle, String amount, Color bg, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, color: AppColors.deepPink)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
      ]),
    );
  }
}
