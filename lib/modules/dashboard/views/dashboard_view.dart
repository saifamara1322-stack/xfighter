import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/routes/app_router.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/modules/dashboard/controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'XFIGHTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: user.role.color.withOpacity(0.2),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: TextStyle(color: user.role.color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            );
          }),
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
        if (controller.isLoading.value || controller.currentUser.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE31837)),
          );
        }
        if (controller.tabPages.isEmpty) {
          return const Center(
            child: Text(
              'No tabs available for this role',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return IndexedStack(
          index: controller.currentTabIndex.value,
          children: controller.tabPages,
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.bottomNavItems.length <= 1) return const SizedBox.shrink();
        return BottomNavigationBar(
          backgroundColor: const Color(0xFF0D0D1A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE31837),
          unselectedItemColor: Colors.white54,
          currentIndex: controller.currentTabIndex.value,
          onTap: controller.changeTab,
          items: controller.bottomNavItems,
          elevation: 8,
        );
      }),
    );
  }

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
                  user?.fullName ?? 'Loading...',
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
                _drawerItem(Icons.dashboard, 'DASHBOARD', () => Get.back()),
                _drawerItem(Icons.person, 'MY PROFILE', () {
                  Get.back();
                  _navigateToProfile(controller);
                }),
                const Divider(color: Colors.white24, height: 1),
                Obx(() {
                  if (controller.isFighter()) return _buildFighterMenu();
                  if (controller.isCoach()) return _buildCoachMenu();
                  if (controller.isClub()) return _buildClubMenu();
                  if (controller.isOrganizer()) return _buildOrganizerMenu();
                  if (controller.isReferee()) return _buildRefereeMenu();
                  if (controller.isAdmin()) return _buildAdminMenu();
                  return const SizedBox();
                }),
                const Divider(color: Colors.white24, height: 1),
                _drawerItem(Icons.logout, 'LOGOUT', () {
                  Get.back();
                  controller.showLogoutDialog();
                }, isRed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFighterMenu() => Column(children: [
        _drawerItem(Icons.fitness_center, 'MY RECORD', () {
          Get.back(); Get.toNamed(AppRouter.fighterRecord);
        }),
        _drawerItem(Icons.emoji_events, 'TOURNAMENTS', () {
          Get.back(); Get.toNamed(AppRouter.tournaments);
        }),
        _drawerItem(Icons.assignment_turned_in, 'MY REGISTRATIONS', () {
          Get.back(); Get.toNamed(AppRouter.myRegistrations);
        }),
      ]);

  Widget _buildCoachMenu() => Column(children: [
        _drawerItem(Icons.people, 'MY ATHLETES', () {
          Get.back(); Get.toNamed(AppRouter.coachAthletes);
        }),
        _drawerItem(Icons.emoji_events, 'TOURNAMENTS', () {
          Get.back(); Get.toNamed(AppRouter.tournaments);
        }),
        _drawerItem(Icons.business, 'CLUBS', () {
          Get.back(); Get.toNamed(AppRouter.clubs);
        }),
      ]);

  Widget _buildClubMenu() => Column(children: [
        _drawerItem(Icons.sports_mma, 'MY FIGHTERS', () {
          Get.back(); Get.toNamed(AppRouter.clubFighters);
        }),
        _drawerItem(Icons.sports, 'MY COACHES', () {
          Get.back(); Get.toNamed(AppRouter.clubCoaches);
        }),
        _drawerItem(Icons.emoji_events, 'TOURNAMENTS', () {
          Get.back(); Get.toNamed(AppRouter.tournaments);
        }),
        _drawerItem(Icons.mail, 'INVITATIONS', () {
          Get.back(); Get.toNamed(AppRouter.clubInvitations);
        }),
        _drawerItem(Icons.settings, 'CLUB PROFILE', () {
          Get.back(); Get.toNamed(AppRouter.clubSettings);
        }),
      ]);

  Widget _buildOrganizerMenu() => Column(children: [
        _drawerItem(Icons.emoji_events, 'TOURNAMENTS', () {
          Get.back(); Get.toNamed(AppRouter.tournamentManagement);
        }),
        _drawerItem(Icons.people, 'REGISTRATIONS', () {
          Get.back(); Get.toNamed(AppRouter.organizerRegistrations);
        }),
        _drawerItem(Icons.business, 'CLUBS', () {
          Get.back(); Get.toNamed(AppRouter.clubs);
        }),
        _drawerItem(Icons.manage_accounts, 'MY PROFILE', () {
          Get.back(); Get.toNamed(AppRouter.organizerProfile);
        }),
      ]);

  Widget _buildRefereeMenu() => Column(children: [
        _drawerItem(Icons.sports_mma, 'UPCOMING FIGHTS', () {
          Get.back(); Get.toNamed(AppRouter.refereeUpcoming);
        }),
        _drawerItem(Icons.assignment, 'SCORECARDS', () {
          Get.back(); Get.toNamed(AppRouter.refereeScorecards);
        }),
        _drawerItem(Icons.history, 'MATCH HISTORY', () {
          Get.back(); Get.toNamed(AppRouter.refereeHistory);
        }),
      ]);

  Widget _buildAdminMenu() => Column(children: [
        _drawerItem(Icons.emoji_events, 'TOURNAMENTS', () {
          Get.back(); Get.toNamed(AppRouter.tournamentManagement);
        }),
        _drawerItem(Icons.admin_panel_settings, 'MANAGE ADMINS', () {
          Get.back(); Get.toNamed(AppRouter.adminManagement);
        }),
        _drawerItem(Icons.manage_accounts, 'MANAGE ORGANIZERS', () {
          Get.back(); Get.toNamed(AppRouter.organizerManagement);
        }),
        _drawerItem(Icons.verified_user, 'VERIFICATION', () {
          Get.back(); Get.toNamed(AppRouter.verification);
        }),
        _drawerItem(Icons.business, 'CLUBS', () {
          Get.back(); Get.toNamed(AppRouter.clubs);
        }),
        _drawerItem(Icons.sports, 'SPORTS', () {
          Get.back(); Get.toNamed(AppRouter.sports);
        }),
        _drawerItem(Icons.category, 'CATEGORIES', () {
          Get.back(); Get.toNamed(AppRouter.categories);
        }),
        _drawerItem(Icons.people, 'ALL USERS', () {
          Get.back(); Get.toNamed(AppRouter.users);
        }),
        _drawerItem(Icons.analytics, 'STATISTICS', () {
          Get.back(); Get.toNamed(AppRouter.statistics);
        }),
      ]);

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap,
      {bool isRed = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isRed ? const Color(0xFFE31837) : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
            color: isRed ? const Color(0xFFE31837) : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13),
      ),
      onTap: onTap,
    );
  }

  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.FIGHTER:
        return Icons.sports_mma;
      case UserRole.COACH:
        return Icons.sports;
      case UserRole.CLUB:
        return Icons.business;
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
    } else if (controller.isClub()) {
      Get.toNamed(AppRouter.clubSettings);
    } else if (controller.isOrganizer()) {
      Get.toNamed(AppRouter.organizerProfile);
    } else if (controller.isReferee()) {
      Get.toNamed(AppRouter.refereeProfile);
    } else if (controller.isAdmin()) {
      Get.toNamed(AppRouter.adminProfile);
    }
  }
}
