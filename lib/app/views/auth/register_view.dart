import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});
  
  final AuthController authController = Get.find<AuthController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'CREATE FIGHTER PROFILE',
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
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background fighter elements
          Positioned(
            top: -30,
            right: -30,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.sports_mma,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.03,
              child: Icon(
                Icons.emoji_events,
                size: 220,
                color: Colors.white,
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Icon - Octagon style
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE31837),
                        Color(0xFFB8102E),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE31837).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_add_alt_1,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE31837),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NEW CHALLENGER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Card - Glassmorphic
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Name Row - First & Last
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFighterTextField(
                                    controller: authController.firstNameController,
                                    label: 'FIRST NAME',
                                    hint: 'Enter first name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildFighterTextField(
                                    controller: authController.lastNameController,
                                    label: 'LAST NAME',
                                    hint: 'Enter last name',
                                    icon: Icons.person_outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Email Field
                            _buildFighterTextField(
                              controller: authController.emailController,
                              label: 'EMAIL ADDRESS',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            
                            // Phone Field
                            _buildFighterTextField(
                              controller: authController.phoneController,
                              label: 'PHONE NUMBER',
                              hint: 'Optional',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            
                            // Role Selection - FighterRec Fighter Card Style
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.assignment_ind,
                                          size: 18,
                                          color: Color(0xFFE31837),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'SELECT YOUR ROLE',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(() => Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: UserRole.values.map((role) {
                                        final isSelected = authController.selectedRole.value == role;
                                        return _buildRoleChip(role, isSelected, () {
                                          authController.selectedRole.value = role;
                                        });
                                      }).toList(),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Password Field
                            Obx(() => Column(
                              children: [
                                _buildFighterTextField(
                                  controller: authController.passwordController,
                                  label: 'PASSWORD',
                                  hint: 'Create a password (min. 6 characters)',
                                  icon: Icons.lock_outline,
                                  obscureText: authController.obscurePassword.value,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authController.obscurePassword.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    onPressed: authController.togglePasswordVisibility,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Password Requirements - Fighter style
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE31837).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE31837).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 14,
                                        color: const Color(0xFFE31837),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Minimum 6 characters required',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                            const SizedBox(height: 32),
                            
                            // Register Button - Fight Ready
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : authController.register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE31837),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                child: authController.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'JOIN THE FIGHT',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                              ),
                            )),
                            const SizedBox(height: 20),
                            
                            // VS Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'VS',
                                    style: TextStyle(
                                      color: const Color(0xFFE31837),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Login Link
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: 'ALREADY HAVE AN ACCOUNT? ',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'SIGN IN',
                                      style: TextStyle(
                                        color: Color(0xFFE31837),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFighterTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: const Color(0xFFE31837),
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE31837),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
  
  Widget _buildRoleChip(UserRole role, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE31837)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getRoleIcon(role),
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              _getRoleDisplay(role),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.fighter:
        return Icons.sports_mma;
      case UserRole.coach:
        return Icons.school;
      case UserRole.organizer:
        return Icons.event;
      case UserRole.referee:
        return Icons.gavel;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
  
  String _getRoleDisplay(UserRole role) {
    switch (role) {
      case UserRole.fighter:
        return 'Fighter';
      case UserRole.coach:
        return 'Coach';
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.referee:
        return 'Referee';
      case UserRole.admin:
        return 'Admin';
    }
  }
}