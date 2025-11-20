import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Groups',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Text('GroupsPage Comming Soon...')),

        // Floating action button to add group
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const Text('Add Group Form Coming Soon...')),
            // );
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      ),
    );
  }
}
