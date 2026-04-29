import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/fighter_controller.dart';
import '../../../data/models/fighter_model.dart';

class FighterProfileView extends StatelessWidget {
  final FighterController controller = Get.put(FighterController());

  FighterProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'FIGHTER PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final id = controller.currentFighter.value?.id;
              if (id != null) controller.loadFighterProfile(id);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
            ),
          );
        }

        final fighter = controller.currentFighter.value;
        if (fighter == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_mma, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                const Text(
                  'No profile found',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31837)),
                  onPressed: () {
                    // TODO: link to profile creation screen
                    Get.snackbar('Info', 'Profile creation coming soon',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                  child: const Text('Create Profile',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(fighter: fighter),
              const SizedBox(height: 20),
              _InfoSection(fighter: fighter),
              const SizedBox(height: 20),
              _ClubSection(controller: controller),
              const SizedBox(height: 20),
              _CoachSection(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Fighter fighter;
  const _ProfileHeader({required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE31837), Color(0xFFB8102E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withAlpha(51),
            child: Text(
              fighter.fullName.isNotEmpty
                  ? fighter.fullName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fighter.fullName,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            fighter.email,
            style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14),
          ),
          if (fighter.category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                fighter.category!,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Section
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final Fighter fighter;
  const _InfoSection({required this.fighter});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'FIGHTER DETAILS',
      child: Column(
        children: [
          _Row('Email', fighter.email),
          _Row('Full Name', fighter.fullName),
          _Row('Phone', fighter.phoneNumber ?? '—'),
          _Row('Category / Weight Class', fighter.category ?? '—'),
          _Row(
              'Weight',
              fighter.weight != null
                  ? '${fighter.weight!.toStringAsFixed(1)} kg'
                  : '—'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Club Section
// ─────────────────────────────────────────────────────────────────────────────

class _ClubSection extends StatelessWidget {
  final FighterController controller;
  const _ClubSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fighter = controller.currentFighter.value;
      final club = fighter?.club;

      return _Card(
        title: 'CLUB',
        child: club == null
            ? Column(
                children: [
                  const Text('No club assigned',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837)),
                    onPressed: () => controller.requestJoinClub(''),
                    child: const Text('Request Club Membership',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row('Name', club.name),
                  _Row('City', club.city),
                ],
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Section
// ─────────────────────────────────────────────────────────────────────────────

class _CoachSection extends StatelessWidget {
  final FighterController controller;
  const _CoachSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fighter = controller.currentFighter.value;
      final coach = fighter?.coach;
      final currentCoach = controller.currentCoach.value;

      final coachName = coach?.fullName ?? currentCoach?.fullName;
      final coachSpecialty =
          coach?.specialty ?? currentCoach?.specialty;

      return _Card(
        title: 'COACH',
        child: coachName == null
            ? Column(
                children: [
                  const Text('No coach assigned',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837)),
                    onPressed: () => controller.requestCoach(''),
                    child: const Text('Request Coach',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            : Column(
                children: [
                  _Row('Name', coachName),
                  if (coachSpecialty != null)
                    _Row('Specialty', coachSpecialty),
                ],
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE31837),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}