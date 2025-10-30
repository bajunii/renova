import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import '../../model/groups_model.dart';

class GroupsService {
  // final _firestore = FirebaseFirestore.instance;
  // final _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads image to Firebase Storage and returns the download URL.
  Future<String?> uploadImage(File? imageFile) async {
    if (imageFile == null) return null;

    final fileName = 'group_profile/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);

    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

}
