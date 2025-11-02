import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';
import '../widgets/event_tile.dart';
import '../forms/event_form.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Events',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 10,
          itemBuilder: (context, index) => const EventTile(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventForm()),
            );
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      ),
    );
  }
}
