import 'package:get/get.dart';
import '../models/fighter_model.dart';
import '../models/fight_card_model.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class MatchmakingRepository {
  // Use dummy data since the API docs do not define matchmaking endpoints yet.
  // Using active user to generate different data.
  final List<FightCard> _dummyFightCards = [];
  bool _initialized = false;

  void _initDummyData() {
    if (_initialized) return;
    _initialized = true;
    final AuthController authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    final currentUserId = currentUser?.id ?? 'dummy_user';
    final userName = currentUser?.fullName ?? 'Fighter';

    // Generate user-specific data
    _dummyFightCards.addAll([
      FightCard(
        id: 'fight_1_$currentUserId',
        eventId: 'event_1',
        fighter1Id: currentUserId,
        fighter2Id: 'opponent_1',
        weightClass: 'Lightweight',
        status: FightStatus.scheduled,
        order: 1,
      ),
      FightCard(
        id: 'fight_2_$currentUserId',
        eventId: 'event_1',
        fighter1Id: currentUserId,
        fighter2Id: 'opponent_2',
        weightClass: 'Welterweight',
        status: FightStatus.scheduled,
        order: 2,
      ),
    ]);
  }

  Future<List<FightCard>> getFightCardsForEvent(String eventId) async {
    _initDummyData();
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyFightCards.where((f) => f.eventId == eventId).toList();
  }

  Future<FightCard> createFightCard(Map<String, dynamic> data) async {
    _initDummyData();
    await Future.delayed(const Duration(milliseconds: 800));
    final newCard = FightCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: data['eventId'],
      fighter1Id: data['fighter1Id'],
      fighter2Id: data['fighter2Id'],
      weightClass: data['weightClass'],
      status: FightStatus.scheduled,
      order: _dummyFightCards.length + 1,
    );
    _dummyFightCards.add(newCard);
    return newCard;
  }

  Future<void> updateFightStatus(String fightId, FightStatus status) async {
    _initDummyData();
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _dummyFightCards.indexWhere((f) => f.id == fightId);
    if (index != -1) {
      final current = _dummyFightCards[index];
      _dummyFightCards[index] = FightCard(
        id: current.id,
        eventId: current.eventId,
        fighter1Id: current.fighter1Id,
        fighter2Id: current.fighter2Id,
        weightClass: current.weightClass,
        status: status,
        order: current.order,
        winnerId: current.winnerId,
        method: current.method,
        methodDetails: current.methodDetails,
        round: current.round,
        scheduledTime: current.scheduledTime,
        actualTime: current.actualTime,
        refereeId: current.refereeId,
        fighter1Stats: current.fighter1Stats,
        fighter2Stats: current.fighter2Stats,
      );
    }
  }

  Future<List<Fighter>> getEligibleFighters(String eventId, String weightClass) async {
    _initDummyData();
    final AuthController authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    final currentUserId = currentUser?.id ?? 'dummy_user';
    final userName = currentUser?.fullName ?? 'John Doe';

    await Future.delayed(const Duration(milliseconds: 500));
    // Dummy eligible fighters based on current user
    return [
      Fighter(
        id: currentUserId,
        email: currentUser?.email ?? 'fighter1@test.com',
        fullName: userName,
        weight: 70.0,
        category: weightClass,
      ),
      Fighter(
        id: 'opponent_user',
        email: 'opponent@test.com',
        fullName: 'Jane Smith',
        weight: 69.5,
        category: weightClass,
      ),
    ];
  }
}
