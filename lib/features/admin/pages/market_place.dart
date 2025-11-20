import 'package:flutter/material.dart';
import '../../../core/colors/colors.dart';
import '../widgets/art_item_tile.dart';
import '../../model/market_model.dart';
import '../forms/art_item_form.dart';
import '../service/market_service.dart';

class MarketPlace extends StatelessWidget {
  const MarketPlace({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list (could also come from API or local JSON)
    final marketService = MarketService();

    // Categories for the horizontal list
    final List<String> categories = [
      "All",
      "Recycled",
      "Upcycled",
      "Handmade",
      "Nature",
      "Modern Art",
      "Others"
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
                          ), 
                          side: BorderSide(
                            color: AppColors.accent, 
                            width: 1.5, 
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // GridView for displaying art items
              Expanded(child: _getArtitems(marketService)),
            ],
          ),
        ),

        // Floating action button to add new art item
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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

  FutureBuilder<List<ArtitemModel>> _getArtitems(MarketService marketService) {
    return FutureBuilder<List<ArtitemModel>>(
      future: marketService.getArtItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No art items available.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final artItems = snapshot.data!;

        return GridView.builder(
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
        );
      },
    );
  }
}
