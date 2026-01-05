import 'package:expance_tracker_app/view/reminder/services/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expance_tracker_app/model/bill_reminder_model.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;

class BillCard extends StatelessWidget {
  final BillReminder bill;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  final bool showDeleteButton;

  const BillCard({
    super.key,
    required this.bill,
    required this.onTap,
    required this.onMarkPaid,
    required this.onDelete,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate days until due date
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;
    final isDueSoon = daysUntilDue <= 3;
    final isOverdue = !bill.isPaid && bill.dueDate.isBefore(DateTime.now());
    
    // Determine status colors and text based on bill state
    Color statusColor;
    Color bgColor;
    String statusText;

    if (bill.isPaid) {
      statusColor = Colors.green;
      bgColor = const Color(0xFFE6FFE6);
      statusText = 'PAID';
    } else if (isOverdue) {
      statusColor = Colors.red;
      bgColor = const Color(0xFFFFE6E6);
      statusText = 'OVERDUE';
    } else if (isDueSoon) {
      statusColor = Colors.orange;
      bgColor = const Color(0xFFFFF3E0);
      statusText = daysUntilDue == 0 ? 'TODAY' : '$daysUntilDue days';
    } else {
      statusColor = AppColors.mediumPink;
      bgColor = AppColors.lightPink1;
      statusText = '$daysUntilDue days';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon circle
                _buildCategoryIcon(bgColor, statusColor),
                const SizedBox(width: 15),
                
                // Bill details section
                _buildBillDetails(bill, statusColor, statusText),
                
                // Amount and action buttons section
                _buildAmountAndActions(bill, onMarkPaid, onDelete, showDeleteButton),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build category icon container
  Widget _buildCategoryIcon(Color bgColor, Color statusColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        BillService.getBillIcon(bill.category),
        color: statusColor,
        size: 24,
      ),
    );
  }

  // Build bill details section
  Widget _buildBillDetails(BillReminder bill, Color statusColor, String statusText) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepPink,
                    decoration: bill.isPaid ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Category text
          Text(
            bill.category,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          // Date row
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 5),
              Text(
                DateFormat('MMM dd, yyyy').format(bill.dueDate),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build amount and action buttons section
  Widget _buildAmountAndActions(
    BillReminder bill, 
    VoidCallback onMarkPaid, 
    VoidCallback onDelete, 
    bool showDeleteButton
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Amount text
        Text(
          '₹${bill.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.deepPink,
          ),
        ),
        const SizedBox(height: 8),
        // Action buttons row
        Row(
          children: [
            // Mark as paid button (only for unpaid bills)
            if (!bill.isPaid)
              InkWell(
                onTap: onMarkPaid,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Paid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepPink,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Delete button
            if (showDeleteButton)
              InkWell(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}