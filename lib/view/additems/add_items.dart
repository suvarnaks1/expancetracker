import 'package:expance_tracker_app/view/common/bottom_nav.dart';
import 'package:expance_tracker_app/view/expance/expancemonthview.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/services/firebase_service.dart';
import 'package:expance_tracker_app/model/expance_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItems extends StatefulWidget {
  const AddItems({Key? key, required String existingId, required initialAmount, required initialDesc, required initialCategory, final DateTime? initialDate}) : super(key: key);
  @override
  State<AddItems> createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _category;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
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
      builder: (ctx, child) => Theme(
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

      final exp = Expense(
        id: '',
        amount: double.parse(_amountCtrl.text),
        description: _descCtrl.text,
        category: _category!,
        date: dateTime,
      );

      await FirebaseService.db
          .collection('users/$uid/expenses')
          .add(exp.toMap());

      if (!mounted) return;
       Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ExpenseMonthView()),
            );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
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
          leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BottomNav()),
            );
        },
        ),),
        backgroundColor: AppColors.lightPink1,
        body: Padding(
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
                  decoration: const InputDecoration(
                    labelText: 'Amount', prefixText: '\₹ ',
                  ),
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
                  items: ['Food', 'Transport', 'Shopping', 'Emi','Rent','Other',]
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
      ),
    );
  }
}
