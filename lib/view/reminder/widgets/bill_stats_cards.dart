import 'package:flutter/material.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;

class BillStatsCards extends StatelessWidget {
  final int upcomingCount;
  final int overdueCount;
  final int paidCount;

  const BillStatsCards({
    super.key,
    required this.upcomingCount,
    required this.overdueCount,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Upcoming bills card
          Expanded(
            child: _buildStatCard(
              title: 'Upcoming',
              value: upcomingCount.toString(),
              subtitle: 'Bills due',
              icon: Icons.calendar_today,
              color: AppColors.lightPink2,
              textColor: AppColors.deepPink,
            ),
          ),
          const SizedBox(width: 12),
          
          // Overdue bills card
          Expanded(
            child: _buildStatCard(
              title: 'Overdue',
              value: overdueCount.toString(),
              subtitle: 'Need attention',
              icon: Icons.warning,
              color: const Color(0xFFFFE6E6),
              textColor: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          
          // Paid bills card
          Expanded(
            child: _buildStatCard(
              title: 'Paid',
              value: paidCount.toString(),
              subtitle: 'Completed',
              icon: Icons.check_circle,
              color: const Color(0xFFE6FFE6),
              textColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // Build individual stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and value row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}