import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/services/firebase_service.dart';
import 'package:expance_tracker_app/model/expance_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItems extends StatefulWidget {
  const AddItems({Key? key}) : super(key: key);

  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _category;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (_, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.deepPink),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (_, child) => Theme(
        data: ThemeData.light().copyWith(
          timePickerTheme: TimePickerThemeData(
            dialHandColor: AppColors.deepPink,
            hourMinuteTextColor: AppColors.deepPink,
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    context.loaderOverlay.show();

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final expense = Expense(
        id: '',
        amount: double.parse(_amountCtrl.text),
        description: _descCtrl.text,
        category: _category!,
        date: dateTime,
      );

      await FirebaseService.db
          .collection('users/$uid/expenses')
          .add(expense.toMap());

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('❗️Save failed: $e');
      debugPrint('$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
      context.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dtText = _selectedDate == null
        ? 'Pick Date'
        : DateFormat.yMMMd().format(_selectedDate!);
    final tmText = _selectedTime == null
        ? 'Pick Time'
        : _selectedTime!.format(context);

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add New Item'),
          backgroundColor: AppColors.mediumPink,
        ),
        backgroundColor: AppColors.lightPink1,
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(dtText),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepPink,
                              side: const BorderSide(color: AppColors.deepPink),
                            ),
                            onPressed: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(tmText),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepPink,
                              side: const BorderSide(color: AppColors.deepPink),
                            ),
                            onPressed: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v != null && double.tryParse(v) != null
                              ? null
                              : 'Enter valid amount',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                      validator: (v) =>
                          v != null && v.isNotEmpty ? null : 'Enter description',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      hint: const Text('Select Category'),
                      items: ['Food', 'Transport', 'Shopping', 'Other']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v != null ? null : 'Select category',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepPink,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
