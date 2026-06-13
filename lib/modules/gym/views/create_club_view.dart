import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/gym/controllers/gym_controller.dart';

class AddGymView extends GetView<ClubController> {
  const AddGymView({super.key});

  @override
  Widget build(BuildContext context) {
    final ClubController controller = Get.find<ClubController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'REGISTER NEW GYM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.add_business, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            // ---- Club Name (clubName) ----
            _buildLabel('Gym Name *'),
            _buildTextField(
              controller: controller.nameController,
              hint: 'e.g., Alpha Fighting Academy',
              icon: Icons.business,
            ),
            const SizedBox(height: 20),

            // ---- Owner Email ----
            _buildLabel('Owner Email *'),
            _buildTextField(
              controller: controller.emailController,
              hint: 'owner@example.com',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // ---- Owner Password ----
            _buildLabel('Owner Password *'),
            _buildTextField(
              controller: controller.passwordController,
              hint: 'Create a strong password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // ---- Owner Full Name ----
            _buildLabel('Owner Full Name *'),
            _buildTextField(
              controller: controller.fullNameController,
              hint: 'John Doe',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // ---- Phone Number (optional) ----
            _buildLabel('Phone Number (Optional)'),
            _buildTextField(
              controller: controller.phoneController,
              hint: '+1 234 567 8900',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // ---- City (optional) ----
            _buildLabel('City (Optional)'),
            _buildTextField(
              controller: controller.cityController,
              hint: 'e.g., Los Angeles',
              icon: Icons.location_city,
            ),
            const SizedBox(height: 20),

            // ---- Address (optional) ----
            _buildLabel('Address (Optional)'),
            _buildTextField(
              controller: controller.addressController,
              hint: 'Street, building, etc.',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),

            // ---- Description (optional) ----
            _buildLabel('Description (Optional)'),
            _buildTextField(
              controller: controller.descriptionController,
              hint: 'Tell us about your gym...',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // ---- Logo URL (optional) ----
            _buildLabel('Logo URL (Optional)'),
            _buildTextField(
              controller: controller.logoUrlController,
              hint: 'https://example.com/logo.png',
              icon: Icons.image,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            // Submit button
            Obx(() {
              final isLoading = controller.isLoading.value;
              return ElevatedButton(
                onPressed: isLoading ? null : () => _submitForm(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'CREATE GYM',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
              );
            }),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'All fields marked with * are required.\nAfter creation, your gym will be pending admin approval.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: const Color(0xFFE31837), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE31837), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  void _submitForm(ClubController controller) async {
    // Basic validation (more in controller)
    if (controller.nameController.text.trim().isEmpty) {
      _showSnackBar('Error', 'Gym name is required');
      return;
    }
    if (controller.emailController.text.trim().isEmpty) {
      _showSnackBar('Error', 'Owner email is required');
      return;
    }
    if (controller.passwordController.text.trim().isEmpty) {
      _showSnackBar('Error', 'Owner password is required');
      return;
    }
    if (controller.fullNameController.text.trim().isEmpty) {
      _showSnackBar('Error', 'Owner full name is required');
      return;
    }

    await controller.createClub();

    // Optional: close after success
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.clubs.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isSnackbarOpen) Get.back();
        });
      }
    });
  }

  void _showSnackBar(String title, String message) {
    Get.snackbar(title, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }
}