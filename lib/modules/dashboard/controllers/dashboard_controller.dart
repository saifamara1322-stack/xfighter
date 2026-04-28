import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/auth_repository.dart';
import 'package:xfighter/data/models/user_model.dart';

class DashboardController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  
  var currentUser = Rx<User?>(null);
  var isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }
  
  Future<void> loadCurrentUser() async {
    currentUser.value = await _authRepository.getCurrentUser();
  }
  
  bool isFighter() => currentUser.value?.role == UserRole.fighter;
  bool isCoach() => currentUser.value?.role == UserRole.coach;
  bool isOrganizer() => currentUser.value?.role == UserRole.organizer;
  bool isAdmin() => currentUser.value?.role == UserRole.admin;
  bool isReferee() => currentUser.value?.role == UserRole.referee;
  
  Future<void> logout() async {
    await _authRepository.logout();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
  
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'LOGOUT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
            ),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}