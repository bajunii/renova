import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';

class EcoSports extends StatelessWidget {
  const EcoSports({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'EcoSports',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Text('EcoSports Comming Soon...')),
      ),
    );
  }
}
