import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group.dart';
import 'group_auth_service.dart';

class GroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _collection = 'groups';

  // Create a new group
  static Future<String> createGroup({
    required String groupName,
    required String groupDetails,
    required List<File> documents,
    String? location,
    String? contactNumber,
    String? website,
    Map<String, String>? socialMedia,
    List<String>? focusAreas,
    int maxMembers = 100,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload documents to Firebase Storage
      List<String> documentUrls = [];
      for (int i = 0; i < documents.length; i++) {
        final file = documents[i];
        final fileName =
            'group_documents/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';
        final ref = _storage.ref().child(fileName);
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        documentUrls.add(downloadUrl);
      }

      // Create group document
      final groupDoc = _firestore.collection(_collection).doc();

      // Create the group leader as the first member
      final leader = GroupMember(
        userId: user.uid,
        name: user.displayName ?? 'Unknown',
        email: user.email ?? '',
        role: MemberRole.leader,
        joinedAt: DateTime.now(),
        isActive: true,
      );

      final group = Group(
        id: groupDoc.id,
        groupName: groupName,
        groupDetails: groupDetails,
        documentUrls: documentUrls,
        status: GroupStatus.pending,
        verificationStatus: VerificationStatus.pending,
        createdAt: DateTime.now(),
        members: [leader],
        location: location,
        contactNumber: contactNumber,
        website: website,
        socialMedia: socialMedia ?? {},
        focusAreas: focusAreas ?? [],
        maxMembers: maxMembers,
      );

      await groupDoc.set(group.toMap());

      // Link group to organization if this is an organization account
      try {
        final groupAuthService = GroupAuthService();
        await groupAuthService.linkGroupToOrganization(groupDoc.id);
      } catch (e) {
        print('Note: Group not linked to organization (individual user): $e');
        // This is fine - individual users won't have organization accounts
      }

      return groupDoc.id;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  // Get group by ID
  static Future<Group?> getGroup(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();
      if (doc.exists) {
        return Group.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  // Get group by leader ID
  static Future<Group?> getGroupByLeader(String leaderId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where(
            'members',
            arrayContains: {'userId': leaderId, 'role': 'leader'},
          )
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Group.fromMap(query.docs.first.data(), query.docs.first.id);
      }
      return null;
    } catch (e) {
      // Fallback: get all groups and check manually
      try {
        final allGroups = await _firestore.collection(_collection).get();
        for (var doc in allGroups.docs) {
          final group = Group.fromMap(doc.data(), doc.id);
          if (group.leader?.userId == leaderId) {
            return group;
          }
        }
        return null;
      } catch (e2) {
        throw Exception('Failed to get group by leader: $e');
      }
    }
  }

  // Update group
  static Future<void> updateGroup(
    String groupId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _firestore.collection(_collection).doc(groupId).update(updates);
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  // Upload additional documents
  static Future<List<String>> uploadDocuments(
    String groupId,
    List<File> documents,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      List<String> documentUrls = [];
      for (int i = 0; i < documents.length; i++) {
        final file = documents[i];
        final fileName =
            'group_documents/${groupId}_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';
        final ref = _storage.ref().child(fileName);
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        documentUrls.add(downloadUrl);
      }

      // Update group with new document URLs
      final group = await getGroup(groupId);
      if (group != null) {
        final updatedUrls = [...group.documentUrls, ...documentUrls];
        await updateGroup(groupId, {
          'documentUrls': updatedUrls,
          'verificationStatus': VerificationStatus.pending
              .toString()
              .split('.')
              .last,
        });
      }

      return documentUrls;
    } catch (e) {
      throw Exception('Failed to upload documents: $e');
    }
  }

  // Admin functions
  static Future<void> approveGroup(String groupId, {String? adminNotes}) async {
    try {
      final updates = <String, dynamic>{
        'status': GroupStatus.approved.toString().split('.').last,
        'verificationStatus': VerificationStatus.approved
            .toString()
            .split('.')
            .last,
        'approvedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      await updateGroup(groupId, updates);
    } catch (e) {
      throw Exception('Failed to approve group: $e');
    }
  }

  static Future<void> rejectGroup(
    String groupId,
    String reason, {
    String? adminNotes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': GroupStatus.rejected.toString().split('.').last,
        'verificationStatus': VerificationStatus.rejected
            .toString()
            .split('.')
            .last,
        'rejectionReason': reason,
      };

      if (adminNotes != null) {
        updates['adminNotes'] = adminNotes;
      }

      await updateGroup(groupId, updates);
    } catch (e) {
      throw Exception('Failed to reject group: $e');
    }
  }

  // Get all groups for admin
  static Stream<List<Group>> getAllGroups() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Group.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get pending groups for admin approval
  static Stream<List<Group>> getPendingGroups() {
    return _firestore
        .collection(_collection)
        .where(
          'status',
          isEqualTo: GroupStatus.pending.toString().split('.').last,
        )
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Group.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get groups by status
  static Stream<List<Group>> getGroupsByStatus(GroupStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Group.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Delete group (admin only)
  static Future<void> deleteGroup(String groupId) async {
    try {
      // Get group to delete associated documents
      final group = await getGroup(groupId);
      if (group != null) {
        // Delete documents from storage
        for (String url in group.documentUrls) {
          try {
            final ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (e) {
            // Continue even if document deletion fails
            print('Failed to delete document: $e');
          }
        }
      }

      // Delete group document
      await _firestore.collection(_collection).doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  // Add member to group
  static Future<void> addMember(
    String groupId,
    String memberId,
    String memberName,
    String memberEmail, {
    MemberRole role = MemberRole.member,
  }) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) throw Exception('Group not found');

      // Check if user is already a member
      if (group.members.any((member) => member.userId == memberId)) {
        throw Exception('User is already a member of this group');
      }

      final newMember = GroupMember(
        userId: memberId,
        name: memberName,
        email: memberEmail,
        role: role,
        joinedAt: DateTime.now(),
        isActive: true,
      );

      final updatedMembers = [...group.members, newMember];

      await updateGroup(groupId, {
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  // Remove member from group
  static Future<void> removeMember(String groupId, String memberId) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) throw Exception('Group not found');

      final updatedMembers = group.members
          .where((member) => member.userId != memberId)
          .toList();

      await updateGroup(groupId, {
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  // Update member role
  static Future<void> updateMemberRole(
    String groupId,
    String memberId,
    MemberRole newRole,
  ) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) throw Exception('Group not found');

      final updatedMembers = group.members.map((member) {
        if (member.userId == memberId) {
          return GroupMember(
            userId: member.userId,
            name: member.name,
            email: member.email,
            role: newRole,
            joinedAt: member.joinedAt,
            isActive: member.isActive,
          );
        }
        return member;
      }).toList();

      await updateGroup(groupId, {
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update member role: $e');
    }
  }

  // Update member (generic update for any member field)
  static Future<void> updateMember(
    String groupId,
    String memberId, {
    String? name,
    String? email,
    MemberRole? role,
    bool? isActive,
  }) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) throw Exception('Group not found');

      final updatedMembers = group.members.map((member) {
        if (member.userId == memberId) {
          return GroupMember(
            userId: member.userId,
            name: name ?? member.name,
            email: email ?? member.email,
            role: role ?? member.role,
            joinedAt: member.joinedAt,
            isActive: isActive ?? member.isActive,
          );
        }
        return member;
      }).toList();

      await updateGroup(groupId, {
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  // Deactivate member (don't remove from group, just mark as inactive)
  static Future<void> deactivateMember(String groupId, String memberId) async {
    try {
      final group = await getGroup(groupId);
      if (group == null) throw Exception('Group not found');

      final updatedMembers = group.members.map((member) {
        if (member.userId == memberId) {
          return GroupMember(
            userId: member.userId,
            name: member.name,
            email: member.email,
            role: member.role,
            joinedAt: member.joinedAt,
            isActive: false,
          );
        }
        return member;
      }).toList();

      await updateGroup(groupId, {
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate member: $e');
    }
  }
}
