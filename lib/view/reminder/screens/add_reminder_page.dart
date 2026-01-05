import 'package:expance_tracker_app/view/reminder/services/bill_service.dart';
import 'package:expance_tracker_app/view/reminder/widgets/add_bill_dialog.dart';
import 'package:expance_tracker_app/view/reminder/widgets/bill_card.dart';
import 'package:expance_tracker_app/view/reminder/widgets/bill_details_sheet.dart';
import 'package:expance_tracker_app/view/reminder/widgets/bill_filter_tabs.dart';
import 'package:expance_tracker_app/view/reminder/widgets/bill_stats_cards.dart';
import 'package:flutter/material.dart';
import 'package:expance_tracker_app/model/bill_reminder_model.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;

class BillRemindersPage extends StatefulWidget {
  const BillRemindersPage({super.key});

  @override
  State<BillRemindersPage> createState() => _BillRemindersPageState();
}

class _BillRemindersPageState extends State<BillRemindersPage> {
  List<BillReminder> allBills = []; // All bills from database
  List<BillReminder> filteredBills = []; // Bills filtered by active filter
  String activeFilter = 'upcoming'; // Current filter ('all', 'upcoming', 'overdue', 'paid')
  bool isLoading = true; // Loading state
  Map<String, dynamic> statistics = {}; // Bill statistics

  @override
  void initState() {
    super.initState();
    _fetchBills(); // Fetch bills when page loads
  }

  // Fetch bills from database and calculate statistics
  Future<void> _fetchBills() async {
    setState(() => isLoading = true);
    
    final bills = await BillService.fetchBills();
    final stats = BillService.calculateStatistics(bills);
    
    setState(() {
      allBills = bills;
      statistics = stats;
      _applyFilter(); // Apply current filter to fetched bills
      isLoading = false;
    });
  }

  // Apply active filter to bills
  void _applyFilter() {
    filteredBills = BillService.filterBills(allBills, activeFilter);
  }

  // Handle filter change
  void _handleFilterChange(String filter) {
    setState(() {
      activeFilter = filter;
      _applyFilter();
    });
  }



// Replace the _showAddBillDialog method with:
Future<void> _showAddBillDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => AddBillDialog(
      onBillAdded: _fetchBills, // Refresh bills list when bill is added
    ),
  );
}

  // Show delete confirmation dialog
  void _showDeleteConfirmation(BillReminder bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 10),
            Text('Delete Bill'),
          ],
        ),
        content: const Text('Are you sure you want to delete this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBill(bill);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Delete a bill
  Future<void> _deleteBill(BillReminder bill) async {
    final success = await BillService.deleteBill(bill.id);
    
    if (success) {
      _fetchBills(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete bill')),
      );
    }
  }

  // Mark bill as paid
  Future<void> _markAsPaid(BillReminder bill) async {
    final success = await BillService.markAsPaid(bill.id);
    
    if (success) {
      _fetchBills(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill marked as paid')),
      );
    }
  }

  // Show bill details sheet
  void _showBillDetails(BuildContext context, BillReminder bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BillDetailsSheet(
        bill: bill,
        onClose: () => Navigator.pop(context),
        onMarkPaid: () {
          Navigator.pop(context);
          _markAsPaid(bill);
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(bill);
        },
      ),
    );
  }

  // Build header section
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill Reminders',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepPink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Never miss a payment',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
          
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                value: statistics['totalBills']?.toString() ?? '0',
                label: 'Total Bills',
                icon: Icons.receipt,
                color: AppColors.mediumPink,
              ),
              _buildStatItem(
                value: '₹${(statistics['totalUpcomingAmount']?.toStringAsFixed(0) ?? '0')}',
                label: 'Due Amount',
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build individual stat item
  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Build bills list
  Widget _buildBillsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.deepPink));
    }

    if (filteredBills.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: filteredBills.length,
      itemBuilder: (context, index) => BillCard(
        bill: filteredBills[index],
        onTap: () => _showBillDetails(context, filteredBills[index]),
        onMarkPaid: () => _markAsPaid(filteredBills[index]),
        onDelete: () => _showDeleteConfirmation(filteredBills[index]),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt,
            size: 80,
            color: AppColors.lightPink2,
          ),
          const SizedBox(height: 20),
          Text(
            activeFilter == 'all' ? 'No bills yet' : 'No ${activeFilter} bills',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            activeFilter == 'all' 
              ? 'Add your first bill reminder'
              : 'All bills are ${activeFilter == 'paid' ? 'unpaid' : 'paid'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: Column(
        children: [
          // Header section
          _buildHeader(),
          
          // Statistics cards
          BillStatsCards(
            upcomingCount: statistics['upcomingCount'] ?? 0,
            overdueCount: statistics['overdueCount'] ?? 0,
            paidCount: statistics['paidCount'] ?? 0,
          ),
          
          // Filter tabs
          BillFilterTabs(
            activeFilter: activeFilter,
            onFilterChanged: _handleFilterChange,
          ),
          
          // Bills list
          Expanded(child: _buildBillsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillDialog(context),
        backgroundColor: AppColors.deepPink,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Bill', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}