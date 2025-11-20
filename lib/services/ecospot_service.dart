import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ecospot.dart';

class EcoSpotService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'ecospots';

  // Create a new EcoSpot
  static Future<String> createEcoSpot({
    required String name,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
    required String groupId,
    required String groupName,
    required EcoSpotType type,
    List<String> acceptedMaterials = const [],
    String? contactNumber,
    String? operatingHours,
  }) async {
    try {
      final ecoSpotDoc = _firestore.collection(_collection).doc();

      final ecoSpot = EcoSpot(
        id: ecoSpotDoc.id,
        name: name,
        description: description,
        location: location,
        latitude: latitude,
        longitude: longitude,
        groupId: groupId,
        groupName: groupName,
        type: type,
        status: EcoSpotStatus.active,
        acceptedMaterials: acceptedMaterials,
        contactNumber: contactNumber,
        operatingHours: operatingHours,
        createdAt: DateTime.now(),
      );

      await ecoSpotDoc.set(ecoSpot.toMap());
      return ecoSpotDoc.id;
    } catch (e) {
      throw Exception('Failed to create EcoSpot: $e');
    }
  }

  // Get EcoSpot by ID
  static Future<EcoSpot?> getEcoSpot(String ecoSpotId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(ecoSpotId).get();

      if (doc.exists) {
        return EcoSpot.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get EcoSpot: $e');
    }
  }

  // Get EcoSpots by Group ID
  static Future<List<EcoSpot>> getEcoSpotsByGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EcoSpot.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get EcoSpots: $e');
    }
  }

  // Get all active EcoSpots
  static Future<List<EcoSpot>> getActiveEcoSpots() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => EcoSpot.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active EcoSpots: $e');
    }
  }

  // Update EcoSpot
  static Future<void> updateEcoSpot(
    String ecoSpotId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(ecoSpotId).update(updates);
    } catch (e) {
      throw Exception('Failed to update EcoSpot: $e');
    }
  }

  // Update EcoSpot status
  static Future<void> updateEcoSpotStatus(
    String ecoSpotId,
    EcoSpotStatus status,
  ) async {
    try {
      await updateEcoSpot(ecoSpotId, {
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update EcoSpot status: $e');
    }
  }

  // Delete EcoSpot
  static Future<void> deleteEcoSpot(String ecoSpotId) async {
    try {
      await _firestore.collection(_collection).doc(ecoSpotId).delete();
    } catch (e) {
      throw Exception('Failed to delete EcoSpot: $e');
    }
  }

  // Increment collection count
  static Future<void> incrementCollectionCount(String ecoSpotId) async {
    try {
      await _firestore.collection(_collection).doc(ecoSpotId).update({
        'collectionCount': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment collection count: $e');
    }
  }

  // Search EcoSpots by name or location
  static Future<List<EcoSpot>> searchEcoSpots(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .get();

      // Filter results based on name or location containing the query
      return querySnapshot.docs
          .map((doc) => EcoSpot.fromMap(doc.data()))
          .where(
            (ecoSpot) =>
                ecoSpot.name.toLowerCase().contains(query.toLowerCase()) ||
                ecoSpot.location.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search EcoSpots: $e');
    }
  }
}
