import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/app/views/fighter/fighter_profile_view.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class DashboardView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  
  DashboardView({super.key});
  
  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _showLogoutDialog(),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Obx(() {
        final user = authController.currentUser.value;
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
  
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                    user?.roleIcon ?? Icons.person,
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
                    if (authController.isFighter()) {
                      Get.to(() => FighterProfileView());
                    } else if (authController.isCoach()) {
                      Get.toNamed('/coach-profile');
                    }
                  },
                ),
                const Divider(color: Colors.white24, height: 1),
                
                Obx(() {
                  if (authController.isFighter()) {
                    return Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.fitness_center,
                          label: 'MY RECORD',
                          onTap: () {
                            Get.back();
                            Get.to(() => FighterProfileView());
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
                      ],
                    );
                  } else if (authController.isCoach()) {
                    return Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.people,
                          label: 'MY ATHLETES',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/coach-profile');
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
                      ],
                    );
                  } else if (authController.isOrganizer()) {
                    return Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.event,
                          label: 'CREATE EVENT',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/create-event');
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.event_available,
                          label: 'MANAGE EVENTS',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/manage-events');
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
                          icon: Icons.event_note,
                          label: 'MY EVENTS',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/events');
                          },
                        ),
                      ],
                    );
                  } else if (authController.isAdmin()) {
                    return Column(
                      children: [
                        _buildDrawerItem(
                          icon: Icons.admin_panel_settings,
                          label: 'ADMIN PANEL',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/users');
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.people,
                          label: 'USER MANAGEMENT',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/users');
                          },
                        ),
                        _buildDrawerItem(
                          icon: Icons.verified_user,
                          label: 'COACH MANAGEMENT',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/coach-management');
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
                        _buildDrawerItem(
                          icon: Icons.admin_panel_settings,
                          label: 'EVENT MANAGEMENT',
                          onTap: () {
                            Get.back();
                            Get.toNamed('/admin-events');
                          },
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }),
                
                const Divider(color: Colors.white24, height: 1),
                
                _buildDrawerItem(
                  icon: Icons.settings,
                  label: 'SETTINGS',
                  onTap: () {
                    Get.back();
                    // Navigate to settings
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout,
                  label: 'LOGOUT',
                  onTap: () {
                    Get.back();
                    _showLogoutDialog();
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
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isRed ? const Color(0xFFE31837) : Colors.white70,
        ),
      ),
      onTap: onTap,
      hoverColor: const Color(0xFFE31837).withOpacity(0.1),
    );
  }
  
  Widget _buildDashboardContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card - FighterRec Style
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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE31837).withOpacity(0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            user.roleIcon,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WELCOME BACK,',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.firstName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(
                          label: 'ROLE',
                          value: user.roleDisplay,
                          color: const Color(0xFFE31837),
                        ),
                        _buildInfoChip(
                          label: 'STATUS',
                          value: user.statusDisplay,
                          color: user.statusColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Actions based on role - FighterRec Style
          _buildQuickActions(user.role),
          
          const SizedBox(height: 20),
          
          // Upcoming Events/Notifications
          _buildUpcomingEvents(),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions(UserRole role) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _getActionsForRole(role),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _getActionsForRole(UserRole role) {
    final actions = <Widget>[];
    
    switch (role) {
      case UserRole.fighter:
        actions.add(_buildActionButton(
          icon: Icons.event,
          label: 'FIND EVENTS',
          onTap: () => Get.toNamed('/events'),
        ));
        actions.add(_buildActionButton(
          icon: Icons.fitness_center,
          label: 'MY STATS',
          onTap: () => Get.toNamed('/fighter-stats'),
        ));
        break;
        
      case UserRole.coach:
        actions.add(_buildActionButton(
          icon: Icons.person_add,
          label: 'ADD FIGHTER',
          onTap: () => Get.toNamed('/add-fighter'),
        ));
        actions.add(_buildActionButton(
          icon: Icons.people,
          label: 'MANAGE TEAM',
          onTap: () => Get.toNamed('/team'),
        ));
        break;
        
      case UserRole.organizer:
        actions.add(_buildActionButton(
          icon: Icons.event,
          label: 'CREATE EVENT',
          onTap: () => Get.toNamed('/create-event'),
        ));
        actions.add(_buildActionButton(
          icon: Icons.event_available,
          label: 'MANAGE EVENTS',
          onTap: () => Get.toNamed('/manage-events'),
        ));
        break;
        
      case UserRole.referee:
        actions.add(_buildActionButton(
          icon: Icons.gavel,
          label: 'UPCOMING FIGHTS',
          onTap: () => Get.toNamed('/upcoming-fights'),
        ));
        break;
        
      case UserRole.admin:
        actions.add(_buildActionButton(
          icon: Icons.admin_panel_settings,
          label: 'ADMIN PANEL',
          onTap: () => Get.toNamed('/users'),
        ));
        actions.add(_buildActionButton(
          icon: Icons.people,
          label: 'USER MGMT',
          onTap: () => Get.toNamed('/users'),
        ));
        break;
    }
    
    return actions;
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE31837),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: const Color(0xFFE31837).withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpcomingEvents() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'UPCOMING EVENTS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventItem(
              title: 'UFW TUNISIA CHAMPIONSHIP 2024',
              subtitle: 'March 15, 2024 • Radès, Tunis',
              icon: Icons.sports_mma,
            ),
            const SizedBox(height: 12),
            _buildEventItem(
              title: 'FIGHT NIGHT: RISING STARS',
              subtitle: 'March 22, 2024 • Sousse',
              icon: Icons.sports_mma,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFE31837),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFE31837).withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE31837).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: 48,
                  color: Color(0xFFE31837),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('LOGOUT'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}