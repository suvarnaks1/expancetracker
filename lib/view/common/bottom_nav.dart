import 'package:expance_tracker_app/resources/colors.dart';
import 'package:expance_tracker_app/view/additems/add_items.dart';
import 'package:expance_tracker_app/view/common/expance.dart';
import 'package:expance_tracker_app/view/common/home_screen.dart';
import 'package:expance_tracker_app/view/common/profile_setting_page.dart';
import 'package:flutter/material.dart';


class BottomNav extends StatefulWidget {
  const BottomNav({super.key});
  @override
  State<BottomNav> createState() => _MainScreenState();
}

class _MainScreenState extends State<BottomNav> {
  int _selectedIndex = 0;

  final _pages = [
    FinanceDashboard(),
    ExpenseMonthView(),
   ProfileSettingsPage(),
    const Center(child: Text('Settings')),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPink1,
      body: _pages[_selectedIndex],

      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.lightPink2, AppColors.deepPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: (){
Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => AddItems(existingId: '', initialAmount: null, initialDesc: null, initialCategory: null, )),
                        (route) => false,
                      );
          },
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: AppColors.mediumPink,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left icons
                Row(children: [
                  _buildNavIcon(Icons.home, 0),
                  _buildNavIcon(Icons.bar_chart, 1),
                ]),
                // Right icons
                Row(children: [
                  _buildNavIcon(Icons.person, 2),
                  _buildNavIcon(Icons.settings, 3),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final selected = _selectedIndex == index;
    final color = selected ? AppColors.deepPink : AppColors.lightPink2;
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: () => _onItemTapped(index),
    );
  }
}
