import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF1A1A1A),
              const Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.03,
                child: Icon(
                  Icons.sports_mma,
                  size: 300,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Opacity(
                opacity: 0.03,
                child: Icon(
                  Icons.shield,
                  size: 350,
                  color: Colors.white,
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
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
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.sports_mma,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'XFIGHTER',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE31837),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'TUNISIA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
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
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFE31837).withOpacity(0.15),
                                          const Color(0xFFB8102E).withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE31837).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 16,
                                              color: Color(0xFFE31837),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'DEMO ACCOUNTS',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: Colors.white70,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _buildDemoAccountRow('🥊 FIGHTER', 'mohamed.fighter@example.com'),
                                        const SizedBox(height: 8),
                                        _buildDemoAccountRow('🎯 COACH', 'nour.coach@example.com'),
                                        const SizedBox(height: 8),
                                        _buildDemoAccountRow('📋 ORGANIZER', 'youssef.organizer@example.com'),
                                        const SizedBox(height: 8),
                                        _buildDemoAccountRow('🛡️ REFEREE', 'sirine.ref@example.com'),
                                        const SizedBox(height: 8),
                                        _buildDemoAccountRow('👑 ADMIN', 'admin@example.com'),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            '🔓 Any password works for demo',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 28),
                                  
                                  TextField(
                                    controller: authController.emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'EMAIL ADDRESS',
                                      labelStyle: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: Color(0xFFE31837),
                                      ),
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
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  Obx(() => TextField(
                                    controller: authController.passwordController,
                                    obscureText: authController.obscurePassword.value,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'PASSWORD',
                                      labelStyle: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                      hintText: 'Enter your password',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFFE31837),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          authController.obscurePassword.value
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white54,
                                        ),
                                        onPressed: authController.togglePasswordVisibility,
                                      ),
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
                                  )),
                                  
                                  const SizedBox(height: 32),
                                  
                                  Obx(() => SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: authController.isLoading.value
                                          ? null
                                          : authController.login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFE31837),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
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
                                              'ENTER THE OCTAGON',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                    ),
                                  )),
                                  
                                  const SizedBox(height: 20),
                                  
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
                                  
                                  TextButton(
                                    onPressed: () {
                                      Get.toNamed('/register');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'NO ACCOUNT? ',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'CREATE ONE',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDemoAccountRow(String role, String email) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Color(0xFFE31837),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          role,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            email,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}