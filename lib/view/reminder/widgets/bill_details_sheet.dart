import 'package:expance_tracker_app/view/reminder/services/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expance_tracker_app/model/bill_reminder_model.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;


class BillDetailsSheet extends StatelessWidget {
  final BillReminder bill;
  final VoidCallback onClose;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  const BillDetailsSheet({
    super.key,
    required this.bill,
    required this.onClose,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildHeader(),
            const SizedBox(height: 20),

            // Bill icon and title
            _buildBillHeader(),
            const SizedBox(height: 25),

            // Details grid
            _buildDetailsGrid(),
            
            // Notes section (if available)
            if (bill.notes != null && bill.notes!.isNotEmpty) _buildNotesSection(),
            
            // Action buttons
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Build header with close button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bill Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.deepPink,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }

  // Build bill icon and title section
  Widget _buildBillHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.lightPink1,
            shape: BoxShape.circle,
          ),
          child: Icon(
            BillService.getBillIcon(bill.category),
            color: AppColors.deepPink,
            size: 40,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          bill.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.deepPink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          bill.category,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Build details grid with bill information
  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildDetailItem(
          icon: Icons.currency_rupee,
          title: 'Amount',
          value: '₹${bill.amount.toStringAsFixed(2)}',
        ),
        _buildDetailItem(
          icon: Icons.calendar_today,
          title: 'Due Date',
          value: DateFormat('MMM dd, yyyy').format(bill.dueDate),
        ),
        if (bill.reminderDate != null)
          _buildDetailItem(
            icon: Icons.notifications,
            title: 'Reminder',
            value: DateFormat('MMM dd, yyyy').format(bill.reminderDate!),
          ),
        _buildDetailItem(
          icon: Icons.calendar_view_month,
          title: 'Days Left',
          value: '${bill.dueDate.difference(DateTime.now()).inDays} days',
        ),
      ],
    );
  }

  // Build individual detail item
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightPink1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.mediumPink),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.deepPink,
            ),
          ),
        ],
      ),
    );
  }

  // Build notes section
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.deepPink,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.lightPink1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bill.notes!,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  // Build action buttons row
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Close button
        Expanded(
          child: OutlinedButton(
            onPressed: onClose,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: AppColors.lightPink2),
            ),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.deepPink),
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        // Delete button
        Expanded(
          child: OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(
              'Delete',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        // Mark as paid button (disabled if already paid)
        Expanded(
          child: ElevatedButton(
            onPressed: bill.isPaid ? null : onMarkPaid,
            style: ElevatedButton.styleFrom(
              backgroundColor: bill.isPaid ? Colors.grey : AppColors.deepPink,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              bill.isPaid ? 'Already Paid' : 'Mark as Paid',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}