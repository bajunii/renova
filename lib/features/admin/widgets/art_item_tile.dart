// ArtItem card
import 'package:flutter/widgets.dart';
import '../../../core/colors/colors.dart';
import '../../model/market_model.dart';

class ArtItemTile extends StatelessWidget {
  final ArtItem artItem; //class property

  const ArtItemTile({super.key, required this.artItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 260,
      // width: 200,
      width: double.infinity,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent,
            spreadRadius: 0.5,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/placeholder.png',
              image: artItem.imageUrl ?? 'assets/images/placeholder.png',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/placeholder.png',
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Image.asset('assets/images/placeholder.svg', ),
          // FadeInImage.assetNetwork(
          //   placeholder: 'assets/images/free-wifi.png', // Before image load
          //   image: 'assets/images/free-wifi.png', // After image load
          //   width: 160,
          //   fit: BoxFit.cover,
          // ),
          const SizedBox(height: 6.0),
          Text(
            artItem.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Ksh. ${artItem.price.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
