import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import '../models/user_role.dart';

class GroupAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new group organization
  Future<UserCredential?> registerGroupOrganization({
    required String organizationEmail,
    required String password,
    required String organizationName,
    required String leaderName,
    required String leaderEmail,
  }) async {
    try {
      // Create Firebase Auth account with organization email
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: organizationEmail.trim(),
        password: password.trim(),
      );

      // Update display name to organization name
      await result.user?.updateDisplayName(organizationName);

      // Create organization document in Firestore
      await _createOrganizationDocument(
        result.user!,
        organizationName,
        leaderName,
        leaderEmail,
      );

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with organization email and password
  Future<UserCredential?> signInWithOrganizationEmail(
    String organizationEmail,
    String password,
  ) async {
    try {
      print('🔐 Attempting group sign in with email: $organizationEmail');

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: organizationEmail.trim(),
        password: password.trim(),
      );

      print('✅ Group sign in successful for: ${result.user?.email}');
      await _updateLastLogin();
      return result;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Unexpected error during group sign in: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Get current user's group information
  Future<Group?> getCurrentUserGroup() async {
    try {
      final user = currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      print('🔍 Looking for organization data for user: ${user.uid}');

      // First check if this is a group organization account
      DocumentSnapshot orgDoc = await _firestore
          .collection('group_organizations')
          .doc(user.uid)
          .get();

      print('📄 Organization document exists: ${orgDoc.exists}');

      if (orgDoc.exists) {
        // This is a group organization account, get the associated group
        Map<String, dynamic> orgData = orgDoc.data() as Map<String, dynamic>;
        String? groupId = orgData['groupId'];

        print('🔗 Group ID found: $groupId');

        if (groupId != null && groupId.isNotEmpty && groupId != 'null') {
          print('🔍 Looking for group document: $groupId');

          DocumentSnapshot groupDoc = await _firestore
              .collection('groups')
              .doc(groupId)
              .get();

          print('📄 Group document exists: ${groupDoc.exists}');

          if (groupDoc.exists) {
            return Group.fromMap(
              groupDoc.data() as Map<String, dynamic>,
              groupDoc.id,
            );
          } else {
            print('❌ Group document not found for ID: $groupId');
          }
        } else {
          print(
            '❌ No valid groupId found in organization data. Current value: $groupId',
          );
          print('📋 Organization data: $orgData');
        }
      } else {
        print('❌ No organization document found for user: ${user.uid}');
      }

      return null;
    } catch (e) {
      print('❌ Error getting current user group: $e');
      if (e.toString().contains('permission-denied')) {
        print('🚨 Permission denied - check Firestore security rules');
        print(
          '📝 Make sure rules allow read access to group_organizations and groups collections',
        );
      }
      return null;
    }
  }

  // Get current user's role within the group
  Future<MemberRole?> getCurrentUserRole() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final group = await getCurrentUserGroup();
      if (group == null) return null;

      // Check organization document for member role
      DocumentSnapshot orgDoc = await _firestore
          .collection('group_organizations')
          .doc(user.uid)
          .get();

      if (orgDoc.exists) {
        Map<String, dynamic> orgData = orgDoc.data() as Map<String, dynamic>;
        String? currentMemberEmail = orgData['currentMemberEmail'];

        if (currentMemberEmail != null) {
          // Find the member with this email in the group
          for (GroupMember member in group.members) {
            if (member.email == currentMemberEmail && member.isActive) {
              return member.role;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting current user role: $e');
      return null;
    }
  }

  // Set current member accessing the group account
  Future<void> setCurrentMember(String memberEmail) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await _firestore.collection('group_organizations').doc(user.uid).update({
        'currentMemberEmail': memberEmail,
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to set current member: $e';
    }
  }

  // Get all members who can access this group account
  Future<List<GroupMember>> getAccessibleMembers() async {
    try {
      final group = await getCurrentUserGroup();
      if (group == null) return [];

      // Return all active members
      return group.members.where((member) => member.isActive).toList();
    } catch (e) {
      print('Error getting accessible members: $e');
      return [];
    }
  }

  // Check if current user has specific permissions
  Future<bool> hasPermission(String permission) async {
    try {
      final role = await getCurrentUserRole();
      if (role == null) return false;

      switch (permission) {
        case 'add_members':
        case 'remove_members':
        case 'edit_group':
          return role == MemberRole.leader || role == MemberRole.chair;
        case 'manage_finances':
          return role == MemberRole.leader ||
              role == MemberRole.chair ||
              role == MemberRole.treasurer;
        case 'manage_documents':
          return role == MemberRole.leader ||
              role == MemberRole.chair ||
              role == MemberRole.secretary;
        case 'view_analytics':
          return true; // All members can view analytics
        default:
          return false;
      }
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  // Link group to organization
  Future<void> linkGroupToOrganization(String groupId) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await _firestore.collection('group_organizations').doc(user.uid).update({
        'groupId': groupId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to link group to organization: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Create organization document in Firestore
  Future<void> _createOrganizationDocument(
    User user,
    String organizationName,
    String leaderName,
    String leaderEmail,
  ) async {
    await _firestore.collection('group_organizations').doc(user.uid).set({
      'uid': user.uid,
      'organizationEmail': user.email,
      'organizationName': organizationName,
      'leaderName': leaderName,
      'leaderEmail': leaderEmail,
      'currentMemberEmail': leaderEmail, // Initially set to leader
      'role': UserRole.group.name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'groupId': null, // Will be set when group is created
    });
  }

  // Update last login time
  Future<void> _updateLastLogin() async {
    try {
      final user = currentUser;
      if (user == null) return;

      await _firestore.collection('group_organizations').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail for last login update
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No organization found with this email address. Please check your email or register.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your organization email and password.';
      case 'email-already-in-use':
        return 'An organization account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This organization account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return 'Authentication failed: ${e.message ?? "Unknown error"}. Please try again.';
    }
  }
}
