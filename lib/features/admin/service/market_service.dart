import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../model/market_model.dart';

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

  ///Creates a new art item document in Firestore using `toJson()` from model
  Future<void> createArtItem(ArtitemModel artItem, {File? imageFile}) async {
    try {
      // Upload image if available
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
        artItem.imageUrl = imageUrl;
      }

      // Create document reference
      final docRef = _firestore
          .collection('artitems')
          .doc(artItem.id.isEmpty ? null : artItem.id);

      // Use model’s `toJson()` for data consistency
      await docRef.set(artItem.toJson());
    } catch (e) {
      throw Exception('Failed to create art item: $e');
    }
  }

  /// GET all Art Items (one-time fetch)
  Future<List<ArtitemModel>> getArtItems() async {
    try {
      final snapshot = await _firestore
          .collection('artitems')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ArtitemModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching art items: $e');
      return [];
    }
  }

  /// Real-time stream of all art items using ArtitemModel.fromJson()
  Stream<List<ArtitemModel>> getArtItemsStream() {
    return _firestore
        .collection('artitems')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ArtitemModel.fromJson(doc.data(), doc.id))
              .toList();
        });
  }
}
