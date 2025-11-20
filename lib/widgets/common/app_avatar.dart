import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String initials;
  final Color backgroundColor;
  final double radius;

  const AppAvatar({
    super.key,
    required this.initials,
    required this.backgroundColor,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
