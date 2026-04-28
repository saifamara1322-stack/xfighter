import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            );
          }),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard,
                  label: 'DASHBOARD',
                  onTap: () => Get.back(),
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  label: 'MY PROFILE',
                  onTap: () {
                    Get.back();
                    _navigateToProfile(controller);
                  },
                ),
                const Divider(color: Colors.white24, height: 1),
                
                Obx(() {
                  if (controller.isFighter()) {
                    return _buildFighterMenu();
                  } else if (controller.isCoach()) {
                    return _buildCoachMenu();
                  } else if (controller.isOrganizer()) {
                    return _buildOrganizerMenu();
                  } else if (controller.isAdmin()) {
                    return _buildAdminMenu();
                  }
                  return const SizedBox();
                }),
                
                const Divider(color: Colors.white24, height: 1),
                
                _buildDrawerItem(
                  icon: Icons.settings,
                  label: 'SETTINGS',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/settings');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  label: 'LOGOUT',
                  onTap: () {
                    Get.back();
                    controller.showLogoutDialog();
                  },
                  isRed: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFighterMenu() {
    return Column(
      children: [
        _buildDrawerItem(
          icon: Icons.fitness_center,
          label: 'MY RECORD',
          onTap: () {
            Get.back();
            Get.toNamed('/fighter-profile');
          },
        ),
        _buildDrawerItem(
          icon: Icons.event,
          label: 'UPCOMING FIGHTS',
          onTap: () {
            Get.back();
            Get.toNamed('/events');
          },
        ),
        _buildDrawerItem(
          icon: Icons.event_note,
          label: 'EVENTS',
          onTap: () {
            Get.back();
            Get.toNamed('/events');
          },
        ),
        _buildDrawerItem(
          icon: Icons.assignment_turned_in,
          label: 'MY REGISTRATIONS',
          onTap: () {
            Get.back();
            Get.toNamed('/my-registrations');
          },
        ),
      ],
    );
  }
  
  Widget _buildCoachMenu() {
    return Column(
      children: [
        _buildDrawerItem(
          icon: Icons.people,
          label: 'MY ATHLETES',
          onTap: () {
            Get.back();
            Get.toNamed('/coach-athletes');
          },
        ),
        _buildDrawerItem(
          icon: Icons.school,
          label: 'COACH PROFILE',
          onTap: () {
            Get.back();
            Get.toNamed('/coach-profile');
          },
        ),
        _buildDrawerItem(
          icon: Icons.business,
          label: 'MANAGE GYMS',
          onTap: () {
            Get.back();
            Get.toNamed('/gyms');
          },
        ),
        _buildDrawerItem(
          icon: Icons.assignment_turned_in,
          label: 'PENDING REGISTRATIONS',
          onTap: () {
            Get.back();
            Get.toNamed('/pending-registrations');
          },
        ),
      ],
    );
  }
  
  Widget _buildOrganizerMenu() {
    return Column(
      children: [
        _buildDrawerItem(
          icon: Icons.event,
          label: 'MANAGE EVENTS',
          onTap: () {
            Get.back();
            Get.toNamed('/admin-events');
          },
        ),
        _buildDrawerItem(
          icon: Icons.people,
          label: 'FIGHTER REGISTRATIONS',
          onTap: () {
            Get.back();
            Get.toNamed('/fighter-registrations');
          },
        ),
        _buildDrawerItem(
          icon: Icons.business,
          label: 'MANAGE GYMS',
          onTap: () {
            Get.back();
            Get.toNamed('/gyms');
          },
        ),
        _buildDrawerItem(
          icon: Icons.assignment_turned_in,
          label: 'FIGHT CARDS',
          onTap: () {
            Get.back();
            Get.toNamed('/fight-cards');
          },
        ),
      ],
    );
  }
  
  Widget _buildAdminMenu() {
    return Column(
      children: [
        _buildDrawerItem(
          icon: Icons.people,
          label: 'ALL USERS',
          onTap: () {
            Get.back();
            Get.toNamed('/users');
          },
        ),
        _buildDrawerItem(
          icon: Icons.event,
          label: 'MANAGE EVENTS',
          onTap: () {
            Get.back();
            Get.toNamed('/admin-events');
          },
        ),
        _buildDrawerItem(
          icon: Icons.business,
          label: 'MANAGE GYMS',
          onTap: () {
            Get.back();
            Get.toNamed('/gyms');
          },
        ),
        _buildDrawerItem(
          icon: Icons.analytics,
          label: 'STATISTICS',
          onTap: () {
            Get.back();
            Get.toNamed('/statistics');
          },
        ),
      ],
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isRed ? const Color(0xFFE31837) : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isRed ? const Color(0xFFE31837) : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
  
  Widget _buildDashboardContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
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
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.roleDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                icon: Icons.event,
                label: 'Events',
                onTap: () => Get.toNamed('/events'),
              ),
              _buildQuickActionCard(
                icon: Icons.business,
                label: 'Gyms',
                onTap: () => Get.toNamed('/gyms'),
              ),
              _buildQuickActionCard(
                icon: Icons.people,
                label: 'Users',
                onTap: () => Get.toNamed('/users'),
              ),
              _buildQuickActionCard(
                icon: Icons.sports_mma,
                label: 'Fighters',
                onTap: () => Get.toNamed('/fighters'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFE31837),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.fighter:
        return Icons.sports_mma;
      case UserRole.coach:
        return Icons.sports;
      case UserRole.organizer:
        return Icons.event;
      case UserRole.referee:
        return Icons.gavel;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
  
  void _navigateToProfile(DashboardController controller) {
    if (controller.isFighter()) {
      Get.toNamed('/fighter-profile');
    } else if (controller.isCoach()) {
      Get.toNamed('/coach-profile');
    } else if (controller.isOrganizer()) {
      Get.toNamed('/organizer-profile');
    } else if (controller.isAdmin()) {
      Get.toNamed('/admin-profile');
    }
  }
}