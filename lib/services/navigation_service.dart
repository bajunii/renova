import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';
import '../screens/dashboards/member_dashboard.dart';
import '../screens/dashboards/group_dashboard.dart';
import '../screens/dashboards/business_dashboard.dart';
import '../screens/dashboard_screen.dart';

class NavigationService {
  static Future<Widget> getDashboardForUser(String userId) async {
    try {
      print('🔍 Getting dashboard for user: $userId');

      // Get user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? roleString = userData['role'] as String?;

        print('👤 User role found: $roleString');

        if (roleString != null) {
          UserRole role = UserRole.fromString(roleString);

          switch (role) {
            case UserRole.member:
              print('🚀 Loading Member Dashboard');
              return const MemberDashboard();
            case UserRole.group:
              print('🚀 Loading Group Dashboard');
              return const GroupDashboard();
            case UserRole.business:
              print('🚀 Loading Business Dashboard');
              return const BusinessDashboard();
          }
        }
      }

      print('⚠️ No role found, using default dashboard');
    } catch (e) {
      print('❌ Error getting user role: $e');
    }

    // Fallback to default dashboard
    print('🚀 Loading Default Dashboard');
    return const DashboardScreen();
  }

  static UserRole getRoleFromString(String? roleString) {
    if (roleString == null) return UserRole.member;
    return UserRole.fromString(roleString);
  }

  static Future<Map<String, dynamic>> getUserRoleInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? roleString = userData['role'] as String?;
        UserRole role = getRoleFromString(roleString);

        return {
          'role': role,
          'roleString': roleString ?? 'member',
          'displayName': role.displayName,
          'description': role.description,
          'userData': userData,
        };
      }
    } catch (e) {
      print('❌ Error getting user role info: $e');
    }

    return {
      'role': UserRole.member,
      'roleString': 'member',
      'displayName': 'Member',
      'description': 'Individual user with access to basic features',
      'userData': {},
    };
  }
}
