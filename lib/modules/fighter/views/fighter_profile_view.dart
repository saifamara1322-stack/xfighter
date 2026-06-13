import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/fighter_controller.dart';
import '../../../data/models/fighter_model.dart';
import '../../../core/routes/app_router.dart';

class FighterProfileView extends StatelessWidget {
  final FighterController controller = Get.put(FighterController());

  FighterProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('FIGHTER PROFILE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshProfile(),
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
                const Text('No profile found',
                    style: TextStyle(color: Colors.white54, fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31837)),
                  onPressed: () {
                    Get.toNamed('/create-fighter-profile')?.then((_) {
                      controller.refreshProfile();
                    });
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

// --- Profile Header (same as in FighterRecordView, but can be reused) ---
class _ProfileHeader extends StatelessWidget {
  final Fighter fighter;
  const _ProfileHeader({required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE31837), Color(0xFFB8102E)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withAlpha(51),
            child: Text(
              fighter.fullName.isNotEmpty ? fighter.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(fighter.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(fighter.email,
              style: TextStyle(color: Colors.white.withAlpha(179), fontSize: 14)),
          if (fighter.category != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(fighter.category!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}

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
          _Row('Category', fighter.category ?? '—'),
          _Row('Weight', fighter.weight != null ? '${fighter.weight!.toStringAsFixed(1)} kg' : '—'),
          _Row('Birth Date', fighter.birthDate ?? '—'),
          _Row('Age', fighter.age != null ? '${fighter.age} years' : '—'),
          _Row('Gender', fighter.gender ?? '—'),
        ],
      ),
    );
  }
}

// --- ClubSection and CoachSection same as before, using controller.currentClubs and currentCoach ---
// (copy from the previous version, unchanged)

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
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
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
            child: Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
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

  void _browseClubs() => Get.toNamed(AppRouter.clubs);

  void _openClubById(String clubId) {
    Get.toNamed(AppRouter.clubDetail.replaceAll(':id', clubId));
  }

  void _showJoinClubDialog() {
    final clubEmailCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Request Club Membership',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: clubEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Club email',
            labelStyle: TextStyle(color: Colors.white54),
            hintText: 'club@example.com',
          ),
        ),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              final email = clubEmailCtrl.text.trim();
              if (email.isEmpty) return;
              Get.back();
              controller.requestJoinClubByEmail(email);
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fighter = controller.currentFighter.value;
      final club = fighter?.club;
      final clubs = controller.currentClubs;

      return _Card(
        title: 'CLUB',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (club != null) ...[
              _Row('Name', club.name),
              _Row('City', club.city),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE31837),
                  side: const BorderSide(color: Color(0xFFE31837)),
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('View Club Profile'),
                onPressed: () => _openClubById(club.id),
              ),
            ] else if (clubs.isNotEmpty) ...[
              ...clubs.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(c.city ?? '—',
                          style: const TextStyle(color: Colors.white54)),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Color(0xFFE31837)),
                        onPressed: () => _openClubById(c.id),
                      ),
                    ),
                  )),
            ] else ...[
              const Text('No club assigned',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31837)),
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Find & Join a Club',
                      style: TextStyle(color: Colors.white)),
                  onPressed: _browseClubs,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Join by Club Email'),
                  onPressed: _showJoinClubDialog,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Section – now uses dedicated controller.currentCoach
// ─────────────────────────────────────────────────────────────────────────────

class _CoachSection extends StatelessWidget {
  final FighterController controller;
  const _CoachSection({required this.controller});

  void _showRequestCoachDialog() {
    final coachEmailCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF0D0D1A),
        title: const Text('Request Coach',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: coachEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Coach email',
            labelStyle: TextStyle(color: Colors.white54),
            hintText: 'coach@example.com',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837)),
            onPressed: () {
              final email = coachEmailCtrl.text.trim();
              if (email.isEmpty) return;
              Get.back();
              controller.requestCoachByEmail(email);
            },
            child: const Text('Send Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Use the coach fetched from the dedicated endpoint
      final coach = controller.currentCoach.value;

      return _Card(
        title: 'COACH',
        child: coach == null
            ? Column(
                children: [
                  const Text('No coach assigned',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837)),
                    onPressed: _showRequestCoachDialog,
                    child: const Text('Request Coach',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            : Column(
                children: [
                  _Row('Name', coach.fullName),
                  if (coach.specialty != null)
                    _Row('Specialty', coach.specialty!),
                ],
              ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
