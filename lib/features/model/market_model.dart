import 'package:cloud_firestore/cloud_firestore.dart';

class ArtitemModel {
  // model properties
  final String id;
  String title;
  String? imageUrl;
  String category;
  double price;
  String description;
  String artist;
  DateTime createdAt;
  List<String>? tags;

  ArtitemModel({
    // initialization of the properties
    required this.id,
    required this.title, // title of the
    this.imageUrl, // thumbnail of the item
    required this.category, // upccled, recycled, digital printing
    required this.price, // price tag
    required this.description, // about the item
    required this.artist, // owner
    required this.createdAt, // time created
    this.tags, // nature ,sunset , - decribe your items in simple words
  });

  //Empty Helper Function
  static ArtitemModel empty() => ArtitemModel(
    id: '',
    title: '',
    imageUrl: null,
    category: '',
    price: 0.0,
    description: '',
    artist: '',
    tags: [],
    createdAt: DateTime.now(),
  );

  //convert to json structure
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "imageUrl": imageUrl,
      "category": category,
      "price": price,
      "description": description,
      "artist": artist,
      "createdAt": Timestamp.fromDate(createdAt),
      "tags": tags ?? [],
    };
  }

  //map orientainted document snapshot from firebase to ArtitemModel
  //constructor
  factory ArtitemModel.fromJson(Map<String, dynamic>? arts, String id) {
    if (arts == null) return ArtitemModel.empty();

    //Map Json Record to the Model
    return ArtitemModel(
      id: id,
      title: arts['title'] ?? '',
      imageUrl: arts['imageUrl'] ?? '',
      category: arts['category'] ?? '',
      price: (arts['price'] is int)
          ? (arts['price'] as int).toDouble()
          : (arts['price'] ?? 0.0),
      description: arts['description'] ?? '',
      createdAt: (arts['createdAt'] is Timestamp)
          ? (arts['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      artist: arts['artist'] ?? '',
      tags: arts['tags'] != null ? List<String>.from(arts['tags']) : [],
    );
  }
}
