import 'package:get/get.dart';
import 'package:xfighter/modules/organizer/controllers/organizer_controller.dart';

class OrganizerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrganizerController>(() => OrganizerController());
  }
}
