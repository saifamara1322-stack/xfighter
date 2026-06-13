import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/tournament_repository.dart';
import '../../../data/repositories/country_repository.dart';
import '../../../data/repositories/club_repository.dart';
import '../../../data/repositories/coach_repository.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/country_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/fighter_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/user_lookup_repository.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';

class EventController extends GetxController {
  final TournamentRepository _tournamentRepo = TournamentRepository();
  final CountryRepository _countryRepo = CountryRepository();
  final ClubRepository _clubRepo = ClubRepository();
  final CoachRepository _coachRepo = CoachRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  final UserLookupRepository _lookup = UserLookupRepository();
  final AuthController _authController = Get.find<AuthController>();

  var events = <Tournament>[].obs;
  var upcomingEvents = <Tournament>[].obs;
  var organizerEvents = <Tournament>[].obs;
  var myRegisteredEvents = <Tournament>[].obs;

  var selectedEvent = Rx<Tournament?>(null);
  var eventDivisions = <TournamentDivision>[].obs;
  var eventRegistrations = <TournamentRegistration>[].obs;
  var eventRules = <TournamentRule>[].obs;
  var countries = <Country>[].obs;
  var categories = <Category>[].obs;
  var registerableFighters = <Fighter>[].obs;

  var isLoading = false.obs;
  var isCreating = false.obs;
  var isDetailLoading = false.obs;
  var isLoadingCountries = false.obs;

  // Form selections
  var selectedCountryId = Rx<String?>(null);
  var selectedLevel = Rx<String>('LOCAL');

