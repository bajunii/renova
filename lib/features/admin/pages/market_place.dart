import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';
import '../widgets/art_item_tile.dart';
import '../../model/market_model.dart';
import '../forms/art_item_form.dart';

class MarketPlace extends StatelessWidget {
  const MarketPlace({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list (could also come from API or local JSON)
    final List<ArtitemModel> artItems = [
      ArtitemModel(
        id: "A102",
        title: "Bottle Cap Mosaic",
        imageUrl: "assets/images/free-wifi.png",
        category: "recycled",
        price: 45.50,
        description:
            "A vibrant wall mosaic crafted from discarded bottle caps.",
        artist: "Jane Mwangi",
        createdAt: DateTime.now(),
        tags: ["mosaic", "bottle caps"],
      ),
      ArtitemModel(
        id: "A003",
        title: "Tire Flower Pot",
        imageUrl: "assets/images/soap.jpg",
        category: "upcycled",
        price: 25.00,
        description: "Old tire transformed into a stylish flower pot.",
        artist: "Peter Otieno",
        createdAt: DateTime.now(),
        tags: ["garden", "tire"],
      ),
      ArtitemModel(
        id: "A102",
        title: "Banana Fiber Basket",
        imageUrl: "",
        category: "handmade",
        price: 35.00,
        description: "Handwoven basket made from dried banana fibers.",
        artist: "Mary Njeri",
        createdAt: DateTime.now(),
        tags: ["basket", "woven"],
      ),
    ];

    // Categories for the horizontal list
    final List<String> categories = [
      "All",
      "Recycled",
      "Upcycled",
      "Handmade",
      "Nature",
      "Modern Art",
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Recycled Art Market",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 1,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal scrollable category list
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Chip(
                        label: Text(
                          categories[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.text,
                          ),
                        ),
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Border radius added here
                          side: BorderSide(
                            color: AppColors.accent, // Border color
                            width: 1.5, // Border width
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // GridView for displaying art items
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: artItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    return ArtItemTile(artItem: artItems[index]);
                  },
                ),
              ),
            ],
          ),
        ),

        // Floating action button to add new art item
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to add new art item form
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArtItemForm()),
            );
          },
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      ),
    );
  }
}
