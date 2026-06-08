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

// Club
import 'package:xfighter/modules/gym/bindings/gym_binding.dart';
import 'package:xfighter/modules/gym/views/gym_list_view.dart';

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

// Coach
import 'package:xfighter/modules/coach/bindings/coach_binding.dart';
import 'package:xfighter/modules/coach/views/coach_athletes_view.dart';

// Registrations
import 'package:xfighter/modules/registration/bindings/registration_binding.dart';
import 'package:xfighter/modules/registration/views/coach_registrations_view.dart';
import 'package:xfighter/modules/registration/views/fighter_registrations_view.dart';
import 'package:xfighter/modules/registration/views/organizer_registrations_view.dart';

// Matchmaking
import 'package:xfighter/modules/matchmaking/controllers/matchmaking_controller.dart';
import 'package:xfighter/modules/matchmaking/views/fight_card_builder_view.dart';

// Admin
import 'package:xfighter/modules/admin/bindings/admin_binding.dart';
import 'package:xfighter/modules/admin/views/admin_detail_view.dart';
import 'package:xfighter/modules/admin/views/admin_list_view.dart';

// Organizer
import 'package:xfighter/modules/organizer/bindings/organizer_binding.dart';
import 'package:xfighter/modules/organizer/views/organizer_detail_view.dart';
import 'package:xfighter/modules/organizer/views/organizer_list_view.dart';

// Verification
import 'package:xfighter/modules/verification/bindings/verification_binding.dart';
import 'package:xfighter/modules/verification/views/verification_list_view.dart';

class _RoleRouteGuard extends GetMiddleware {
  _RoleRouteGuard({
    required this.allowedRoles,
    this.blockDisabledUsers = true,
  }) : super(priority: 1);

  final Set<UserRole> allowedRoles;
  final bool blockDisabledUsers;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: AppRouter.login);
    }

    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (!authController.isLoggedIn.value || user == null) {
      return const RouteSettings(name: AppRouter.login);
    }

    if (blockDisabledUsers && user.status == UserStatus.DISABLED) {
      return const RouteSettings(name: AppRouter.accessDenied);
    }

    if (allowedRoles.isNotEmpty && !allowedRoles.contains(user.role)) {
      return const RouteSettings(name: AppRouter.accessDenied);
    }

    return null;
  }
}

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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFFE31837)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white54),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                color: Color(0xFFE31837),
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'This workflow is not available for your role.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  foregroundColor: Colors.white,
                ),
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

class AppRouter {
  // Auth
  static const initial = '/';
  static const login = '/login';
  static const register = '/register';

  // Core
  static const dashboard = '/dashboard';
  static const accessDenied = '/access-denied';

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
  static const clubDetail = '/clubs/:id';
  static const clubFighters = '/club/fighters';
  static const clubCoaches = '/club/coaches';
  static const clubInvitations = '/club/invitations';

  // Tournaments map to /api/tournaments.
  static const tournaments = '/tournaments';
  static const tournamentManagement = '/tournaments/manage';
  static const tournamentCreate = '/tournaments/create';
  static const tournamentDetail = '/tournaments/:id';
  static const tournamentRegistrations = '/tournaments/:id/registrations';
  static const tournamentFightCard = '/tournaments/:id/fight-card';

  // Legacy event routes kept so older UI/controller links remain valid.
  static const events = '/events';
  static const eventDetail = tournamentDetail;
  static const legacyEventDetail = '/event/:id';
  static const adminEvents = '/admin-events';
  static const createEvent = tournamentCreate;
  static const legacyCreateEvent = '/create-event';

  // Registration workflows map to tournament registration endpoints.
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

  // Referee workflow placeholders.
  static const refereeUpcoming = '/referee/upcoming';
  static const refereeScorecards = '/referee/scorecards';
  static const refereeHistory = '/referee/history';
  static const refereeEvents = '/referee/events';

  // Misc
  static const fightCards = '/fight-cards';
  static const settings = '/settings';
  static const statistics = '/statistics';

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

  static const Set<UserRole> clubRoles = {
    UserRole.CLUB,
  };

  static const Set<UserRole> coachRoles = {
    UserRole.COACH,
  };

  static const Set<UserRole> fighterRoles = {
    UserRole.FIGHTER,
  };

  static const Set<UserRole> refereeRoles = {
    UserRole.REFEREE,
  };

  static List<GetMiddleware> _guard(Set<UserRole> roles) {
    return [_RoleRouteGuard(allowedRoles: roles)];
  }

  static String _argumentOrParam(String key) {
    final argument = Get.arguments;
    return Get.parameters[key] ?? (argument is String ? argument : '');
  }

