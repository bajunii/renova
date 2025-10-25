import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MarketService {

  final _firestore = FirebaseFirestore.instance;
  // final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  /// Uploads image to Firebase Storage and returns the download URL.
  Future<String?> uploadImage(File? imageFile) async {
    if (imageFile == null) return null;

    final fileName = 'art_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// Creates a new art item record in Firestore
  Future<void> createArtItem({
    required String title,
    required String category,
    required double price,
    required String description,
    required String artist,
    required List<String> tags,
    File? imageFile,
  }) async {
    try {
      // Upload image (optional)
      String? imageUrl = await uploadImage(imageFile);

      // Prepare data
      final data = {
        'title': title.trim(),
        'category': category.trim(),
        'price': price,
        'description': description.trim(),
        'artist': artist.trim(),
        'tags': tags,
        'created_at': FieldValue.serverTimestamp(),
      };

      if (imageUrl != null) {
        data['image_url'] = imageUrl;
      }

      // Save to Firestore
      await _firestore.collection('artitems').add(data);
    } catch (e) {
      rethrow;
    }
  }
  /// Fetches all art items from Firestore



}