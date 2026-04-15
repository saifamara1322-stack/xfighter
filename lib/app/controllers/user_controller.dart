import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

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
  
  // Helper method to safely show snackbars
  void _showSnackbar(String title, String message, {Color backgroundColor = Colors.green}) {
    // Ensure the widget tree is built before showing snackbar
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
  
  List<User> get filteredUsers {
    List<User> filtered = users;
    
    if (filterStatus.value != 'all') {
      filtered = filtered.where((user) => 
        user.status.toString().split('.').last == filterStatus.value
      ).toList();
    }
    
    if (filterRole.value != 'all') {
      filtered = filtered.where((user) => 
        user.role.toString().split('.').last == filterRole.value
      ).toList();
    }
    
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((user) =>
        user.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        user.email.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  int get activeUsersCount => users.where((u) => u.isActive).length;
  int get pendingUsersCount => users.where((u) => u.isPending).length;
  int get suspendedUsersCount => users.where((u) => u.isSuspended).length;
  
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final userList = await _userRepository.getAllUsers();
      users.assignAll(userList);
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de charger les utilisateurs: $e',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
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
  
  Future<void> updateUserStatus(String userId, UserStatus newStatus) async {
    try {
      final user = users.firstWhere((u) => u.id == userId);
      final updatedData = {
        ...user.toJson(),
        'status': UserStatus.statusToString(newStatus),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _userRepository.updateUser(userId, updatedData);
      await fetchUsers(); // Refresh list
      
      _showSnackbar(
        'Succès',
        'Statut utilisateur mis à jour',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de mettre à jour le statut: $e',
        backgroundColor: Colors.red,
      );
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      users.removeWhere((user) => user.id == userId);
      
      _showSnackbar(
        'Succès',
        'Utilisateur supprimé',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      _showSnackbar(
        'Erreur',
        'Impossible de supprimer l\'utilisateur: $e',
        backgroundColor: Colors.red,
      );
    }
  }
}