  static GetPage _page({
    required String name,
    required GetPageBuilder page,
    Set<UserRole> roles = authenticatedRoles,
    Bindings? binding,
  }) {
    return GetPage(
      name: name,
      page: page,
      binding: binding,
      middlewares: _guard(roles),
    );
  }

  static List<GetPage> pages = [
    ...AuthRoutes.pages,
    GetPage(
      name: accessDenied,
      page: () => const _AccessDeniedPage(),
    ),

    _page(
      name: dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // Fighter
    _page(
      name: fighterProfile,
      page: () => SharedProfileView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _page(
      name: '/fighter-profile',
      page: () => SharedProfileView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _page(
      name: fighterRecord,
      page: () => const FighterRecordView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _page(
      name: '/fighter-record',
      page: () => const FighterRecordView(),
      roles: fighterRoles,
      binding: FighterBinding(),
    ),
    _page(
      name: fighters,
      page: () => const _PlaceholderPage(
        title: 'Fighters',
        icon: Icons.sports_mma,
      ),
      roles: {...adminRoles, UserRole.CLUB, UserRole.COACH},
      binding: FighterBinding(),
    ),

    // Coach
    _page(
      name: coachProfile,
      page: () => SharedProfileView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _page(
      name: '/coach-profile',
      page: () => SharedProfileView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _page(
      name: coachAthletes,
      page: () => const CoachAthletesView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),
    _page(
      name: '/coach-athletes',
      page: () => const CoachAthletesView(),
      roles: coachRoles,
      binding: CoachBinding(),
    ),

    // Club
    _page(
      name: clubs,
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
      },
      binding: GymBinding(),
    ),
    _page(
      name: '/gyms',
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
      },
      binding: GymBinding(),
    ),
    _page(
      name: clubDetail,
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
      },
      binding: GymBinding(),
    ),
    _page(
      name: '/gym/:id',
      page: () => const GymListView(),
      roles: {
        ...adminRoles,
        UserRole.ORGANIZER,
        UserRole.CLUB,
        UserRole.COACH,
      },
      binding: GymBinding(),
    ),
    _page(
      name: clubSettings,
      page: () => SharedProfileView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: '/club-settings',
      page: () => SharedProfileView(),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: clubFighters,
      page: () => const _PlaceholderPage(
        title: 'Club Fighters',
        icon: Icons.sports_mma,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: '/club-fighters',
      page: () => const _PlaceholderPage(
        title: 'Club Fighters',
        icon: Icons.sports_mma,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: clubCoaches,
      page: () => const _PlaceholderPage(
        title: 'Club Coaches',
        icon: Icons.sports,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: '/club-coaches',
      page: () => const _PlaceholderPage(
        title: 'Club Coaches',
        icon: Icons.sports,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: clubInvitations,
      page: () => const _PlaceholderPage(
        title: 'Club Invitations',
        icon: Icons.mail,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),
    _page(
      name: '/club-invitations',
      page: () => const _PlaceholderPage(
        title: 'Club Invitations',
        icon: Icons.mail,
      ),
      roles: clubRoles,
      binding: GymBinding(),
    ),

    // Tournaments
    _page(
      name: tournaments,
      page: () => EventListView(),
      binding: EventBinding(),
    ),
    _page(
      name: events,
      page: () => EventListView(),
      binding: EventBinding(),
    ),
    _page(
      name: tournamentManagement,
      page: () => EventListView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _page(
      name: adminEvents,
      page: () => EventListView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _page(
      name: tournamentCreate,
      page: () => CreateEventView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _page(
      name: legacyCreateEvent,
      page: () => CreateEventView(),
      roles: tournamentManagerRoles,
      binding: EventBinding(),
    ),
    _page(
      name: tournamentRegistrations,
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: tournamentFightCard,
      page: () => FightCardBuilderView(
        eventId: Get.parameters['id'] ?? '',
        eventName: Get.parameters['name'] ?? 'Fight Card',
      ),
      roles: tournamentManagerRoles,
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MatchmakingController());
      }),
    ),
    _page(
      name: tournamentDetail,
      page: () => EventDetailView(eventId: Get.parameters['id'] ?? ''),
      binding: EventBinding(),
    ),
    _page(
      name: legacyEventDetail,
      page: () => EventDetailView(eventId: Get.parameters['id'] ?? ''),
      binding: EventBinding(),
    ),

    // Registrations
    _page(
      name: myRegistrations,
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: '/my-registrations',
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: pendingRegistrations,
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: '/pending-registrations',
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: fighterRegistrations,
      page: () => FighterRegistrationsView(),
      roles: fighterRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: '/fighter-registrations',
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: coachRegistrations,
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: '/coach-registrations',
      page: () => CoachRegistrationsView(),
      roles: coachRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: organizerRegistrations,
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),
    _page(
      name: '/organizer-registrations',
      page: () => OrganizerRegistrationsView(),
      roles: tournamentManagerRoles,
      binding: RegistrationBinding(),
    ),

    // Master data
    _page(
      name: sports,
      page: () => const _PlaceholderPage(
        title: 'Sports',
        icon: Icons.sports,
      ),
      roles: adminRoles,
    ),
    _page(
      name: categories,
      page: () => const _PlaceholderPage(
        title: 'Categories',
        icon: Icons.category,
      ),
      roles: adminRoles,
    ),
    _page(
      name: countries,
      page: () => const _PlaceholderPage(
        title: 'Countries',
        icon: Icons.flag,
      ),
      roles: adminRoles,
    ),

    // Users / admin
    _page(
      name: users,
      page: () => UserListView(),
      roles: adminRoles,
      binding: UserBinding(),
    ),
    _page(
      name: adminManagement,
      page: () => const AdminListView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _page(
      name: legacyAdminManagement,
      page: () => const AdminListView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _page(
      name: adminDetail,
      page: () => AdminDetailView(adminId: _argumentOrParam('id')),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _page(
      name: legacyAdminDetail,
      page: () => AdminDetailView(adminId: _argumentOrParam('id')),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _page(
      name: adminProfile,
      page: () => SharedProfileView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),
    _page(
      name: '/admin-profile',
      page: () => SharedProfileView(),
      roles: adminRoles,
      binding: AdminBinding(),
    ),

    // Organizers
    _page(
      name: organizerManagement,
      page: () => const OrganizerListView(),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _page(
      name: legacyOrganizerManagement,
      page: () => const OrganizerListView(),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _page(
      name: organizerDetail,
      page: () => OrganizerDetailView(organizerId: _argumentOrParam('id')),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _page(
      name: legacyOrganizerDetail,
      page: () => OrganizerDetailView(organizerId: _argumentOrParam('id')),
      roles: adminRoles,
      binding: OrganizerBinding(),
    ),
    _page(
      name: organizerProfile,
      page: () => SharedProfileView(),
      roles: {UserRole.ORGANIZER},
      binding: OrganizerBinding(),
    ),
    _page(
      name: '/organizer-profile',
      page: () => SharedProfileView(),
      roles: {UserRole.ORGANIZER},
      binding: OrganizerBinding(),
    ),

    // Verification / documents
    _page(
      name: verification,
      page: () => const VerificationListView(),
      roles: adminRoles,
      binding: VerificationBinding(),
    ),
    _page(
      name: legacyVerification,
      page: () => const VerificationListView(),
      roles: adminRoles,
      binding: VerificationBinding(),
    ),
    _page(
      name: documents,
      page: () => const _PlaceholderPage(
        title: 'Documents',
        icon: Icons.description,
      ),
      roles: {
        UserRole.FIGHTER,
        UserRole.REFEREE,
        UserRole.CLUB,
      },
    ),

    // Referee
    _page(
      name: refereeProfile,
      page: () => SharedProfileView(),
      roles: refereeRoles,
    ),
    _page(
      name: '/referee-profile',
      page: () => SharedProfileView(),
      roles: refereeRoles,
    ),
    _page(
      name: refereeUpcoming,
      page: () => const _PlaceholderPage(
        title: 'Upcoming Fights',
        icon: Icons.sports_mma,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: '/referee-upcoming',
      page: () => const _PlaceholderPage(
        title: 'Upcoming Fights',
        icon: Icons.sports_mma,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: refereeScorecards,
      page: () => const _PlaceholderPage(
        title: 'Scorecards',
        icon: Icons.assignment,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: '/referee-scorecards',
      page: () => const _PlaceholderPage(
        title: 'Scorecards',
        icon: Icons.assignment,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: refereeHistory,
      page: () => const _PlaceholderPage(
        title: 'Match History',
        icon: Icons.history,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: '/referee-history',
      page: () => const _PlaceholderPage(
        title: 'Match History',
        icon: Icons.history,
      ),
      roles: refereeRoles,
    ),
    _page(
      name: refereeEvents,
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),
    _page(
      name: '/referee-events',
      page: () => EventListView(),
      roles: refereeRoles,
      binding: EventBinding(),
    ),

    // Fight cards / misc
    _page(
      name: fightCards,
      page: () => FightCardBuilderView(
        eventId: Get.parameters['id'] ?? '',
        eventName: Get.parameters['name'] ?? 'Fight Card',
      ),
      roles: tournamentManagerRoles,
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MatchmakingController());
      }),
    ),
    _page(
      name: settings,
      page: () => const _PlaceholderPage(
        title: 'Settings',
        icon: Icons.settings,
      ),
    ),
    _page(
      name: statistics,
      page: () => const _PlaceholderPage(
        title: 'Statistics',
        icon: Icons.analytics,
      ),
      roles: adminRoles,
    ),
  ];
}
