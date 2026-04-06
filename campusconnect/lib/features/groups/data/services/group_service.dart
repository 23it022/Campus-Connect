import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/group_model.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../../shared/constants/constants.dart';

/// Group Service
/// Handles all Firebase operations for groups

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _groupsCollection = FirebaseCollections.groups;

  /// Get all groups (public only for non-members)
  Future<List<GroupModel>> getAllGroups() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_groupsCollection)
          .where('isPrivate', isEqualTo: false)
          .orderBy('membersCount', descending: true)
          .get();

      return snapshot.docs.map((doc) => GroupModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get groups: $e');
    }
  }

  /// Get group by ID
  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_groupsCollection).doc(groupId).get();

      if (!doc.exists) return null;

      return GroupModel.fromDocument(doc);
    } catch (e) {
      throw Exception('Failed to get group: $e');
    }
  }

  /// Get groups user is a member of
  Future<List<GroupModel>> getMyGroups(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_groupsCollection)
          .where('members', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => GroupModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get my groups: $e');
    }
  }

  /// Create new group
  Future<GroupModel> createGroup(GroupModel group) async {
    try {
      final docRef = _firestore.collection(_groupsCollection).doc();
      final groupWithId = group.copyWith(groupId: docRef.id);

      await docRef.set(groupWithId.toMap());

      return groupWithId;
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }

  /// Update existing group
  Future<void> updateGroup(GroupModel group) async {
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(group.groupId)
          .update(group.toMap());
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection(_groupsCollection).doc(groupId).delete();
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  /// Join group (add user to members)
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      final docRef = _firestore.collection(_groupsCollection).doc(groupId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Group not found');
        }

        final group = GroupModel.fromDocument(snapshot);

        if (group.isMember(userId)) {
          throw Exception('Already a member of this group');
        }

        transaction.update(docRef, {
          'members': FieldValue.arrayUnion([userId]),
          'membersCount': FieldValue.increment(1),
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to join group: $e');
    }
  }

  /// Leave group (remove user from members)
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      final docRef = _firestore.collection(_groupsCollection).doc(groupId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Group not found');
        }

        final group = GroupModel.fromDocument(snapshot);

        if (!group.isMember(userId)) {
          throw Exception('Not a member of this group');
        }

        if (group.isAdmin(userId)) {
          throw Exception(
              'Admin cannot leave the group. Delete the group instead.');
        }

        transaction.update(docRef, {
          'members': FieldValue.arrayRemove([userId]),
          'membersCount': FieldValue.increment(-1),
          'updatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }

  /// Search groups by name
  Future<List<GroupModel>> searchGroups(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_groupsCollection)
          .where('isPrivate', isEqualTo: false)
          .orderBy('name')
          .startAt([query]).endAt([query + '\uf8ff']).get();

      return snapshot.docs.map((doc) => GroupModel.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search groups: $e');
    }
  }

  /// Get group members (user profiles)
  Future<List<UserModel>> getGroupMembers(String groupId) async {
    try {
      final group = await getGroupById(groupId);
      if (group == null || group.members.isEmpty) {
        return [];
      }

      // Get user profiles for all members
      final List<UserModel> members = [];
      for (final userId in group.members) {
        final userDoc = await _firestore
            .collection(FirebaseCollections.users)
            .doc(userId)
            .get();
        if (userDoc.exists) {
          members.add(UserModel.fromDocument(userDoc));
        }
      }

      return members;
    } catch (e) {
      throw Exception('Failed to get group members: $e');
    }
  }

  /// Get groups stream for real-time updates
  Stream<List<GroupModel>> getGroupsStream() {
    try {
      return _firestore
          .collection(_groupsCollection)
          .where('isPrivate', isEqualTo: false)
          .orderBy('membersCount', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get groups stream: $e');
    }
  }

  /// Get my groups stream
  Stream<List<GroupModel>> getMyGroupsStream(String userId) {
    try {
      return _firestore
          .collection(_groupsCollection)
          .where('members', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GroupModel.fromDocument(doc))
              .toList());
    } catch (e) {
      throw Exception('Failed to get my groups stream: $e');
    }
  }
}
