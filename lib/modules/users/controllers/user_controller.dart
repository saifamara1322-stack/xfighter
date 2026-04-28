import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  
  var users = <User>[].obs;
  var isLoading = false.obs;
  var filterStatus = 'all'.obs;
  var filterRole = 'all'.obs;
  var searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }
  
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final fetchedUsers = await _userRepository.getUsers();
      users.value = fetchedUsers;
    } catch (e) {
      _showSnackbar('Error', 'Failed to fetch users: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addUser(User user) async {
    try {
      isLoading.value = true;
      final newUser = await _userRepository.addUser(user);
      users.add(newUser);
      _showSnackbar('Success', 'User added successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to add user: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateUser(User user) async {
    try {
      isLoading.value = true;
      final updatedUser = await _userRepository.updateUser(user);
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }
      _showSnackbar('Success', 'User updated successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to update user: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      await _userRepository.deleteUser(userId);
      users.removeWhere((user) => user.id == userId);
      _showSnackbar('Success', 'User deleted successfully');
    } catch (e) {
      _showSnackbar('Error', 'Failed to delete user: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  
  List<User> get filteredUsers {
    return users.where((user) {
      // Apply search filter (search by full name or email)
      if (searchQuery.value.isNotEmpty &&
          !user.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) &&
          !user.email.toLowerCase().contains(searchQuery.value.toLowerCase())) {
        return false;
      }
      
      // Apply status filter
      if (filterStatus.value != 'all') {
        final statusValue = UserStatus.stringToStatus(filterStatus.value);
        if (user.status != statusValue) {
          return false;
        }
      }
      
      // Apply role filter
      if (filterRole.value != 'all') {
        final roleValue = UserRole.stringToRole(filterRole.value);
        if (user.role != roleValue) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
  
  List<UserRole> get availableRoles => UserRole.values;
  List<UserStatus> get availableStatuses => UserStatus.values;
  
  void updateFilterStatus(String status) {
    filterStatus.value = status;
  }
  
  void updateFilterRole(String role) {
    filterRole.value = role;
  }
  
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void clearFilters() {
    filterStatus.value = 'all';
    filterRole.value = 'all';
    searchQuery.value = '';
  }
  
  void _showSnackbar(String title, String message, {Color backgroundColor = Colors.green}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    });
  }
}