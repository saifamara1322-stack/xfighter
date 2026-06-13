import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/repositories/fighter_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class FighterRecordView extends StatelessWidget {
  const FighterRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_FighterProfileController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFE31837)),
        );
      }

      if (controller.profileMissing.value) {
        return _createProfileScreen(controller);
      }

      final fighter = controller.fighter.value;
      if (fighter == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load fighter profile',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: controller.load,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE31837)),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFFE31837),
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeader(fighter: fighter),
            const SizedBox(height: 24),
            if (controller.coach.value != null) ...[
              const _SectionTitle('ASSIGNED COACH'),
              const SizedBox(height: 8),
              _CoachTile(coach: controller.coach.value!),
              const SizedBox(height: 24),
            ],
            const _SectionTitle('MY CLUBS'),
            const SizedBox(height: 8),
            if (controller.clubs.isEmpty)
              Column(
                children: [
                  const Text('Not affiliated with any club yet.',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showJoinClubBottomSheet(controller),
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text('Find & Join a Club',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31837),
                    ),
                  ),
                ],
              )
            else
              ...controller.clubs.map((c) => _ClubTile(club: c)),
          ],
        ),
      );
    });
  }

  Widget _createProfileScreen(_FighterProfileController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sports_mma, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text('No fighter profile yet',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Complete your fighter profile to get started',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Get.toNamed('/create-fighter-profile')?.then((_) {
                controller.load();
              });
            },
            child: const Text('Create Profile', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _showJoinClubBottomSheet(_FighterProfileController controller) async {
      await controller.fetchAllClubs();   // was fetchActiveClubs

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Join a Club',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white24),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingClubs.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE31837)),
                  );
                }
                if (controller.availableClubs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No active clubs available',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.availableClubs.length,
                  itemBuilder: (context, index) {
                    final club = controller.availableClubs[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2196F3),
                        child: Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text(club.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(club.city ?? '',
                          style: const TextStyle(color: Colors.white54)),
                      trailing: ElevatedButton(
                        onPressed: controller.isRequesting.value
                            ? null
                            : () => controller.requestJoinClub(club.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE31837),
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Join', style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FighterProfileController extends GetxController {
  final _repo = FighterRepository();
  final ClubRepository _clubRepo = ClubRepository();
  final fighter = Rx<Fighter?>(null);
  final clubs = <Club>[].obs;
  final coach = Rx<Coach?>(null);
  final isLoading = false.obs;
  final profileMissing = false.obs;

  // For available clubs bottom sheet
  final availableClubs = <Club>[].obs;
  final isLoadingClubs = false.obs;
  final isRequesting = false.obs; 

Future<void> fetchAllClubs() async {
  isLoadingClubs.value = true;
  try {
    availableClubs.value = await _repo.getAllClubs();
  } catch (e) {
    Get.snackbar('Error', 'Could not load clubs: $e');
  } finally {
    isLoadingClubs.value = false;
  }
}

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final userId = Get.find<AuthController>().currentUser.value?.id;
    if (userId == null) return;

    isLoading.value = true;
    profileMissing.value = false;

    try {
      final fighterProfile = await _repo.getFighterByUserId(userId);
      fighter.value = fighterProfile;
      final fighterId = fighterProfile.id;

      // Clubs: always return a list (empty if none)
      List<Club> clubsList = [];
      try {
        clubsList = await _repo.getFighterClubs(fighterId);
      } catch (e) {
        print('⚠️ Clubs error: $e');
      }
      clubs.value = clubsList;

      // Coach: may be null if not assigned
      Coach? coachObj;
      try {
        coachObj = await _repo.getFighterCoach(fighterId);
      } catch (e) {
        print('⚠️ Coach error: $e');
      }
      coach.value = coachObj;
    } catch (e, stack) {
      print('❌ Load error: $e\n$stack');
      if (e.toString().contains('Fighter not found')) {
        profileMissing.value = true;
      } else {
        Get.snackbar('Error', 'Failed to load: ${e.toString()}');
      }
      fighter.value = null;
      clubs.clear();
      coach.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch available clubs when bottom sheet opens
  Future<void> fetchAvailableClubs() async {
    isLoadingClubs.value = true;
    try {
      availableClubs.value = (await _clubRepo.getAllClubs()) as List<Club>;
    } catch (e) {
      Get.snackbar('Error', 'Could not load clubs: $e');
      availableClubs.clear();
    } finally {
      isLoadingClubs.value = false;
    }
  }

  Future<void> requestJoinClub(String clubId) async {
    isRequesting.value = true;
    try {
      await _repo.requestJoinClub(clubId);
      Get.snackbar('Success', 'Join request sent to club');
      // Optional: close bottom sheet and reload clubs after a delay
      Get.back();
      await Future.delayed(const Duration(seconds: 1));
      await load(); // refresh the fighter's clubs list
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request: $e');
    } finally {
      isRequesting.value = false;
    }
  }
}

// ----- UI Components (unchanged) -----

class _ProfileHeader extends StatelessWidget {
  final Fighter fighter;
  const _ProfileHeader({required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE31837).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
            child: const Icon(Icons.sports_mma, size: 40, color: Color(0xFFE31837)),
          ),
          const SizedBox(height: 16),
          Text(fighter.fullName,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(fighter.email,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox('CATEGORY', fighter.category ?? '—'),
              _statBox('WEIGHT', fighter.weight != null ? '${fighter.weight} kg' : '—'),
              _statBox('CLUB', fighter.club?.name ?? '—'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1));
  }
}

class _CoachTile extends StatelessWidget {
  final Coach coach;
  const _CoachTile({required this.coach});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF141424),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE31837),
          child: Icon(Icons.sports, color: Colors.white),
        ),
        title: Text(coach.fullName,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(coach.specialty ?? 'Coach',
            style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final Club club;
  const _ClubTile({required this.club});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF141424),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2196F3),
          child: Icon(Icons.business, color: Colors.white),
        ),
        title: Text(club.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(club.city ?? '',
            style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}