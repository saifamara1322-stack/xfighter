import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';

class SharedProfileView extends StatelessWidget {
  SharedProfileView({super.key});

  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Obx(() {
        final user = _authController.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.role.color.withOpacity(0.1),
                  border: Border.all(color: user.role.color, width: 3),
                ),
                child: Center(
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: user.role.color),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name and Role Badge
              Text(
                user.fullName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: user.role.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: user.role.color),
                ),
                child: Text(
                  user.role.displayName,
                  style: TextStyle(color: user.role.color, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 8),
              
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 10, color: user.status.color),
                    const SizedBox(width: 6),
                    Text(
                      user.status.displayName,
                      style: TextStyle(color: user.status.color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info Cards
              _buildInfoCard('Personal Details', [
                _buildInfoRow(Icons.email, 'Email', user.email),
                _buildInfoRow(Icons.phone, 'Phone', user.phoneNumber ?? 'Not provided'),
                _buildInfoRow(Icons.fingerprint, 'User ID', user.id),
              ]),

              const SizedBox(height: 16),

              _buildInfoCard('Account Settings', [
                _buildActionRow(Icons.lock, 'Change Password', () => _showChangePasswordDialog(context)),
                _buildActionRow(Icons.edit, 'Edit Profile', () => _showEditProfileDialog(context, user)),
                if (user.role == UserRole.FIGHTER || user.role == UserRole.REFEREE)
                  _buildActionRow(Icons.description, 'Manage Documents', () {
                    Get.snackbar('Coming Soon', 'Document management is not yet implemented', colorText: Colors.white);
                  }),
              ]),
            ],
          ),
        );
      }),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Change Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Current Password', labelStyle: TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'New Password', labelStyle: TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Confirm New Password', labelStyle: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837)),
            onPressed: isSubmitting.value ? null : () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar('Error', 'Passwords do not match', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              if (newPasswordController.text.length < 6) {
                Get.snackbar('Error', 'Password must be at least 6 characters', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              
              isSubmitting.value = true;
              // Simulate API call
              await Future.delayed(const Duration(seconds: 1));
              isSubmitting.value = false;
              
              Get.back();
              Get.snackbar('Success', 'Password changed successfully', backgroundColor: Colors.green, colorText: Colors.white);
            },
            child: isSubmitting.value 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final RxBool isSubmitting = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Full Name', labelStyle: TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.white54)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Email and Role cannot be changed here.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837)),
            onPressed: isSubmitting.value ? null : () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Name cannot be empty', backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              isSubmitting.value = true;
              // Simulate API call
              await Future.delayed(const Duration(seconds: 1));
              
              // Optimistically update AuthController's current user (simulate refresh)
              final updatedUser = User(
                id: user.id,
                email: user.email,
                fullName: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
                role: user.role,
                status: user.status,
                countryId: user.countryId,
              );
              _authController.currentUser.value = updatedUser;
              
              isSubmitting.value = false;
              Get.back();
              Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
            },
            child: isSubmitting.value 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE31837), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
