import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/user_model.dart';

// Auth
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/modules/auth/routes/auth_routes.dart';

// Dashboard
import 'package:xfighter/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:xfighter/modules/dashboard/views/dashboard_view.dart';

// Fighter
import 'package:xfighter/modules/fighter/bindings/fighter_binding.dart';
import 'package:xfighter/modules/fighter/views/fighter_record_view.dart';
import 'package:xfighter/modules/fighter/views/fighter_profile_view.dart';

// Club
import 'package:xfighter/modules/gym/views/club_details_view.dart';
import 'package:xfighter/modules/gym/bindings/gym_binding.dart';
import 'package:xfighter/modules/gym/views/gym_list_view.dart';
import 'package:xfighter/modules/gym/views/club_fighters_view.dart';
import 'package:xfighter/modules/gym/views/club_coaches_view.dart';
import 'package:xfighter/modules/gym/views/club_invitations_view.dart';
import 'package:xfighter/modules/gym/views/club_athletes_view.dart';

// Users
import 'package:xfighter/modules/users/bindings/user_binding.dart';
import 'package:xfighter/modules/users/views/user_list_view.dart';

// Tournaments
import 'package:xfighter/modules/event/bindings/event_binding.dart';
import 'package:xfighter/modules/event/views/create_event_view.dart';
import 'package:xfighter/modules/event/views/event_detail_view.dart';
import 'package:xfighter/modules/event/views/event_list_view.dart';

// Profile
import 'package:xfighter/modules/profile/views/shared_profile_view.dart';
import 'package:xfighter/modules/profile/views/documents_view.dart';

// Coach
import 'package:xfighter/modules/coach/bindings/coach_binding.dart';
import 'package:xfighter/modules/coach/views/coach_athletes_view.dart';

// Registrations
import 'package:xfighter/modules/registration/bindings/registration_binding.dart';
import 'package:xfighter/modules/registration/views/coach_registrations_view.dart';
import 'package:xfighter/modules/registration/views/fighter_registrations_view.dart';
import 'package:xfighter/modules/registration/views/organizer_registrations_view.dart';

// Matchmaking removed — no fight-card endpoints in the API.

// Admin
import 'package:xfighter/modules/admin/bindings/admin_binding.dart';
import 'package:xfighter/modules/admin/views/admin_detail_view.dart';
import 'package:xfighter/modules/admin/views/admin_list_view.dart';
import 'package:xfighter/modules/admin/views/sports_view.dart';
import 'package:xfighter/modules/admin/views/categories_view.dart';
import 'package:xfighter/modules/admin/views/countries_view.dart';

// Organizer
import 'package:xfighter/modules/organizer/bindings/organizer_binding.dart';
import 'package:xfighter/modules/organizer/views/organizer_detail_view.dart';
import 'package:xfighter/modules/organizer/views/organizer_list_view.dart';

// Verification
import 'package:xfighter/modules/verification/bindings/verification_binding.dart';
import 'package:xfighter/modules/verification/views/verification_list_view.dart';

// Dashboard stats
import 'package:xfighter/modules/dashboard/views/statistics_view.dart';

// ============================================================================
// Helper: Argument / Parameter extractor (supports Map, String, direct param)
// ============================================================================
String _extractArgument(String key, {String defaultValue = ''}) {
  if (Get.parameters.containsKey(key)) return Get.parameters[key]!;
  final args = Get.arguments;
  if (args is String) return args;
  if (args is Map) {
    final value = args[key];
    if (value != null) return value.toString();
  }
  return defaultValue;
}

// ============================================================================
// Role‑based Route Guard with User Feedback
// ============================================================================
class _RoleRouteGuard extends GetMiddleware {
  _RoleRouteGuard({required this.allowedRoles, this.blockDisabledUsers = true})
    : super(priority: 1);

