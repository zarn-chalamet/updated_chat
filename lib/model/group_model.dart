import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String groupName;
  final List<String> members;
  final String admin;
  final String pf_path;
  final Timestamp createdAt;

  GroupModel(
      {required this.groupId,
      required this.groupName,
      required this.members,
      required this.admin,
      required this.pf_path,
      required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'members': members,
      'admin': admin,
      'pf_path': pf_path,
      'createdAt': createdAt,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> data) {
    return GroupModel(
      groupId: data['groupId'] as String,
      groupName: data['groupName'] as String,
      members: List<String>.from(data['members']),
      admin: data['admin'] as String,
      pf_path: data['pf_path'] as String,
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
