import '../../../../core/base/base_provider.dart';
import '../../domain/models/group_model.dart';
import '../../data/services/group_service.dart';
import '../../../auth/domain/models/user_model.dart';

/// Group Provider
/// Manages group state and provides group methods to the UI

class GroupProvider extends BaseProvider {
  final GroupService _groupService = GroupService();

  List<GroupModel> _allGroups = [];
  List<GroupModel> _myGroups = [];
  GroupModel? _selectedGroup;
  List<UserModel> _groupMembers = [];

  /// Getters
  List<GroupModel> get allGroups => _allGroups;
  List<GroupModel> get myGroups => _myGroups;
  GroupModel? get selectedGroup => _selectedGroup;
  List<UserModel> get groupMembers => _groupMembers;

  /// Load all groups
  Future<void> loadAllGroups() async {
    await executeOperation(() async {
      _allGroups = await _groupService.getAllGroups();
      notifyListeners();
    });
  }

  /// Load user's groups
  Future<void> loadMyGroups(String userId) async {
    await executeOperation(() async {
      _myGroups = await _groupService.getMyGroups(userId);
      notifyListeners();
    });
  }

  /// Load single group by ID
  Future<void> loadGroup(String groupId) async {
    await executeOperation(() async {
      _selectedGroup = await _groupService.getGroupById(groupId);
      notifyListeners();
    });
  }

  /// Create new group
  Future<bool> createGroup(GroupModel group) async {
    final result = await executeOperation(() async {
      final createdGroup = await _groupService.createGroup(group);

      // Add to local lists
      _allGroups.add(createdGroup);
      _myGroups.add(createdGroup);

      notifyListeners();
      return createdGroup;
    });
    return result != null;
  }

  /// Update group
  Future<bool> updateGroup(GroupModel group) async {
    final result = await executeOperation(() async {
      await _groupService.updateGroup(group);

      // Update in local lists
      _updateGroupInLists(group);

      if (_selectedGroup?.groupId == group.groupId) {
        _selectedGroup = group;
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Delete group
  Future<bool> deleteGroup(String groupId) async {
    final result = await executeOperation(() async {
      await _groupService.deleteGroup(groupId);

      // Remove from local lists
      _removeGroupFromLists(groupId);

      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = null;
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Join group
  Future<bool> joinGroup(String groupId, String userId) async {
    final result = await executeOperation(() async {
      await _groupService.joinGroup(groupId, userId);

      // Refresh the group to get updated member count
      final updatedGroup = await _groupService.getGroupById(groupId);
      if (updatedGroup != null) {
        _updateGroupInLists(updatedGroup);

        // Add to my groups
        if (!_myGroups.any((g) => g.groupId == groupId)) {
          _myGroups.add(updatedGroup);
        }

        if (_selectedGroup?.groupId == groupId) {
          _selectedGroup = updatedGroup;
        }
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Leave group
  Future<bool> leaveGroup(String groupId, String userId) async {
    final result = await executeOperation(() async {
      await _groupService.leaveGroup(groupId, userId);

      // Refresh the group to get updated member count
      final updatedGroup = await _groupService.getGroupById(groupId);
      if (updatedGroup != null) {
        _updateGroupInLists(updatedGroup);

        // Remove from my groups
        _myGroups.removeWhere((g) => g.groupId == groupId);

        if (_selectedGroup?.groupId == groupId) {
          _selectedGroup = updatedGroup;
        }
      }

      notifyListeners();
      return true;
    });
    return result ?? false;
  }

  /// Load group members
  Future<void> loadGroupMembers(String groupId) async {
    await executeOperation(() async {
      _groupMembers = await _groupService.getGroupMembers(groupId);
      notifyListeners();
    });
  }

  /// Search groups by name
  Future<List<GroupModel>> searchGroups(String query) async {
    if (query.isEmpty) return _allGroups;

    return _allGroups
        .where((group) =>
            group.name.toLowerCase().contains(query.toLowerCase()) ||
            group.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filter groups by category
  List<GroupModel> filterByCategory(String category) {
    if (category == 'All') return _allGroups;
    return _allGroups.where((group) => group.category == category).toList();
  }

  /// Helper method to update group in all lists
  void _updateGroupInLists(GroupModel group) {
    // Update in all groups
    final allIndex = _allGroups.indexWhere((g) => g.groupId == group.groupId);
    if (allIndex != -1) {
      _allGroups[allIndex] = group;
    }

    // Update in my groups
    final myIndex = _myGroups.indexWhere((g) => g.groupId == group.groupId);
    if (myIndex != -1) {
      _myGroups[myIndex] = group;
    }
  }

  /// Helper method to remove group from all lists
  void _removeGroupFromLists(String groupId) {
    _allGroups.removeWhere((g) => g.groupId == groupId);
    _myGroups.removeWhere((g) => g.groupId == groupId);
  }

  /// Refresh all group lists
  Future<void> refreshGroups(String userId) async {
    await Future.wait([
      loadAllGroups(),
      loadMyGroups(userId),
    ]);
  }

  /// Clear all data
  void clear() {
    _allGroups = [];
    _myGroups = [];
    _selectedGroup = null;
    _groupMembers = [];
    notifyListeners();
  }
}
