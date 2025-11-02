import 'package:cloud_firestore/cloud_firestore.dart';

enum MaterialType {
  plastic,
  paper,
  glass,
  metal,
  organic,
  electronic,
  textile,
  mixed,
}

extension MaterialTypeExtension on MaterialType {
  String get displayName {
    switch (this) {
      case MaterialType.plastic:
        return 'Plastic';
      case MaterialType.paper:
        return 'Paper';
      case MaterialType.glass:
        return 'Glass';
      case MaterialType.metal:
        return 'Metal';
      case MaterialType.organic:
        return 'Organic';
      case MaterialType.electronic:
        return 'Electronic';
      case MaterialType.textile:
        return 'Textile';
      case MaterialType.mixed:
        return 'Mixed';
    }
  }

  String get icon {
    switch (this) {
      case MaterialType.plastic:
        return '♻️';
      case MaterialType.paper:
        return '📄';
      case MaterialType.glass:
        return '🍾';
      case MaterialType.metal:
        return '🔧';
      case MaterialType.organic:
        return '🌱';
      case MaterialType.electronic:
        return '💻';
      case MaterialType.textile:
        return '👕';
      case MaterialType.mixed:
        return '📦';
    }
  }
}

class WeightRecord {
  final String id;
  final String groupId;
  final String ecoSpotId;
  final String ecoSpotName;
  final MaterialType materialType;
  final double weightInKg;
  final String? notes;
  final String recordedBy;
  final String recordedByName;
  final DateTime recordedAt;

  WeightRecord({
    required this.id,
    required this.groupId,
    required this.ecoSpotId,
    required this.ecoSpotName,
    required this.materialType,
    required this.weightInKg,
    this.notes,
    required this.recordedBy,
    required this.recordedByName,
    required this.recordedAt,
  });

  factory WeightRecord.fromMap(Map<String, dynamic> map, String id) {
    return WeightRecord(
      id: id,
      groupId: map['groupId'] ?? '',
      ecoSpotId: map['ecoSpotId'] ?? '',
      ecoSpotName: map['ecoSpotName'] ?? '',
      materialType: MaterialType.values.firstWhere(
        (e) => e.toString() == 'MaterialType.${map['materialType']}',
        orElse: () => MaterialType.mixed,
      ),
      weightInKg: (map['weightInKg'] ?? 0).toDouble(),
      notes: map['notes'],
      recordedBy: map['recordedBy'] ?? '',
      recordedByName: map['recordedByName'] ?? '',
      recordedAt: (map['recordedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'ecoSpotId': ecoSpotId,
      'ecoSpotName': ecoSpotName,
      'materialType': materialType.toString().split('.').last,
      'weightInKg': weightInKg,
      'notes': notes,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }
}
