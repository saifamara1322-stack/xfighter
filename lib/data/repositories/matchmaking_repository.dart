import '../models/fighter_model.dart';
import '../models/fight_card_model.dart';

class MatchmakingRepository {
  // Use dummy data since the API docs do not define matchmaking endpoints yet
  final List<FightCard> _dummyFightCards = [];

  Future<List<FightCard>> getFightCardsForEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyFightCards.where((f) => f.eventId == eventId).toList();
  }

  Future<FightCard> createFightCard(Map<String, dynamic> data) async {
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
    await Future.delayed(const Duration(milliseconds: 500));
    // Dummy eligible fighters
    return [
      Fighter(
        id: 'f1',
        email: 'fighter1@test.com',
        fullName: 'John Doe',
        weight: 70.0,
        category: 'Lightweight',
      ),
      Fighter(
        id: 'f2',
        email: 'fighter2@test.com',
        fullName: 'Jane Smith',
        weight: 69.5,
        category: 'Lightweight',
      ),
    ];
  }
}
