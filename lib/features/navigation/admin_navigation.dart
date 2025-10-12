import 'package:flutter/material.dart';
import '../admin/pages/admin_dashboard.dart';
import '../admin/pages/eco_sports.dart';
import '../admin/pages/events_page.dart';
import '../admin/pages/groups_page.dart';
import '../admin/pages/market_place.dart';
import '../../core/colors/colors.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int index = 0;

  // listing of the different screens
  final screens = [
    AdminDashboard(),
    EcoSports(),
    EventsPage(),
    GroupsPage(),
    MarketPlace(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: screens[index],
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: AppColors.accent,
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      child: NavigationBar(
        height: 60,
        backgroundColor: AppColors.background,
        selectedIndex: index,
        onDestinationSelected: (index) => setState(() => this.index = index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: Duration(seconds: 3),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'EcoSports',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'MarketPlace',
          ),
        ],
      ),
    ),
  );
}
