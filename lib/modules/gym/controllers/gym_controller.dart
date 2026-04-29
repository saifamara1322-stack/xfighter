// gym_controller.dart — backwards-compat shim.
// All logic has moved to ClubController (club_controller.dart).
// This file re-exports ClubController as GymController so legacy routes still compile.
export 'package:xfighter/modules/gym/controllers/club_controller.dart'
    show ClubController;

// Alias so existing code that does `GymController controller` still resolves.
import 'package:xfighter/modules/gym/controllers/club_controller.dart';
typedef GymController = ClubController;