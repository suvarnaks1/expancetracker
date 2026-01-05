import 'package:flutter/material.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;

class BillFilterTabs extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const BillFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Upcoming', 'upcoming'),
            const SizedBox(width: 8),
            _buildFilterChip('Overdue', 'overdue'),
            const SizedBox(width: 8),
            _buildFilterChip('Paid', 'paid'),
          ],
        ),
      ),
    );
  }

  // Build individual filter chip
  Widget _buildFilterChip(String label, String value) {
    final isSelected = activeFilter == value;
    
    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepPink : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.deepPink : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.deepPink.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}