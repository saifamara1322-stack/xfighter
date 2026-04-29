import 'package:get/get.dart';
import 'package:xfighter/modules/gym/views/gym_list_view.dart';
import 'package:xfighter/modules/gym/bindings/gym_binding.dart';

class GymRoutes {
  static const String gymList = '/gyms';
  static const String gymDetail = '/gym/:id';

  static List<GetPage> pages = [
    GetPage(
      name: gymList,
      page: () => const GymListView(),
      binding: GymBinding(),
    ),
    // Club detail view is not yet implemented; routing to list as fallback
    GetPage(
      name: gymDetail,
      page: () => const GymListView(),
      binding: GymBinding(),
    ),
  ];
}