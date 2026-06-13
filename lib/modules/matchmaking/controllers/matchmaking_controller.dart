import 'package:get/get.dart';
import 'package:xfighter/data/repositories/matchmaking_repository.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/fight_card_model.dart';

class MatchmakingController extends GetxController {
  final MatchmakingRepository _repository = MatchmakingRepository();
  
  var fighters = <Fighter>[].obs;
  var fightCards = <FightCard>[].obs;
  var isLoading = false.obs;
  
  final String eventId;
  final String weightClass;

  MatchmakingController({required this.eventId, required this.weightClass});

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getEligibleFighters(eventId, weightClass),
        _repository.getFightCardsForEvent(eventId),
      ]);
      fighters.value = results[0] as List<Fighter>;
      // Filter fight cards for the specific weight class to build
      fightCards.value = (results[1] as List<FightCard>)
          .where((f) => f.weightClass == weightClass)
          .toList();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMatch(Fighter f1, Fighter f2) async {
    try {
      final newCard = await _repository.createFightCard({
        'eventId': eventId,
        'fighter1Id': f1.id,
        'fighter2Id': f2.id,
        'weightClass': weightClass,
      });
      fightCards.add(newCard);
      // Remove them from the eligible fighters pool locally
      fighters.removeWhere((f) => f.id == f1.id || f.id == f2.id);
      Get.snackbar('Match Created', '${f1.fullName} vs ${f2.fullName}', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> removeMatch(FightCard card) async {
    try {
      // API doesn't have delete match yet, assuming soft UI removal for now
      // Re-add to eligible pool (in reality we would re-fetch or map UUIDs to profiles)
      // This requires the full API endpoint or a reload
      fightCards.removeWhere((c) => c.id == card.id);
      await load(); // Reload to get eligible pool back
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
