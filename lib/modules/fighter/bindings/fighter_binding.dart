import 'package:get/get.dart';
import 'package:xfighter/modules/fighter/controllers/fighter_controller.dart';

class FighterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FighterController>(() => FighterController());
  }
}