  @override
  void onInit() {
    super.onInit();
    loadEvents();
    loadCountries();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      categories.value = await _categoryRepo.getCategories();
    } catch (_) {
      categories.clear();
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _showSnackbar(String title, String message, {Color backgroundColor = Colors.green}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title, message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final paged = await _tournamentRepo.getTournaments(page: 0, size: 100);
      events.value = paged.content;

      upcomingEvents.value = paged.content.where((e) =>
          e.startDate != null && e.startDate!.isAfter(DateTime.now())
      ).toList();

      final currentUserId = _authController.currentUser.value?.id;
      final role = _authController.currentUser.value?.role;

      organizerEvents.value = currentUserId == null
          ? []
          : paged.content.where((e) => e.organizerId == currentUserId).toList();

      if (role == UserRole.FIGHTER) {
        myRegisteredEvents.value = paged.content
            .where((e) => e.status == TournamentStatus.OPEN)
            .take(1)
            .toList();
      }
    } catch (e) {
      events.clear();
      upcomingEvents.clear();
      organizerEvents.clear();
      _showSnackbar('Erreur', 'Failed to load tournaments: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCountries() async {
    isLoadingCountries.value = true;
    try {
      countries.value = await _countryRepo.getAllCountries(); // GET /api/countries
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to load countries: $e', backgroundColor: Colors.red);
      countries.clear();
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<void> loadEventDetails(String eventId) async {
    isDetailLoading.value = true;
    try {
      final results = await Future.wait([
        _tournamentRepo.getTournamentById(eventId),
        _tournamentRepo.getDivisions(eventId),
        _tournamentRepo.getRegistrations(eventId),
        _tournamentRepo.getRules(eventId),
      ]);

      selectedEvent.value = results[0] as Tournament;
      eventDivisions.value = results[1] as List<TournamentDivision>;
      eventRegistrations.value = results[2] as List<TournamentRegistration>;
      eventRules.value = results[3] as List<TournamentRule>;
      await _loadRegisterableFighters();
    } catch (e) {
      selectedEvent.value = null;
      _showSnackbar('Erreur', 'Failed to load details: $e', backgroundColor: Colors.red);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> _loadRegisterableFighters() async {
    registerableFighters.clear();
    final user = _authController.currentUser.value;
    if (user == null) return;

    try {
      switch (user.role) {
        case UserRole.CLUB:
          final clubId = await _clubRepo.resolveMyClubId();
          if (clubId != null) {
            registerableFighters.value =
                await _clubRepo.getClubFighters(clubId);
          }
          break;
        case UserRole.COACH:
          registerableFighters.value =
              await _coachRepo.getCoachFighters(user.id);
          break;
        default:
          break;
      }
    } catch (_) {
      registerableFighters.clear();
    }
  }

  TournamentRegistration? registrationForFighter(
      String fighterId, String divisionId) {
    return eventRegistrations.firstWhereOrNull(
      (r) => r.fighterId == fighterId && r.divisionId == divisionId,
    );
  }

  bool get canRegisterOthers {
    final role = _authController.currentUser.value?.role;
    return role == UserRole.CLUB || role == UserRole.COACH;
  }

  bool isRegistrationWindowOpen(Tournament event) {
    final now = DateTime.now();
    return event.status == TournamentStatus.OPEN &&
        now.isAfter(event.registrationOpenAt) &&
        now.isBefore(event.registrationCloseAt);
  }

  Future<void> createEventWithValues({
    required String name,
    required String description,
    required String city,
    required String venue,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime registrationOpenAt,
    required DateTime registrationCloseAt,
    required String level,
    required String countryId,
  }) async {
    final organizerId = _authController.currentUser.value?.id;
    if (organizerId == null) {
      _showSnackbar('Erreur', 'You must be logged in as an organizer.', backgroundColor: Colors.red);
      return;
    }

    if (name.isEmpty || city.isEmpty || venue.isEmpty || countryId.isEmpty) {
      _showSnackbar('Erreur', 'Name, city, venue, and country are required.', backgroundColor: Colors.red);
      return;
    }

    isCreating.value = true;
    try {
      final request = CreateTournamentRequest(
        name: name,
        description: description.isNotEmpty ? description : null,
        level: level,
        countryId: countryId,
        organizerId: organizerId,
        city: city,
        venue: venue,
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
        registrationOpenAt: registrationOpenAt.toIso8601String(),
        registrationCloseAt: registrationCloseAt.toIso8601String(),
      );

      final event = await _tournamentRepo.createTournament(request);
      events.insert(0, event);

      _showSnackbar('Succès', 'Tournament created successfully');
      Get.back();
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to create: $e', backgroundColor: Colors.red);
    } finally {
      isCreating.value = false;
    }
  }

  // Other CRUD methods (update, delete, etc.) remain similar – adapt to the new model
  Future<void> updateEvent(String id, UpdateTournamentRequest request) async {
    try {
      final updated = await _tournamentRepo.updateTournament(id, request);
      selectedEvent.value = updated;

      final index = events.indexWhere((e) => e.id == id);
      if (index != -1) events[index] = updated;

      final upcomingIndex = upcomingEvents.indexWhere((e) => e.id == id);
      if (upcomingIndex != -1) upcomingEvents[upcomingIndex] = updated;

      final organizerIndex = organizerEvents.indexWhere((e) => e.id == id);
      if (organizerIndex != -1) organizerEvents[organizerIndex] = updated;

      _showSnackbar('Succès', 'Tournament updated successfully');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to update: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _tournamentRepo.deleteTournament(id);
      events.removeWhere((e) => e.id == id);
      upcomingEvents.removeWhere((e) => e.id == id);
      organizerEvents.removeWhere((e) => e.id == id);
      Get.back();
      _showSnackbar('Succès', 'Tournament deleted');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to delete: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> changeStatus(String id, String newStatus) async {
    try {
      Tournament updated;
      switch (newStatus) {
        case 'OPEN':
          updated = await _tournamentRepo.openRegistrations(id);
          break;
        case 'CLOSED':
          updated = await _tournamentRepo.closeRegistrations(id);
          break;
        case 'IN_PROGRESS':
          updated = await _tournamentRepo.startTournament(id);
          break;
        case 'COMPLETED':
          updated = await _tournamentRepo.completeTournament(id);
          break;
        default:
          updated = await _tournamentRepo.changeStatus(id, newStatus);
      }
      selectedEvent.value = updated;

      final index = events.indexWhere((e) => e.id == id);
      if (index != -1) events[index] = updated;

      _showSnackbar('Succès', 'Status changed to ${updated.status.displayName}');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to change status: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> approveRegistration(String registrationId) async {
    try {
      final updated =
          await _tournamentRepo.approveRegistration(registrationId);
      final index =
          eventRegistrations.indexWhere((r) => r.id == registrationId);
      if (index != -1) eventRegistrations[index] = updated;
      _showSnackbar('Succès', 'Registration approved');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to approve: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> rejectRegistration(String registrationId, String reason) async {
    try {
      final updated =
          await _tournamentRepo.rejectRegistration(registrationId, reason);
      final index =
          eventRegistrations.indexWhere((r) => r.id == registrationId);
      if (index != -1) eventRegistrations[index] = updated;
      _showSnackbar('Succès', 'Registration rejected');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to reject: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> cancelRegistration(String registrationId) async {
    try {
      final updated =
          await _tournamentRepo.cancelRegistration(registrationId);
      final index =
          eventRegistrations.indexWhere((r) => r.id == registrationId);
      if (index != -1) eventRegistrations[index] = updated;
      _showSnackbar('Succès', 'Registration cancelled');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to cancel: $e', backgroundColor: Colors.red);
    }
  }

  bool get isParticipant {
    final role = _authController.currentUser.value?.role;
    return role == UserRole.FIGHTER ||
        role == UserRole.COACH ||
        role == UserRole.CLUB;
  }

  Future<void> registerFighterByEmailForTournament(
    String eventId,
    String divisionId,
    String fighterEmail,
  ) async {
    try {
      final fighterId = await _lookup.resolveFighterIdByEmail(fighterEmail);
      await registerForTournament(
        eventId,
        divisionId,
        fighterUserId: fighterId,
      );
    } catch (e) {
      _showSnackbar('Erreur', e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> registerForTournament(String eventId, String? divisionId,
      {String? fighterUserId}) async {
    final currentUserId = _authController.currentUser.value?.id;
    if (currentUserId == null) {
      _showSnackbar('Erreur', 'You must be logged in to register.', backgroundColor: Colors.red);
      return;
    }

    final targetFighterId = fighterUserId ?? currentUserId;

    try {
      final request = CreateTournamentRegistrationRequest(
        fighterId: targetFighterId,
        divisionId: divisionId,
      );
      final reg = await _tournamentRepo.registerAthlete(eventId, request);
      final existing =
          eventRegistrations.indexWhere((r) => r.id == reg.id);
      if (existing >= 0) {
        eventRegistrations[existing] = reg;
      } else {
        eventRegistrations.add(reg);
      }

      final event = events.firstWhereOrNull((e) => e.id == eventId);
      if (event != null && !myRegisteredEvents.any((e) => e.id == eventId)) {
        myRegisteredEvents.add(event);
      }

      _showSnackbar('Succès', 'Registration submitted successfully!');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to register: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> createDivision(
    String eventId, {
    String? sportCategoryId,
    String? gender,
    double? minW,
    double? maxW,
    int? maxParticipants,
  }) async {
    if (sportCategoryId == null || sportCategoryId.isEmpty) {
      _showSnackbar('Erreur', 'Sport category is required', backgroundColor: Colors.red);
      return;
    }
    try {
      final request = CreateTournamentDivisionRequest(
        categoryId: sportCategoryId,
        gender: gender,
        weightMin: minW,
        weightMax: maxW,
        maxParticipants: maxParticipants,
      );
      final div = await _tournamentRepo.addDivision(eventId, request);
      eventDivisions.add(div);
      _showSnackbar('Succès', 'Division added');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to add division: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> createRule(String eventId, String type, String desc) async {
    try {
      final request = CreateTournamentRuleRequest(
        ruleType: type,
        description: desc,
      );
      final rule = await _tournamentRepo.addRule(eventId, request);
      eventRules.add(rule);
      _showSnackbar('Succès', 'Rule added');
    } catch (e) {
      _showSnackbar('Erreur', 'Failed to add rule: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> deleteRule(String ruleId) async {
    eventRules.removeWhere((r) => r.id == ruleId);
    _showSnackbar('Succès', 'Rule deleted');
  }

  Future<void> deleteDivision(String divisionId) async {
    eventDivisions.removeWhere((d) => d.id == divisionId);
    _showSnackbar('Succès', 'Division deleted');
  }
}