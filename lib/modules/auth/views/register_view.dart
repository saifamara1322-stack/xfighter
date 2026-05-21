import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/modules/fighter/controllers/fighter_controller.dart';
import 'package:xfighter/modules/registration/controllers/registration_controller.dart';
import 'package:xfighter/data/models/country_model.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  static const _red = Color(0xFFE31837);
  static const _bg = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    final AuthController c = Get.put(AuthController());
    final RegistrationController regController = Get.put(RegistrationController());

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'CREATE ACCOUNT',
          style: TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16),
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
          // ── Decorative icons ──────────────────────────────────────────────
          Positioned(
            top: -30,
            right: -30,
            child: Opacity(
              opacity: 0.03,
              child: const Icon(Icons.sports_mma, size: 200, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.03,
              child: const Icon(Icons.emoji_events, size: 220, color: Colors.white),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add_alt_1,
                        size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NEW CHALLENGER',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Role tab selector ─────────────────────────────────────
                _RoleTabBar(controller: c),
                const SizedBox(height: 24),

                // ── Shared fields card ────────────────────────────────────
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('PERSONAL INFORMATION'),
                      const SizedBox(height: 16),
                      _Field(
                        controller: c.fullNameController,
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _Field(
                        controller: c.emailController,
                        label: 'EMAIL ADDRESS',
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _Field(
                        controller: c.phoneController,
                        label: 'PHONE NUMBER',
                        hint: 'Optional',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      // Country dropdown with API integration
                      _CountryDropdown(controller: c, regController: regController),
                      const SizedBox(height: 16),
                      Obx(() => _Field(
                            controller: c.passwordController,
                            label: 'PASSWORD',
                            hint: 'Min. 6 characters',
                            icon: Icons.lock_outline,
                            obscureText: c.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                c.obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: c.togglePasswordVisibility,
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Role-specific fields ──────────────────────────────────
                Obx(() => c.registerRoleIndex.value == 0
                    ? _FighterFields(controller: c)
                    : _RefereeFields(controller: c)),

                const SizedBox(height: 24),

                // ── Submit button ─────────────────────────────────────────
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: c.isLoading.value ? null : c.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: c.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )
                            : const Text(
                                'JOIN THE FIGHT',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5),
                              ),
                      ),
                    )),
                const SizedBox(height: 20),

                // ── Sign in link ──────────────────────────────────────────
                _Divider(),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.back(),
                  child: RichText(
                    text: const TextSpan(
                      text: 'ALREADY HAVE AN ACCOUNT? ',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'SIGN IN',
                          style: TextStyle(
                            color: _red,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role tab bar
// ─────────────────────────────────────────────────────────────────────────────

class _RoleTabBar extends StatelessWidget {
  final AuthController controller;
  const _RoleTabBar({required this.controller});

  static const _red = Color(0xFFE31837);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller.registerTabController,
        indicator: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🥊', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text('FIGHTER'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🛡️', style: TextStyle(fontSize: 16)),
                SizedBox(width: 8),
                Text('REFEREE'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role-specific field panels
// ─────────────────────────────────────────────────────────────────────────────

class _FighterFields extends StatelessWidget {
  final AuthController controller;
  const _FighterFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('FIGHTER DETAILS'),
          const SizedBox(height: 16),
          _Field(
            controller: controller.categoryController,
            label: 'WEIGHT CATEGORY',
            hint: 'e.g. Lightweight, Welterweight',
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          _Field(
            controller: controller.weightController,
            label: 'WEIGHT (kg)',
            hint: 'e.g. 77.5',
            icon: Icons.monitor_weight_outlined,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}

class _RefereeFields extends StatelessWidget {
  final AuthController controller;
  const _RefereeFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('REFEREE DETAILS'),
          const SizedBox(height: 16),
          _Field(
            controller: controller.licenseNumberController,
            label: 'LICENSE NUMBER',
            hint: 'Optional',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),
          _Field(
            controller: controller.gradeController,
            label: 'GRADE / CERTIFICATION',
            hint: 'Optional',
            icon: Icons.grade_outlined,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Country Dropdown with API integration (following the same pattern)
// ─────────────────────────────────────────────────────────────────────────────

class _CountryDropdown extends StatelessWidget {
  final AuthController controller;
  final RegistrationController regController;
  const _CountryDropdown({required this.controller, required this.regController});

  static const _red = Color(0xFFE31837);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state
      if (regController.isLoadingCountries.value && regController.countries.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: _red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COUNTRY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Loading countries...',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      // Show error state
      if (regController.hasCountriesError.value) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load countries',
                      style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => regController.refreshCountries(),
                    child: const Text('Retry', style: TextStyle(color: _red)),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      // Show empty state
      if (regController.countries.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.flag_outlined, color: _red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COUNTRY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No countries available',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: _red),
                onPressed: () => regController.refreshCountries(),
              ),
            ],
          ),
        );
      }

      // Show dropdown with countries from API
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Country>(
            isExpanded: true,
            value: regController.selectedCountry.value,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined, color: _red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'COUNTRY',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your country',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            items: regController.countries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Country Flag
                      if (country.flagUrl != null && 
                          country.flagUrl!.isNotEmpty && 
                          country.flagUrl != 'string')
                        _buildFlagImage(country.flagUrl!),
                      if (country.flagUrl != null && 
                          country.flagUrl!.isNotEmpty && 
                          country.flagUrl != 'string')
                        const SizedBox(width: 12),
                      
                      // Country Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              'Code: ${country.code}',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      
                      // Selected indicator
                      if (regController.selectedCountry.value?.id == country.id)
                        const Icon(Icons.check_circle, color: _red, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (Country? country) {
              if (country != null) {
                regController.setSelectedCountry(country);
                controller.selectedCountryId.value = country.id; // Store UUID in auth controller
                print('Selected country: ${country.name} (ID: ${country.id})');
              }
            },
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
          ),
        ),
      );
    });
  }

  Widget _buildFlagImage(String flagUrl) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagUrl,
          width: 40,
          height: 30,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade800,
              child: const Icon(
                Icons.flag,
                size: 20,
                color: Colors.white54,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI helpers
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
          border:
              Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10)),
          ],
        ),
        child: child,
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 3, height: 16, color: const Color(0xFFE31837)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 13),
          ),
        ],
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  static const _red = Color(0xFFE31837);

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1),
          hintText: hint,
          hintStyle:
              TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: _red, size: 20),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _red, width: 2),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('VS',
                style: TextStyle(
                    color: const Color(0xFFE31837),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2)),
          ),
          Expanded(
              child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1))),
        ],
      );
}