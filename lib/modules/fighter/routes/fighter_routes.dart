import 'package:get/get.dart';
import 'package:xfighter/modules/fighter/views/fighter_profile_view.dart';
import 'package:xfighter/modules/fighter/bindings/fighter_binding.dart';

class FighterRoutes {
  static const String fighterProfile = '/fighter-profile';
  
  static List<GetPage> pages = [
    GetPage(
      name: fighterProfile,
      page: () => const FighterProfileView(),
      binding: FighterBinding(),
    ),
  ];
}