import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/auth/routes/auth_routes.dart';

// ── Dashboard ─────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/dashboard/views/dashboard_view.dart';
import 'package:xfighter/modules/dashboard/bindings/dashboard_binding.dart';

// ── Fighter ──────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/fighter/views/fighter_profile_view.dart';
import 'package:xfighter/modules/fighter/bindings/fighter_binding.dart';

// ── Gym / Club ────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/gym/views/gym_list_view.dart';
import 'package:xfighter/modules/gym/bindings/gym_binding.dart';

// ── Users ─────────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/users/views/user_list_view.dart';
import 'package:xfighter/modules/users/bindings/user_binding.dart';

// ── Events ────────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/event/views/event_list_view.dart';
import 'package:xfighter/modules/event/views/event_detail_view.dart';
import 'package:xfighter/modules/event/views/create_event_view.dart';
import 'package:xfighter/modules/event/bindings/event_binding.dart';

// ── Coach ─────────────────────────────────────────────────────────────────────
import 'package:xfighter/modules/coach/views/coach_profile_view.dart';
import 'package:xfighter/modules/coach/views/coach_management_view.dart';
import 'package:xfighter/modules/coach/bindings/coach_binding.dart';

// ── Registrations ─────────────────────────────────────────────────────────────
import 'package:xfighter/modules/registration/views/fighter_registrations_view.dart';
import 'package:xfighter/modules/registration/views/coach_registrations_view.dart';
import 'package:xfighter/modules/registration/bindings/registration_binding.dart';

// ── Matchmaking ───────────────────────────────────────────────────────────────
import 'package:xfighter/modules/matchmaking/views/fight_card_builder_view.dart';
import 'package:xfighter/modules/matchmaking/controllers/matchmaking_controller.dart';

/// Placeholder screens for routes that don't have a full view yet.
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage(this.title);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text('$title — coming soon',
              style: const TextStyle(fontSize: 18)),
        ),
      );
}

class AppRouter {
  // ── Route name constants ────────────────────────────────────────────────────

  // Auth
  static const initial = '/';
  static const login = '/login';
  static const register = '/register';

  // Core
  static const dashboard = '/dashboard';

  // Fighter
  static const fighterProfile = '/fighter-profile';
  static const fighters = '/fighters';

  // Gym / Club
  static const gyms = '/gyms';
  static const gymDetail = '/gym/:id';

  // Users (admin)
  static const users = '/users';

  // Events
  static const events = '/events';
  static const eventDetail = '/event/:id';
  static const adminEvents = '/admin-events';
  static const createEvent = '/create-event';

  // Coach
  static const coachProfile = '/coach-profile';
  static const coachAthletes = '/coach-athletes';

  // Registrations
  static const myRegistrations = '/my-registrations';
  static const pendingRegistrations = '/pending-registrations';
  static const fighterRegistrations = '/fighter-registrations';

  // Matchmaking / fight cards
  static const fightCards = '/fight-cards';

  // Profile fallbacks
  static const organizerProfile = '/organizer-profile';
  static const adminProfile = '/admin-profile';

  // Misc
  static const settings = '/settings';
  static const statistics = '/statistics';

  // ── Page list ──────────────────────────────────────────────────────────────

  static List<GetPage> pages = [
    // ── Auth ─────────────────────────────────────────────────────────────────
    ...AuthRoutes.pages,

    // ── Dashboard ────────────────────────────────────────────────────────────
    GetPage(
      name: dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),

    // ── Fighter ──────────────────────────────────────────────────────────────
    GetPage(
      name: fighterProfile,
      page: () => FighterProfileView(),
      binding: FighterBinding(),
    ),
    GetPage(
      name: fighters,
      page: () => const _PlaceholderPage('Fighters'),
    ),

    // ── Gym / Club ───────────────────────────────────────────────────────────
    GetPage(
      name: gyms,
      page: () => const GymListView(),
      binding: GymBinding(),
    ),
    GetPage(
      name: gymDetail,
      page: () => const GymListView(), // detail view coming soon
      binding: GymBinding(),
    ),

    // ── Users ────────────────────────────────────────────────────────────────
    GetPage(
      name: users,
      page: () => UserListView(),
      binding: UserBinding(),
    ),

    // ── Events ───────────────────────────────────────────────────────────────
    GetPage(
      name: events,
      page: () => EventListView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: eventDetail,
      page: () => EventDetailView(eventId: Get.parameters['id'] ?? ''),
      binding: EventBinding(),
    ),
    GetPage(
      name: adminEvents,
      page: () => EventListView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: createEvent,
      page: () => CreateEventView(),
      binding: EventBinding(),
    ),

    // ── Coach ────────────────────────────────────────────────────────────────
    GetPage(
      name: coachProfile,
      page: () => CoachProfileView(),
      binding: CoachBinding(),
    ),
    GetPage(
      name: coachAthletes,
      page: () => CoachManagementView(),
      binding: CoachBinding(),
    ),

    // ── Registrations ────────────────────────────────────────────────────────
    GetPage(
      name: myRegistrations,
      page: () => FighterRegistrationsView(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: pendingRegistrations,
      page: () => CoachRegistrationsView(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: fighterRegistrations,
      page: () => FighterRegistrationsView(),
      binding: RegistrationBinding(),
    ),

    // ── Fight cards ──────────────────────────────────────────────────────────
    GetPage(
      name: fightCards,
      page: () => FightCardBuilderView(
        eventId: Get.parameters['id'] ?? '',
        eventName: Get.parameters['name'] ?? 'Fight Card',
      ),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MatchmakingController());
      }),
    ),

    // ── Profile fallbacks ────────────────────────────────────────────────────
    GetPage(
      name: organizerProfile,
      page: () => const _PlaceholderPage('Organizer Profile'),
    ),
    GetPage(
      name: adminProfile,
      page: () => const _PlaceholderPage('Admin Profile'),
    ),

    // ── Misc ─────────────────────────────────────────────────────────────────
    GetPage(
      name: settings,
      page: () => const _PlaceholderPage('Settings'),
    ),
    GetPage(
      name: statistics,
      page: () => const _PlaceholderPage('Statistics'),
    ),
  ];
}
