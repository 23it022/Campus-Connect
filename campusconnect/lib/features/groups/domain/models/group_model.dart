import 'package:cloud_firestore/cloud_firestore.dart';

/// Group Model
/// Represents a student group or community

class GroupModel {
  final String groupId;
  final String name;
  final String description;
  final String imageUrl;
  final String adminId;
  final String adminName;
  final List<String> members;
  final int membersCount;
  final String category;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupModel({
    required this.groupId,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.adminId,
    required this.adminName,
    List<String>? members,
    this.membersCount = 1,
    this.category = 'General',
    this.isPrivate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : members = members ?? [adminId],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'adminId': adminId,
      'adminName': adminName,
      'members': members,
      'membersCount': membersCount,
      'category': category,
      'isPrivate': isPrivate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? 'Unknown',
      members: List<String>.from(map['members'] ?? []),
      membersCount: map['membersCount'] ?? 0,
      category: map['category'] ?? 'General',
      isPrivate: map['isPrivate'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory GroupModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel.fromMap(data);
  }

  bool isMember(String userId) => members.contains(userId);

  bool isAdmin(String userId) => adminId == userId;

  GroupModel copyWith({
    String? groupId,
    String? name,
    String? description,
    String? imageUrl,
    String? adminId,
    String? adminName,
    List<String>? members,
    int? membersCount,
    String? category,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      members: members ?? this.members,
      membersCount: membersCount ?? this.membersCount,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
