import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/auth_repository.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/repositories/tournament_repository.dart';
import 'package:xfighter/data/repositories/admin_repository.dart';
import 'package:xfighter/data/repositories/verification_repository.dart';
import 'package:xfighter/modules/profile/views/shared_profile_view.dart';
import 'package:xfighter/modules/event/views/event_list_view.dart';
import 'package:xfighter/modules/registration/views/organizer_registrations_view.dart';
import 'package:xfighter/modules/fighter/views/fighter_record_view.dart';
import 'package:xfighter/modules/coach/views/coach_athletes_view.dart';
import 'package:xfighter/modules/gym/views/club_athletes_view.dart';
import 'package:xfighter/modules/profile/views/documents_view.dart';

class DashboardController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TournamentRepository _tournamentRepo = TournamentRepository();
  final AdminRepository _adminRepo = AdminRepository();
  final VerificationRepository _verificationRepo = VerificationRepository();

  var currentUser = Rx<User?>(null);
  var isLoading = false.obs;

  // Dashboard stat counters (admin/organizer view)
  var totalTournaments = 0.obs;
  var pendingVerifications = 0.obs;
  var totalAdmins = 0.obs;

  // Tab navigation
  final RxInt currentTabIndex = 0.obs;
  final RxList<BottomNavigationBarItem> bottomNavItems =
      <BottomNavigationBarItem>[].obs;
  final RxList<Widget> tabPages = <Widget>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    isLoading.value = true;
    try {
      // Try to get from AuthController first (already loaded on login)
      final authController = Get.find<AuthController>();
      if (authController.currentUser.value != null) {
        currentUser.value = authController.currentUser.value;
        _updateBottomNavigationForRole();
        _loadStats();
        // Listen for future changes
        authController.currentUser.listen((user) {
          if (user != null && currentUser.value?.id != user.id) {
            currentUser.value = user;
            _updateBottomNavigationForRole();
            _loadStats();
          }
        });
        return;
      }

      final user = await _authRepository.getCurrentUser();
      currentUser.value = user;
      if (user != null) {
        _updateBottomNavigationForRole();
        _loadStats();
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      // Try cached user
      currentUser.value = await _authRepository.getCachedUser();
      if (currentUser.value != null) {
        _updateBottomNavigationForRole();
      } else {
        Get.offAllNamed('/login');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _updateBottomNavigationForRole() {
    final user = currentUser.value;
    if (user == null) return;

    final role = user.role;
    final List<BottomNavigationBarItem> items = [];
    final List<Widget> pages = [];

    // Common home tab
    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ));
    pages.add(HomeTab(role: role));

    switch (role) {
      case UserRole.FIGHTER:
        items.addAll([
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Tournaments'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Documents'),
        ]);
        pages.addAll([
          const FighterRecordView(),
          EventListView(),
          const DocumentsView(),
        ]);
        break;

      case UserRole.COACH:
        items.addAll([
          const BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Athletes'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Tournaments'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Documents'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ]);
        pages.addAll([
          const CoachAthletesView(),
          EventListView(),
          const DocumentsView(),
          SharedProfileView(),
        ]);
        break;

      case UserRole.CLUB:
        items.addAll([
          const BottomNavigationBarItem(
              icon: Icon(Icons.groups), label: 'Athletes'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Club'),
        ]);
        pages.addAll([
          const ClubAthletesView(),
          SharedProfileView(),
        ]);
        break;

      case UserRole.ORGANIZER:
        items.addAll([
          const BottomNavigationBarItem(
              icon: Icon(Icons.event_available), label: 'Tournaments'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.app_registration), label: 'Registrations'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ]);
        pages.addAll([
          EventListView(),
          OrganizerRegistrationsView(),
          SharedProfileView(),
        ]);
        break;

      case UserRole.REFEREE:
        items.addAll([
          const BottomNavigationBarItem(
              icon: Icon(Icons.event), label: 'Tournaments'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.description), label: 'Documents'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ]);
        pages.addAll([
          EventListView(),
          const DocumentsView(),
          SharedProfileView(),
        ]);
        break;

      case UserRole.ADMIN:
      case UserRole.SUPER_ADMIN:
      default:
        // Admin uses drawer navigation, no bottom nav extra tabs needed
        break;
    }

    bottomNavItems.assignAll(items);
    tabPages.assignAll(pages);
    currentTabIndex.value = 0;
  }

  void _loadStats() {
    final role = currentUser.value?.role;
    if (role == UserRole.ADMIN || role == UserRole.SUPER_ADMIN || role == UserRole.ORGANIZER) {
      _fetchStats();
    }
  }

  Future<void> _fetchStats() async {
    try {
      final tournamentsFuture = _tournamentRepo.getTournaments(page: 0, size: 1);
      tournamentsFuture.then((p) => totalTournaments.value = p.totalElements).catchError((_) {});
    } catch (_) {}

    try {
      if (currentUser.value?.role == UserRole.SUPER_ADMIN) {
        final adminsFuture = _adminRepo.getAllAdmins(page: 0, size: 1);
        adminsFuture.then((p) => totalAdmins.value = p.totalElements).catchError((_) {});
      }
    } catch (_) {}

    try {
      final pendingFuture = _verificationRepo.getPendingUsers(page: 0, size: 1);
      pendingFuture.then((p) => pendingVerifications.value = p.totalElements).catchError((_) {});
    } catch (_) {}
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  bool isFighter() => currentUser.value?.role == UserRole.FIGHTER;
  bool isCoach() => currentUser.value?.role == UserRole.COACH;
  bool isClub() => currentUser.value?.role == UserRole.CLUB;
  bool isOrganizer() => currentUser.value?.role == UserRole.ORGANIZER;
  bool isReferee() => currentUser.value?.role == UserRole.REFEREE;
  bool isAdmin() =>
      currentUser.value?.role == UserRole.ADMIN ||
      currentUser.value?.role == UserRole.SUPER_ADMIN;

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('LOGOUT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Get.find<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            child: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ======================== HOME TAB (ROLE-SPECIFIC QUICK ACTIONS) ========================

class HomeTab extends StatelessWidget {
  final UserRole role;
  const HomeTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE31837), Color(0xFFB8102E)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                        color: Colors.white.withAlpha(204), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
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
            );
          }),
          const SizedBox(height: 16),

          // Stats row (admin/organizer only)
          Obx(() {
            if (!controller.isAdmin() && !controller.isOrganizer()) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OVERVIEW',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _statCard('Tournaments',
                            controller.totalTournaments.value, Icons.emoji_events,
                            const Color(0xFFE31837))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _statCard(
                            'Pending',
                            controller.pendingVerifications.value,
                            Icons.pending_actions,
                            Colors.orange)),
                    if (controller.currentUser.value?.role ==
                        UserRole.SUPER_ADMIN) ...[
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard('Admins', controller.totalAdmins.value,
                              Icons.admin_panel_settings, Colors.blue)),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          const Text('QUICK ACTIONS',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(role),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(UserRole role) {
    List<Map<String, dynamic>> actions = [];

    switch (role) {
      case UserRole.FIGHTER:
        actions = [
          {'icon': Icons.person, 'label': 'My Profile', 'route': '/fighter-record'},
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/events'},
          {'icon': Icons.assignment_turned_in, 'label': 'My Registrations', 'route': '/my-registrations'},
          {'icon': Icons.description, 'label': 'Documents', 'route': '/documents/me'},
        ];
        break;
      case UserRole.COACH:
        actions = [
          {'icon': Icons.people, 'label': 'My Athletes', 'route': '/coach-athletes'},
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/events'},
          {'icon': Icons.business, 'label': 'My Clubs', 'route': '/gyms'},
          {'icon': Icons.description, 'label': 'Documents', 'route': '/documents/me'},
        ];
        break;
      case UserRole.CLUB:
        actions = [
          {'icon': Icons.sports_mma, 'label': 'Fighters', 'route': '/club-fighters'},
          {'icon': Icons.sports, 'label': 'Coaches', 'route': '/club-coaches'},
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/events'},
          {'icon': Icons.how_to_reg, 'label': 'Register Fighter', 'route': '/events'},
          {'icon': Icons.mail, 'label': 'Invitations', 'route': '/club-invitations'},
          {'icon': Icons.settings, 'label': 'Club Profile', 'route': '/club-settings'},
        ];
        break;
      case UserRole.ORGANIZER:
        actions = [
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/admin-events'},
          {'icon': Icons.people, 'label': 'Registrations', 'route': '/organizer-registrations'},
          {'icon': Icons.business, 'label': 'Clubs', 'route': '/gyms'},
          {'icon': Icons.manage_accounts, 'label': 'Profile', 'route': '/organizer-profile'},
        ];
        break;
      case UserRole.REFEREE:
        actions = [
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/events'},
          {'icon': Icons.description, 'label': 'Documents', 'route': '/documents/me'},
          {'icon': Icons.person, 'label': 'Profile', 'route': '/referee-profile'},
        ];
        break;
      case UserRole.ADMIN:
      case UserRole.SUPER_ADMIN:
      default:
        actions = [
          {'icon': Icons.emoji_events, 'label': 'Tournaments', 'route': '/admin-events'},
          {'icon': Icons.admin_panel_settings, 'label': 'Admins', 'route': '/admin-management'},
          {'icon': Icons.manage_accounts, 'label': 'Organizers', 'route': '/organizer-management'},
          {'icon': Icons.verified_user, 'label': 'Verification', 'route': '/verification'},
          {'icon': Icons.business, 'label': 'Clubs', 'route': '/gyms'},
          {'icon': Icons.sports, 'label': 'Sports', 'route': '/sports'},
          {'icon': Icons.category, 'label': 'Categories', 'route': '/categories'},
          {'icon': Icons.flag, 'label': 'Countries', 'route': '/countries'},
          {'icon': Icons.people, 'label': 'All Users', 'route': '/users'},
          {'icon': Icons.analytics, 'label': 'Statistics', 'route': '/statistics'},
        ];
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: actions.map((action) {
        return _quickAction(action['icon'] as IconData,
            action['label'] as String, () {
          Get.toNamed(action['route'] as String);
        });
      }).toList(),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE31837), size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== PLACEHOLDER TABS ========================

class FighterEventsTab extends StatelessWidget {
  const FighterEventsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Upcoming Tournaments',
          style: TextStyle(color: Colors.white54)));
}

class CoachEventsTab extends StatelessWidget {
  const CoachEventsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Events', style: TextStyle(color: Colors.white54)));
}

class CoachProfileTab extends StatelessWidget {
  const CoachProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Coach Profile', style: TextStyle(color: Colors.white54)));
}

// Club tabs
class ClubFightersTab extends StatelessWidget {
  const ClubFightersTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Club Fighters', style: TextStyle(color: Colors.white54)));
}

class ClubCoachesTab extends StatelessWidget {
  const ClubCoachesTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Club Coaches', style: TextStyle(color: Colors.white54)));
}

class ClubSettingsTab extends StatelessWidget {
  const ClubSettingsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Club Settings', style: TextStyle(color: Colors.white54)));
}

// Organizer tabs
class OrganizerEventsTab extends StatelessWidget {
  const OrganizerEventsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Manage Tournaments',
          style: TextStyle(color: Colors.white54)));
}

