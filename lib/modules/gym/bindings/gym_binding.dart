import 'package:get/get.dart';
import 'package:xfighter/modules/gym/controllers/gym_controller.dart';

class GymBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GymController>(() => GymController());
  }
}