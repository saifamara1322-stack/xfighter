// gym_model.dart — backwards-compat shim
// All real models live in club_model.dart.
// Re-export Club as Gym and ClubStatus as GymStatus so old views still compile.

export 'package:xfighter/data/models/club_model.dart'
    show Club, ClubStatus, PagedClubResponse;

import 'package:xfighter/data/models/club_model.dart';

// Aliases for code that still uses the old names
typedef Gym = Club;
typedef GymStatus = ClubStatus;