class OrganizerRegistrationsTab extends StatelessWidget {
  const OrganizerRegistrationsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Fighter Registrations',
          style: TextStyle(color: Colors.white54)));
}

class OrganizerProfileTab extends StatelessWidget {
  const OrganizerProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Organizer Profile', style: TextStyle(color: Colors.white54)));
}

// Referee tabs (dummy data as per user request)
class RefereeUpcomingTab extends StatelessWidget {
  const RefereeUpcomingTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _fightCard('Ali Hassan', 'Karim Benali', 'MMA - 77kg', 'June 20, 2026', 'Arena X'),
        _fightCard('Samir Trabelsi', 'Yassine Mejri', 'Kickboxing - 65kg', 'June 22, 2026', 'Stadium Y'),
      ],
    );
  }

  Widget _fightCard(String f1, String f2, String division, String date, String venue) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(f1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('VS', style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold)),
                Text(f2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(division, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.calendar_today, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(venue, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }
}

class RefereeScorecardsTab extends StatelessWidget {
  const RefereeScorecardsTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Scorecards — coming soon',
          style: TextStyle(color: Colors.white54)));
}

class RefereeProfileTab extends StatelessWidget {
  const RefereeProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
      child: Text('Referee Profile', style: TextStyle(color: Colors.white54)));
}