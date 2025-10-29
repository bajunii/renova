import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupStatus { pending, approved, rejected, suspended }

enum VerificationStatus { notSubmitted, pending, approved, rejected }

enum MemberRole { leader, chair, secretary, treasurer, member }

class GroupMember {
  final String userId;
  final String name;
  final String email;
  final MemberRole role;
  final DateTime joinedAt;
  final bool isActive;

  GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: MemberRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case MemberRole.leader:
        return 'Group Leader';
      case MemberRole.chair:
        return 'Chairperson';
      case MemberRole.secretary:
        return 'Secretary';
      case MemberRole.treasurer:
        return 'Treasurer';
      case MemberRole.member:
        return 'Member';
    }
  }
}

class Group {
  final String id;
  final String groupName;
  final String groupDetails;
  final List<String> documentUrls;
  final GroupStatus status;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? adminNotes;
  final List<GroupMember> members;
  final String? location;
  final String? contactNumber;
  final String? website;
  final Map<String, String> socialMedia;
  final int maxMembers;
  final List<String> focusAreas; // e.g., ["plastic", "paper", "electronics"]

  Group({
    required this.id,
    required this.groupName,
    required this.groupDetails,
    this.documentUrls = const [],
    this.status = GroupStatus.pending,
    this.verificationStatus = VerificationStatus.notSubmitted,
    required this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.rejectionReason,
    this.adminNotes,
    this.members = const [],
    this.location,
    this.contactNumber,
    this.website,
    this.socialMedia = const {},
    this.maxMembers = 100,
    this.focusAreas = const [],
  });

  // Convert Group to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupName': groupName,
      'groupDetails': groupDetails,
      'documentUrls': documentUrls,
      'status': status.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
      'members': members.map((member) => member.toMap()).toList(),
      'location': location,
      'contactNumber': contactNumber,
      'website': website,
      'socialMedia': socialMedia,
      'maxMembers': maxMembers,
      'focusAreas': focusAreas,
    };
  }

  // Create Group from Firestore document
  factory Group.fromMap(Map<String, dynamic> map, String documentId) {
    return Group(
      id: documentId,
      groupName: map['groupName'] ?? '',
      groupDetails: map['groupDetails'] ?? '',
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      status: GroupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => GroupStatus.pending,
      ),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['verificationStatus'],
        orElse: () => VerificationStatus.notSubmitted,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      rejectionReason: map['rejectionReason'],
      adminNotes: map['adminNotes'],
      members:
          (map['members'] as List<dynamic>?)
              ?.map(
                (memberMap) =>
                    GroupMember.fromMap(memberMap as Map<String, dynamic>),
              )
              .toList() ??
          [],
      location: map['location'],
      contactNumber: map['contactNumber'],
      website: map['website'],
      socialMedia: Map<String, String>.from(map['socialMedia'] ?? {}),
      maxMembers: map['maxMembers'] ?? 100,
      focusAreas: List<String>.from(map['focusAreas'] ?? []),
    );
  }

  // Copy with method for updates
  Group copyWith({
    String? groupName,
    String? groupDetails,
    List<String>? documentUrls,
    GroupStatus? status,
    VerificationStatus? verificationStatus,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? adminNotes,
    List<GroupMember>? members,
    String? location,
    String? contactNumber,
    String? website,
    Map<String, String>? socialMedia,
    int? maxMembers,
    List<String>? focusAreas,
  }) {
    return Group(
      id: id,
      groupName: groupName ?? this.groupName,
      groupDetails: groupDetails ?? this.groupDetails,
      documentUrls: documentUrls ?? this.documentUrls,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      adminNotes: adminNotes ?? this.adminNotes,
      members: members ?? this.members,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      maxMembers: maxMembers ?? this.maxMembers,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }

  // Helper methods
  bool get isApproved => status == GroupStatus.approved;
  bool get isPending => status == GroupStatus.pending;
  bool get isRejected => status == GroupStatus.rejected;
  bool get isSuspended => status == GroupStatus.suspended;

  bool get isVerificationComplete =>
      verificationStatus == VerificationStatus.approved;
  bool get isVerificationPending =>
      verificationStatus == VerificationStatus.pending;

  String get statusDisplayName {
    switch (status) {
      case GroupStatus.pending:
        return 'Pending Approval';
      case GroupStatus.approved:
        return 'Approved';
      case GroupStatus.rejected:
        return 'Rejected';
      case GroupStatus.suspended:
        return 'Suspended';
    }
  }

  String get verificationStatusDisplayName {
    switch (verificationStatus) {
      case VerificationStatus.notSubmitted:
        return 'Documents Not Submitted';
      case VerificationStatus.pending:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Verification Failed';
    }
  }

  // Get completion percentage for profile
  int get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 10;

    if (groupName.isNotEmpty) completedFields++;
    if (groupDetails.isNotEmpty) completedFields++;
    if (members.isNotEmpty) completedFields++;
    if (location != null && location!.isNotEmpty) completedFields++;
    if (contactNumber != null && contactNumber!.isNotEmpty) completedFields++;
    if (website != null && website!.isNotEmpty) completedFields++;
    if (socialMedia.isNotEmpty) completedFields++;
    if (focusAreas.isNotEmpty) completedFields++;
    if (documentUrls.isNotEmpty) completedFields++;
    if (isVerificationComplete) completedFields++;

    return (completedFields * 100 / totalFields).round();
  }

  // Get the leader of the group
  GroupMember? get leader {
    try {
      return members.firstWhere((member) => member.role == MemberRole.leader);
    } catch (e) {
      return null;
    }
  }

  // Get all admins (leaders and chairs)
  List<GroupMember> get admins {
    return members
        .where(
          (member) =>
              member.role == MemberRole.leader ||
              member.role == MemberRole.chair,
        )
        .toList();
  }

  // Get active members count
  int get activeMembersCount {
    return members.where((member) => member.isActive).length;
  }
}
