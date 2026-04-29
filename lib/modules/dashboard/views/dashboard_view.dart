import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/routes/app_router.dart';
import 'package:xfighter/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:xfighter/data/models/user_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'XFIGHTER DASHBOARD',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFE31837)),
              onPressed: controller.showLogoutDialog,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(controller),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return const Center(
            child: Text(
              'No user data found',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return _buildDashboardContent(user);
      }),
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────────

  Widget _buildDrawer(DashboardController controller) {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          Obx(() {
            final user = controller.currentUser.value;
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                ),
              ),
              child: UserAccountsDrawerHeader(
                currentAccountPicture: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(
                    _getRoleIcon(user?.role),
                    size: 40,
                    color: const Color(0xFFE31837),
                  ),
                ),
                accountName: Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            );
          }),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _item(Icons.dashboard, 'DASHBOARD', () => Get.back()),
                _item(Icons.person, 'MY PROFILE', () {
                  Get.back();
                  _navigateToProfile(Get.find<DashboardController>());
                }),
                const Divider(color: Colors.white24, height: 1),
                Obx(() {
                  final c = Get.find<DashboardController>();
                  if (c.isFighter()) return _buildFighterMenu();
                  if (c.isCoach()) return _buildCoachMenu();
                  if (c.isOrganizer()) return _buildOrganizerMenu();
                  if (c.isAdmin()) return _buildAdminMenu();
                  return const SizedBox();
                }),
                const Divider(color: Colors.white24, height: 1),
                _item(Icons.settings, 'SETTINGS',
                    () { Get.back(); Get.toNamed(AppRouter.settings); }),
                _item(Icons.logout, 'LOGOUT', () {
                  Get.back();
                  Get.find<DashboardController>().showLogoutDialog();
                }, isRed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Role menus ──────────────────────────────────────────────────────────────

  Widget _buildFighterMenu() => Column(children: [
        _item(Icons.fitness_center, 'MY RECORD',
            () { Get.back(); Get.toNamed(AppRouter.fighterProfile); }),
        _item(Icons.event, 'EVENTS',
            () { Get.back(); Get.toNamed(AppRouter.events); }),
        _item(Icons.assignment_turned_in, 'MY REGISTRATIONS',
            () { Get.back(); Get.toNamed(AppRouter.myRegistrations); }),
      ]);

  Widget _buildCoachMenu() => Column(children: [
        _item(Icons.people, 'MY ATHLETES',
            () { Get.back(); Get.toNamed(AppRouter.coachAthletes); }),
        _item(Icons.school, 'COACH PROFILE',
            () { Get.back(); Get.toNamed(AppRouter.coachProfile); }),
        _item(Icons.business, 'MANAGE GYMS',
            () { Get.back(); Get.toNamed(AppRouter.gyms); }),
        _item(Icons.assignment_turned_in, 'PENDING REGISTRATIONS',
            () { Get.back(); Get.toNamed(AppRouter.pendingRegistrations); }),
      ]);

  Widget _buildOrganizerMenu() => Column(children: [
        _item(Icons.event, 'MANAGE EVENTS',
            () { Get.back(); Get.toNamed(AppRouter.adminEvents); }),
        _item(Icons.people, 'FIGHTER REGISTRATIONS',
            () { Get.back(); Get.toNamed(AppRouter.fighterRegistrations); }),
        _item(Icons.business, 'MANAGE GYMS',
            () { Get.back(); Get.toNamed(AppRouter.gyms); }),
        _item(Icons.assignment_turned_in, 'FIGHT CARDS',
            () { Get.back(); Get.toNamed(AppRouter.fightCards); }),
      ]);

  Widget _buildAdminMenu() => Column(children: [
        _item(Icons.people, 'ALL USERS',
            () { Get.back(); Get.toNamed(AppRouter.users); }),
        _item(Icons.event, 'MANAGE EVENTS',
            () { Get.back(); Get.toNamed(AppRouter.adminEvents); }),
        _item(Icons.business, 'MANAGE GYMS',
            () { Get.back(); Get.toNamed(AppRouter.gyms); }),
        _item(Icons.analytics, 'STATISTICS',
            () { Get.back(); Get.toNamed(AppRouter.statistics); }),
      ]);

  // ── Dashboard content ───────────────────────────────────────────────────────

  Widget _buildDashboardContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE31837), Color(0xFFB8102E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: TextStyle(
                        color: Colors.white.withAlpha(204), fontSize: 14)),
                const SizedBox(height: 4),
                Text(user.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('QUICK ACTIONS',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _quickAction(Icons.event, 'Events',
                  () => Get.toNamed(AppRouter.events)),
              _quickAction(Icons.business, 'Gyms',
                  () => Get.toNamed(AppRouter.gyms)),
              _quickAction(Icons.people, 'Users',
                  () => Get.toNamed(AppRouter.users)),
              _quickAction(Icons.sports_mma, 'Fighters',
                  () => Get.toNamed(AppRouter.fighters)),
            ],
          ),

          const SizedBox(height: 24),
          const Text('RECENT ACTIVITY',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: const Center(
              child: Text('No recent activity',
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _item(IconData icon, String label, VoidCallback onTap,
      {bool isRed = false}) {
    return ListTile(
      leading:
          Icon(icon, color: isRed ? const Color(0xFFE31837) : Colors.white70),
      title: Text(label,
          style: TextStyle(
              color: isRed ? const Color(0xFFE31837) : Colors.white,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE31837), size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.FIGHTER:
        return Icons.sports_mma;
      case UserRole.COACH:
        return Icons.sports;
      case UserRole.ORGANIZER:
        return Icons.event;
      case UserRole.REFEREE:
        return Icons.gavel;
      case UserRole.ADMIN:
      case UserRole.SUPER_ADMIN:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  void _navigateToProfile(DashboardController controller) {
    if (controller.isFighter()) {
      Get.toNamed(AppRouter.fighterProfile);
    } else if (controller.isCoach()) {
      Get.toNamed(AppRouter.coachProfile);
    } else if (controller.isOrganizer()) {
      Get.toNamed(AppRouter.organizerProfile);
    } else if (controller.isAdmin()) {
      Get.toNamed(AppRouter.adminProfile);
    }
  }
}