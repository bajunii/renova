import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';

class ArtItemForm extends StatefulWidget {
  const ArtItemForm({super.key});

  @override
  State<ArtItemForm> createState() => _ArtItemFormState();
}

class _ArtItemFormState extends State<ArtItemForm> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ArtItem Form',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        body: Center(child: Text('Market Place Art Item. Comming Soon.....')),
      ),
    );
  }
}
