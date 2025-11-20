import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsModel {
  final String id;
  String name;
  String? profile;
  String description;
  String location;
  String email;
  String phone;
  List<Member> members;
  DateTime createdAt;

  GroupsModel({
    required this.id,
    required this.name,
    this.profile,
    required this.description,
    required this.location,
    required this.email,
    required this.phone,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profile": profile,
      "description": description,
      "location": location,
      "email": email,
      "phone": phone,
      "members": members.map((m) => m.toJson()).toList(),
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }
}

class Member {
  final String id;
  String name;
  String? profile;
  String email;
  String phone;
  String idNo;
  DateTime joinedAt;

  Member({
    required this.id,
    required this.name,
    this.profile,
    required this.email,
    required this.phone,
    required this.idNo,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "profile": profile,
      "email": email,
      "phone": phone,
      "idNo": idNo,
      "joinedAt": Timestamp.fromDate(joinedAt),
    };
  }
}