  final Set<UserRole> allowedRoles;
  final bool blockDisabledUsers;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      _showAccessMessage('Authentication service not ready. Please log in.');
      return const RouteSettings(name: AppRouter.login);
    }

    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (!authController.isLoggedIn.value || user == null) {
      _showAccessMessage('Please log in to continue.');
      return const RouteSettings(name: AppRouter.login);
    }

    if (blockDisabledUsers && user.status == UserStatus.DISABLED) {
      _showAccessMessage('Your account has been disabled. Contact support.');
      return const RouteSettings(name: AppRouter.accessDenied);
    }

    if (allowedRoles.isNotEmpty && !allowedRoles.contains(user.role)) {
      _showAccessMessage('You do not have permission to access this section.');
      return const RouteSettings(name: AppRouter.accessDenied);
    }

    return null;
  }

  void _showAccessMessage(String message) {
    // Use a micro delay to avoid showing snackbar during initial routing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        GetSnackBar(
          message: message,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade900,
          snackPosition: SnackPosition.BOTTOM,
        ).show();
      }
    });
  }
}

// ============================================================================
// Placeholder Pages (for unfinished sections)
// ============================================================================
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(title), elevation: 0),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccessDeniedPage extends StatelessWidget {
  const _AccessDeniedPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Access Denied'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: theme.primaryColor, size: 56),
              const SizedBox(height: 16),
              const Text(
                'You do not have permission to view this page.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRouter.dashboard),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Page Not Found'), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: theme.primaryColor, size: 56),
              const SizedBox(height: 16),
              const Text(
                'The requested page does not exist.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRouter.dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Main Router Definition
// ============================================================================
class AppRouter {
  // Auth
  static const initial = '/';
  static const login = '/login';
  static const register = '/register';

  // Core
  static const dashboard = '/dashboard';
  static const accessDenied = '/access-denied';
  static const notFound = '/404';

  // Profiles
  static const fighterProfile = '/fighter/profile';
  static const coachProfile = '/coach/profile';
  static const organizerProfile = '/organizers/me';
  static const refereeProfile = '/referee/profile';
  static const adminProfile = '/admin/me';
  static const clubSettings = '/club/my-club';

  // Fighter / Coach / Club workflows
  static const fighterRecord = '/fighter/record';
  static const fighters = '/fighters';
  static const coachAthletes = '/coach/athletes';
  static const clubs = '/clubs';
  static const clubDetail = '/clubs/:id'; // now points to ClubDetailView
  static const clubFighters = '/club/fighters';
  static const clubCoaches = '/club/coaches';
  static const clubAthletes = '/club/athletes';
  static const clubInvitations = '/club/invitations';

  // Tournaments
  static const tournaments = '/tournaments';
  static const tournamentManagement = '/tournaments/manage';
  static const tournamentCreate = '/tournaments/create';
  static const tournamentDetail = '/tournaments/:id';
  static const tournamentRegistrations = '/tournaments/:id/registrations';

  // Legacy event routes (redirects or kept for compatibility)
  static const events = '/events';
  static const legacyEventDetail = '/event/:id';
  static const adminEvents = '/admin-events';
  static const legacyCreateEvent = '/create-event';

  // Registrations
  static const myRegistrations = '/registrations/me';
  static const pendingRegistrations = '/registrations/coach/pending';
  static const fighterRegistrations = '/registrations/fighter';
  static const organizerRegistrations = '/registrations/organizer';
  static const coachRegistrations = '/registrations/coach';

  // Master data
  static const sports = '/sports';
  static const categories = '/categories';
  static const countries = '/countries';

  // Users / admin / organizer management
  static const users = '/users';
  static const adminManagement = '/admins';
  static const adminDetail = '/admins/:id';
  static const legacyAdminManagement = '/admin-management';
  static const legacyAdminDetail = '/admin-detail';
  static const organizerManagement = '/organizers';
  static const organizerDetail = '/organizers/:id';
  static const legacyOrganizerManagement = '/organizer-management';
  static const legacyOrganizerDetail = '/organizer-detail';

  // Verification / documents
  static const verification = '/verification/pending';
  static const legacyVerification = '/verification';
  static const documents = '/documents/me';

  // Referee workflows (tournaments + documents only — no scorecard API)
  static const refereeEvents = '/referee/events';

  // Misc
  static const settings = '/settings';
  static const statistics = '/statistics';

  // Role sets
  static const Set<UserRole> authenticatedRoles = {
    UserRole.SUPER_ADMIN,
    UserRole.ADMIN,
    UserRole.ORGANIZER,
    UserRole.CLUB,
    UserRole.COACH,
    UserRole.FIGHTER,
    UserRole.REFEREE,
    UserRole.USER,
  };

  static const Set<UserRole> adminRoles = {
    UserRole.SUPER_ADMIN,
    UserRole.ADMIN,
  };

  static const Set<UserRole> tournamentManagerRoles = {
    UserRole.SUPER_ADMIN,
    UserRole.ADMIN,
    UserRole.ORGANIZER,
  };

  static const Set<UserRole> clubRoles = {UserRole.CLUB};

  static const Set<UserRole> coachRoles = {UserRole.COACH};

  static const Set<UserRole> fighterRoles = {UserRole.FIGHTER};

  static const Set<UserRole> tournamentParticipantRoles = {
    UserRole.FIGHTER,
    UserRole.COACH,
    UserRole.CLUB,
    UserRole.REFEREE,
    UserRole.SUPER_ADMIN,
    UserRole.ADMIN,
    UserRole.ORGANIZER,
  };

  static const Set<UserRole> refereeRoles = {UserRole.REFEREE};

  // Helper to create a guarded page
  static GetPage _guardedPage({
    required String name,
    required GetPageBuilder page,
    Set<UserRole> roles = authenticatedRoles,
    Bindings? binding,
  }) {
    return GetPage(
      name: name,
      page: page,
      binding: binding,
      middlewares: [_RoleRouteGuard(allowedRoles: roles)],
    );
  }

  // List of all routes
  static List<GetPage> pages = [
    // Authentication routes (login, register, forgot, etc.)
    ...AuthRoutes.pages,

    // Special system routes
    GetPage(name: accessDenied, page: () => const _AccessDeniedPage()),
    GetPage(name: notFound, page: () => const _NotFoundPage()),

    // Dashboard
    _guardedPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // Fighter routes
    _guardedPage(
      name: fighterProfile,
      page: () => FighterProfileView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    // Legacy alias
    _guardedPage(
      name: '/fighter-profile',
      page: () => FighterProfileView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _guardedPage(
      name: fighterRecord,
      page: () => const FighterRecordView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _guardedPage(
      name: '/fighter-record',
      page: () => const FighterRecordView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _guardedPage(
      name: fighters,
      page: () => UserListView(),
      roles: adminRoles,
      binding: UserBinding(),
    ),

    // Coach routes
    _guardedPage(
      name: coachProfile,
      page: () => SharedProfileView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _guardedPage(
      name: '/coach-profile',
      page: () => SharedProfileView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _guardedPage(
      name: coachAthletes,
      page: () => const CoachAthletesView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _guardedPage(
      name: '/coach-athletes',
      page: () => const CoachAthletesView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),

    // Club routes
    _guardedPage(
      name: clubs,
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
        UserRole.FIGHTER,
      },
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/gyms',
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
        UserRole.FIGHTER,
      },
      binding: GymBinding(),
    ),
    _guardedPage(
      name: clubDetail,
      page: () => ClubDetailsView(clubId: _extractArgument('id')),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
        UserRole.FIGHTER,
      },
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/gym/:id',
      page: () => ClubDetailsView(clubId: _extractArgument('id')),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
        UserRole.FIGHTER,
      },
      binding: GymBinding(),
    ),

    _guardedPage(
      name: clubSettings,
      page: () => SharedProfileView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/club-settings',
      page: () => SharedProfileView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: clubFighters,
      page: () => const ClubFightersView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: clubAthletes,
      page: () => const ClubAthletesView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/club-fighters',
      page: () => const ClubFightersView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: clubCoaches,
      page: () => const ClubCoachesView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/club-coaches',
      page: () => const ClubCoachesView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: clubInvitations,
      page: () => const ClubInvitationsView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _guardedPage(
      name: '/club-invitations',
      page: () => const ClubInvitationsView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),

    // Tournament (Event) routes
    _guardedPage(
      name: tournaments,
      page: () => EventListView(),
      roles: tournamentParticipantRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: events, // legacy alias
      page: () => EventListView(),
      binding: EventBinding(),
    ),
    _guardedPage(
      name: tournamentManagement,
      page: () => EventListView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: adminEvents,
      page: () => EventListView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: tournamentCreate,
      page: () => CreateEventView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: legacyCreateEvent,
      page: () => CreateEventView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: tournamentRegistrations,
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: tournamentDetail,
      page: () => EventDetailView(eventId: _extractArgument('id')),
      roles: tournamentParticipantRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: legacyEventDetail,
      page: () => EventDetailView(eventId: _extractArgument('id')),
      roles: tournamentParticipantRoles,
      binding: EventBinding(),
    ),

    // Registration workflows
    _guardedPage(
      name: myRegistrations,
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: '/my-registrations',
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: pendingRegistrations,
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: '/pending-registrations',
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: fighterRegistrations,
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: '/fighter-registrations',
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: coachRegistrations,
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: '/coach-registrations',
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: organizerRegistrations,
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _guardedPage(
      name: '/organizer-registrations',
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),

    // Master data (admin only)
    _guardedPage(
      name: sports,
      page: () => const SportsView(),
      roles: adminRoles,
    ),
    _guardedPage(
      name: categories,
      page: () => const CategoriesView(),
      roles: adminRoles,
    ),
    _guardedPage(
      name: countries,
      page: () => const CountriesView(),
      roles: adminRoles,
    ),

    // User & admin management
    _guardedPage(
      name: users,
      page: () => UserListView(),
      roles: adminRoles,
      binding: UserBinding(),
    ),
    _guardedPage(
      name: adminManagement,
      page: () => const AdminListView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _guardedPage(
      name: legacyAdminManagement,
      page: () => const AdminListView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _guardedPage(
      name: adminDetail,
      page: () => AdminDetailView(adminId: _extractArgument('id')),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _guardedPage(
      name: legacyAdminDetail,
      page: () => AdminDetailView(adminId: _extractArgument('id')),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _guardedPage(
      name: adminProfile,
      page: () => SharedProfileView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _guardedPage(
      name: '/admin-profile',
      page: () => SharedProfileView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),

    // Organizer management
    _guardedPage(
      name: organizerManagement,
      page: () => const OrganizerListView(),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _guardedPage(
      name: legacyOrganizerManagement,
      page: () => const OrganizerListView(),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _guardedPage(
      name: organizerDetail,
      page: () => OrganizerDetailView(organizerId: _extractArgument('id')),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _guardedPage(
      name: legacyOrganizerDetail,
      page: () => OrganizerDetailView(organizerId: _extractArgument('id')),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _guardedPage(
      name: organizerProfile,
      page: () => SharedProfileView(),
      roles: {UserRole.ORGANIZER},
      binding: OrganizerBinding(),
    ),
    _guardedPage(
      name: '/organizer-profile',
      page: () => SharedProfileView(),
      roles: {UserRole.ORGANIZER},
      binding: OrganizerBinding(),
    ),

    // Verification & documents
    _guardedPage(
      name: verification,
      page: () => const VerificationListView(),
      roles: adminRoles,
      binding: VerificationBinding(),
    ),
    _guardedPage(
      name: legacyVerification,
      page: () => const VerificationListView(),
      roles: adminRoles,
      binding: VerificationBinding(),
    ),
    _guardedPage(
      name: documents,
      page: () => const DocumentsView(),
      roles: {UserRole.FIGHTER, UserRole.REFEREE, UserRole.COACH},
    ),

    // Referee workflows
    _guardedPage(
      name: refereeProfile,
      page: () => SharedProfileView(),
      roles: refereeRoles,
    ),
    _guardedPage(
      name: '/referee-profile',
      page: () => SharedProfileView(),
      roles: refereeRoles,
    ),
    _guardedPage(
      name: refereeEvents,
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: '/referee-events',
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),
    // Legacy referee routes redirect to tournaments
    _guardedPage(
      name: '/referee-upcoming',
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),
    _guardedPage(
      name: '/referee-scorecards',
      page: () => const DocumentsView(),
      roles: refereeRoles,
    ),
    _guardedPage(
      name: '/referee-history',
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),

    // Miscellaneous
    _guardedPage(
      name: settings,
      page: () =>
          const _PlaceholderPage(title: 'Settings', icon: Icons.settings),
    ),
    _guardedPage(
      name: statistics,
      page: () => const StatisticsView(),
      roles: adminRoles,
    ),
  ];
}
