class ArtItem {
  // model properties
  final String title;
  final String? imageUrl;
  final String category;
  final double price;
  final String description;
  final String artist;
  final DateTime createdAt;
  final List<String>? tags;

  ArtItem({
    // initialization of the properties
    required this.title, // title of the
    this.imageUrl, // thumbnail of the item
    required this.category, // upccled, recycled, digital printing
    required this.price, // price tag
    required this.description, // about the item
    required this.artist, // owner
    required this.createdAt, // time created
    this.tags, // nature ,sunset , - decribe your items in simple words
  });
}
