// ArtItem card
import 'package:flutter/widgets.dart';
import '../../../core/colors/colors.dart';

class EventTile extends StatelessWidget {
  // final EventsModel event;

  const EventTile({super.key});

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
            blurRadius: 0.5,
            offset: Offset(0.5, 1),
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
              image: 'assets/images/enviroment.png',
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
          const SizedBox(height: 6.0),
          Text(
            "General Market CleanUp",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4.0),

          Text(
            "Thursday, 1st November 2025",
            style: TextStyle(
              fontSize: 16,
              color:AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text("Mongoja Grounds",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              )),

          const SizedBox(height: 4.0),
          Text(
            "10:00 AM - 4:00 PM",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      
    );

    
  }
}
