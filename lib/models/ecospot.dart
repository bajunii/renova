import 'package:cloud_firestore/cloud_firestore.dart';

enum EcoSpotStatus { active, inactive, pending, suspended }

enum EcoSpotType {
  recyclingCenter,
  collectionPoint,
  dropOffLocation,
  communityCenter,
  beachCleanup,
  other
}

class EcoSpot {
  final String id;
  final String name;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String groupId;
  final String groupName;
  final EcoSpotType type;
  final EcoSpotStatus status;
  final List<String> acceptedMaterials;
  final String? contactNumber;
  final String? operatingHours;
  final int collectionCount;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final bool isVerified;
  final List<String> imageUrls;

  EcoSpot({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.groupId,
    required this.groupName,
    required this.type,
    this.status = EcoSpotStatus.active,
    this.acceptedMaterials = const [],
    this.contactNumber,
    this.operatingHours,
    this.collectionCount = 0,
    required this.createdAt,
    this.lastUpdated,
    this.isVerified = false,
    this.imageUrls = const [],
  });

  String get typeDisplayName {
    switch (type) {
      case EcoSpotType.recyclingCenter:
        return 'Recycling Center';
      case EcoSpotType.collectionPoint:
        return 'Collection Point';
      case EcoSpotType.dropOffLocation:
        return 'Drop-off Location';
      case EcoSpotType.communityCenter:
        return 'Community Center';
      case EcoSpotType.beachCleanup:
        return 'Beach Cleanup';
      case EcoSpotType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case EcoSpotStatus.active:
        return 'Active';
      case EcoSpotStatus.inactive:
        return 'Inactive';
      case EcoSpotStatus.pending:
        return 'Pending';
      case EcoSpotStatus.suspended:
        return 'Suspended';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'groupId': groupId,
      'groupName': groupName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'acceptedMaterials': acceptedMaterials,
      'contactNumber': contactNumber,
      'operatingHours': operatingHours,
      'collectionCount': collectionCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'isVerified': isVerified,
      'imageUrls': imageUrls,
    };
  }

  factory EcoSpot.fromMap(Map<String, dynamic> map) {
    return EcoSpot(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      type: EcoSpotType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => EcoSpotType.other,
      ),
      status: EcoSpotStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EcoSpotStatus.active,
      ),
      acceptedMaterials: List<String>.from(map['acceptedMaterials'] ?? []),
      contactNumber: map['contactNumber'],
      operatingHours: map['operatingHours'],
      collectionCount: map['collectionCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
      isVerified: map['isVerified'] ?? false,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  EcoSpot copyWith({
    String? name,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    EcoSpotType? type,
    EcoSpotStatus? status,
    List<String>? acceptedMaterials,
    String? contactNumber,
    String? operatingHours,
    int? collectionCount,
    DateTime? lastUpdated,
    bool? isVerified,
    List<String>? imageUrls,
  }) {
    return EcoSpot(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      groupId: groupId,
      groupName: groupName,
      type: type ?? this.type,
      status: status ?? this.status,
      acceptedMaterials: acceptedMaterials ?? this.acceptedMaterials,
      contactNumber: contactNumber ?? this.contactNumber,
      operatingHours: operatingHours ?? this.operatingHours,
      collectionCount: collectionCount ?? this.collectionCount,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isVerified: isVerified ?? this.isVerified,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
