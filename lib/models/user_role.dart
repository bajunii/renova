import 'package:flutter/material.dart';

enum UserRole {
  member,
  group,
  business;

  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Member';
      case UserRole.group:
        return 'Group';
      case UserRole.business:
        return 'Business/Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.member:
        return 'Individual user with access to basic features';
      case UserRole.group:
        return 'Group administrator with team management features';
      case UserRole.business:
        return 'Business owner or admin with full access';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.member:
        return Icons.person;
      case UserRole.group:
        return Icons.group;
      case UserRole.business:
        return Icons.business;
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'member':
        return UserRole.member;
      case 'group':
        return UserRole.group;
      case 'business':
        return UserRole.business;
      default:
        return UserRole.member;
    }
  }
}
