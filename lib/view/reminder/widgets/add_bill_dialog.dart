import 'package:expance_tracker_app/view/reminder/services/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expance_tracker_app/resources/colors.dart' show AppColors;


class AddBillDialog extends StatefulWidget {
  final VoidCallback onBillAdded;

  const AddBillDialog({
    super.key,
    required this.onBillAdded,
  });

  @override
  State<AddBillDialog> createState() => _AddBillDialogState();
}

class _AddBillDialogState extends State<AddBillDialog> {
  // Controllers for text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // State variables
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Electricity';
  DateTime? _reminderDate;
  bool _isLoading = false;

  // Date picker for due date
  Future<void> _pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepPink, // Header color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Background color
              onSurface: Colors.black, // Text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Date picker for reminder date
  Future<void> _pickReminderDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.subtract(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: _selectedDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepPink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  // Clear reminder date
  void _clearReminderDate() {
    setState(() {
      _reminderDate = null;
    });
  }

  // Validate and save bill
  Future<void> _saveBill() async {
    // Get and trim input values
    final String title = _titleController.text.trim();
    final String amountText = _amountController.text.trim();
    final String notes = _notesController.text.trim();
    
    // Validate title
    if (title.isEmpty) {
      _showErrorSnackbar('Please enter a bill title');
      return;
    }
    
    // Validate amount
    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }
    
    // Set loading state
    setState(() => _isLoading = true);
    
    try {
      // Add bill to database
      final success = await BillService.addBill(
        title: title,
        amount: amount,
        category: _selectedCategory,
        dueDate: _selectedDate,
        reminderDate: _reminderDate,
        notes: notes.isNotEmpty ? notes : null,
      );
      
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bill added successfully'),
            backgroundColor: AppColors.mediumPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Notify parent widget
        widget.onBillAdded();
        
        // Close dialog
        Navigator.pop(context);
      } else {
        _showErrorSnackbar('Failed to add bill. Please try again.');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Reset form
  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _notesController.clear();
    _selectedDate = DateTime.now().add(const Duration(days: 7));
    _selectedCategory = 'Electricity';
    _reminderDate = null;
  }

  @override
  void dispose() {
    // Clean up controllers
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Center(
        child: Text(
          'Add New Bill',
          style: TextStyle(
            color: AppColors.deepPink,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
            minWidth: 300,
          ),
          child: _isLoading 
              ? _buildLoadingState()
              : _buildFormContent(),
        ),
      ),
      actions: _isLoading 
          ? [] // No actions during loading
          : _buildDialogActions(),
    );
  }

  // Build loading state
  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.deepPink,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Adding bill...',
              style: TextStyle(
                color: AppColors.deepPink,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build form content
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bill Title Field
        _buildTitleField(),
        const SizedBox(height: 16),
        
        // Amount Field
        _buildAmountField(),
        const SizedBox(height: 16),
        
        // Category Dropdown
        _buildCategoryDropdown(),
        const SizedBox(height: 16),
        
        // Due Date Picker
        _buildDueDatePicker(),
        const SizedBox(height: 16),
        
        // Reminder Toggle
        _buildReminderToggle(),
        if (_reminderDate != null) const SizedBox(height: 12),
        if (_reminderDate != null) _buildReminderDate(),
        const SizedBox(height: 16),
        
        // Notes Field
        _buildNotesField(),
      ],
    );
  }

  // Build title text field
  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Bill Title',
        hintText: 'e.g., Electricity Bill, Rent',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightPink2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.deepPink, width: 2),
        ),
        prefixIcon: Icon(Icons.receipt, color: AppColors.mediumPink),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15),
      maxLength: 50,
    );
  }

  // Build amount text field
  Widget _buildAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixText: '₹ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightPink2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.deepPink, width: 2),
        ),
        prefixIcon: Icon(Icons.currency_rupee, color: AppColors.mediumPink),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15),
    );
  }

  // Build category dropdown
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightPink2, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.deepPink),
          iconSize: 24,
          elevation: 8,
          dropdownColor: Colors.white,
          style: TextStyle(
            color: AppColors.deepPink,
            fontSize: 15,
          ),
          items: BillService.categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(
                    BillService.getBillIcon(category),
                    color: AppColors.mediumPink,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(category),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ),
    );
  }

  // Build due date picker
  Widget _buildDueDatePicker() {
    return GestureDetector(
      onTap: () => _pickDueDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightPink2, width: 1),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.mediumPink),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.deepPink,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Build reminder toggle
  Widget _buildReminderToggle() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Set Reminder',
        style: TextStyle(
          color: AppColors.deepPink,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _reminderDate == null 
            ? 'Get notified before due date' 
            : 'You will be reminded on ${DateFormat('MMM dd').format(_reminderDate!)}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      value: _reminderDate != null,
      activeColor: AppColors.deepPink,
      inactiveTrackColor: Colors.grey.shade300,
      onChanged: (bool value) {
        if (value) {
          _pickReminderDate(context);
        } else {
          _clearReminderDate();
        }
      },
    );
  }

  // Build reminder date display
  Widget _buildReminderDate() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightPink1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppColors.mediumPink, size: 20),
              const SizedBox(width: 10),
              Text(
                'Reminder: ${DateFormat('EEE, MMM dd, yyyy').format(_reminderDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.grey,
            onPressed: _clearReminderDate,
          ),
        ],
      ),
    );
  }

  // Build notes text field
  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightPink2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.deepPink, width: 2),
        ),
        prefixIcon: Icon(Icons.notes, color: AppColors.mediumPink),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(fontSize: 15),
      maxLines: 3,
      minLines: 1,
    );
  }

  // Build dialog action buttons
  List<Widget> _buildDialogActions() {
    return [
      // Cancel button
      TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: const Text('CANCEL'),
      ),
      
      // Reset button
      TextButton(
        onPressed: _resetForm,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mediumPink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: const Text('RESET'),
      ),
      
      // Add button
      ElevatedButton(
        onPressed: _saveBill,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 2,
        ),
        child: const Text('ADD BILL'),
      ),
    ];
  }
}