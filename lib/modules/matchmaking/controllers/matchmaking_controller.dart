import 'package:get/get.dart';
import '../../../data/repositories/matchmaking_repository.dart';
import '../../../data/models/fighter_model.dart';
import '../../../data/models/fight_card_model.dart';

class MatchmakingController extends GetxController {
  final MatchmakingRepository _repository = MatchmakingRepository();
  
  var fighters = <Fighter>[].obs;
  var fightCards = <FightCard>[].obs;
  var suggestions = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedWeightClass = ''.obs;
  
  // ...existing methods...
}
