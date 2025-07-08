import 'package:expance_tracker_app/view/additems/add_items.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expance_tracker_app/resources/colors.dart';


class ExpenseMonthView extends StatefulWidget {
  const ExpenseMonthView({super.key});
  @override
  State<ExpenseMonthView> createState() => _ExpenseMonthViewState();
}

class _ExpenseMonthViewState extends State<ExpenseMonthView> {
  String activeTab = 'All';
  int touchedPie = -1, touchedBar = -1;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final stream = FirebaseFirestore.instance
        .collection('users/$uid/expenses')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;

          final categorySpending = <String, double>{};
          final last4 = List<double>.filled(4, 0);
          final now = DateTime.now();

          for (var doc in docs) {
            final d = doc.data() as Map<String, dynamic>;
            final amt = (d['amount'] as num).toDouble();
            final date = (d['date'] as Timestamp).toDate();
            categorySpending[d['category']] =
                (categorySpending[d['category']] ?? 0) + amt;
            final diff = now.month - date.month;
            if (diff >= 0 && diff < 4) {
              last4[3 - diff] += amt;
            }
          }

          final filtered = docs.where((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return activeTab == 'All' || d['category'] == activeTab;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios,color: AppColors.deepPink),),
                
                const Text('Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.calendar_today, color: AppColors.deepPink),
              ]),
              const SizedBox(height: 16),
              Row(children: ['Day','Week','Month'].map((l) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(l, style: TextStyle(color: l=='Month'?Colors.white:AppColors.deepPink)),
                  selected: l=='Month',
                  selectedColor: AppColors.deepPink,
                  backgroundColor: AppColors.lightPink2,
                  onSelected: (_) {},
                ),
              )).toList()),
              const SizedBox(height: 24),
              Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height:200, child: PieChartWidget(data: categorySpending, touchedIndex: touchedPie, onTap: (idx) => setState(()=>touchedPie=idx))),
              const SizedBox(height:24),
              Text('Monthly Trend', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height:200, child: BarChartWidget(data: last4, touchedIndex: touchedBar, onTap: (idx) => setState(()=>touchedBar=idx))),
              const SizedBox(height:24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: ['All',...categorySpending.keys].map((tab){
                  final sel = tab==activeTab;
                  return Padding(
                    padding: const EdgeInsets.only(right:12),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: sel,
                      selectedColor: AppColors.deepPink,
                      backgroundColor: AppColors.lightPink2,
                      labelStyle: TextStyle(color: sel?Colors.white:AppColors.deepPink),
                      onSelected: (_) => setState(()=>activeTab=tab),
                    ),
                  );
                }).toList()),
              ),
              const SizedBox(height:16),
              ...filtered.map((doc){
                final d = doc.data() as Map<String,dynamic>;
                final date = (d['date'] as Timestamp).toDate();
                return _buildTransactionCard(
                  title: d['description'],
                  subtitle: d['category'],
                  amount: '-\$${(d['amount'] as num).toStringAsFixed(2)}',
                  date: DateFormat.yMMMd().format(date),
                  icon: _getIcon(d['category']),
                  onEdit: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AddItems(
                      existingId: doc.id,
                      initialAmount: d['amount'],
                      initialDesc: d['description'],
                      initialCategory: d['category'],
                      initialDate: date,
                    ),
                  )),
                  onDelete: () => _confirmDelete(uid, doc.id),
                );
              }).toList(),
            ]),
          );
        },
      ),
    );
  }

  void _confirmDelete(String uid, String id) {
    showDialog(
      context: context, builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: (){
            FirebaseFirestore.instance.doc('users/$uid/expenses/$id').delete();
            Navigator.pop(context);
          }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
  
  Widget _buildTransactionCard({required String title, required String subtitle, required String amount, required String date, required IconData icon, required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom:12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.lightPink2, borderRadius: BorderRadius.circular(12)),
      child: Row(children:[
        CircleAvatar(backgroundColor:Colors.white, child:Icon(icon, color: AppColors.deepPink)),
        const SizedBox(width:12),
        Expanded(child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize:12)),
          ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children:[
          Text(amount, style: const TextStyle(color:Colors.red, fontWeight: FontWeight.bold)),
          Text(date, style: const TextStyle(fontSize:12, color:Colors.grey)),
        ]),
        IconButton(icon: Icon(Icons.edit, color: AppColors.deepPink), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: onDelete),
      ]),
    );
  }

  IconData _getIcon(String cat) => {
    'Food': Icons.fastfood,
    'Shopping': Icons.shopping_bag,
    'Transport': Icons.directions_car
  }[cat] ?? Icons.category;
}

class PieChartWidget extends StatelessWidget {
  final Map<String,double> data;
  final int touchedIndex;
  final void Function(int) onTap;

  const PieChartWidget({ required this.data, required this.touchedIndex, required this.onTap });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a,b)=>a+b);
    return PieChart(PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      pieTouchData: PieTouchData(touchCallback:(_, resp){
        onTap(resp?.touchedSection?.touchedSectionIndex ?? -1);
      }),
      sections: List.generate(data.length, (i){
        final e = data.entries.elementAt(i);
        final isTouched = i==touchedIndex;
        final pct = (e.value/total*100).toStringAsFixed(1);
        return PieChartSectionData(
          color: _colorFor(e.key),
          value: e.value,
          title: '$pct%',
          radius: isTouched?70:60,
          titleStyle: const TextStyle(fontSize:14, fontWeight:FontWeight.bold, color:Colors.white),
        );
      }),
    ));
  }

  Color _colorFor(String cat) => {
    'Food': Colors.green,
    'Shopping': Colors.orange,
    'Transport': Colors.blue,
  }[cat] ?? Colors.grey;
}
class BarChartWidget extends StatelessWidget {
  final List<double> data;
  final int touchedIndex;
  final void Function(int) onTap;

  const BarChartWidget({ required this.data, required this.touchedIndex, required this.onTap });

  @override
  Widget build(BuildContext context) {
    final maxY = data.reduce((a,b)=>a>b?a:b)*1.2;
    return BarChart(BarChartData(
      maxY: maxY,
      barTouchData: BarTouchData(touchCallback:(_, resp ){
        onTap(resp?.spot?.touchedBarGroupIndex ?? -1);
      }),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, getTitlesWidget:(v,_) {
          const labels=['Jan','Feb','Mar','Apr'];
          final idx = v.toInt().clamp(0, labels.length-1);
          return Text(labels[idx], style: TextStyle(color:AppColors.deepPink));
        })),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles:true, reservedSize:40)),
      ),
      gridData: FlGridData(show:false),
      borderData: FlBorderData(show:false),
      barGroups: List.generate(data.length, (i){
        final isTouch = i==touchedIndex;
        return BarChartGroupData(x:i, barRods:[
          BarChartRodData(toY: data[i], color:AppColors.mediumPink, width: isTouch?20:16, borderRadius: BorderRadius.circular(6)),
        ]);
      }),
    ));
  }
}
