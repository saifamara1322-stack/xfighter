import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/coach_model.dart';
import 'package:xfighter/data/repositories/club_repository.dart';

class ClubCoachesView extends StatelessWidget {
  final bool embedded;
  const ClubCoachesView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_ClubCoachesController());
    final body = Obx(() {
      if (c.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
      }
      if (c.coaches.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sports, size: 72, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No coaches yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Add Coach by UUID'),
              onPressed: () => _showInviteSheet(context, c),
            ),
          ]),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFE31837),
        backgroundColor: const Color(0xFF0D0D1A),
        onRefresh: c.load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: c.coaches.length,
          itemBuilder: (_, i) => _CoachCard(coach: c.coaches[i]),
        ),
      );
    });

    if (embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('ADD COACH BY UUID'),
                onPressed: () => _showInviteSheet(context, c),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('CLUB COACHES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFFE31837)),
            tooltip: 'Add Coach by UUID',
            onPressed: () => _showInviteSheet(context, c),
          ),
        ],
      ),
      body: body,
    );
  }
}

void _showInviteSheet(BuildContext context, _ClubCoachesController controller) {
  final uuidController = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0D0D1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Icon(Icons.fingerprint, color: Color(0xFFE31837)),
        SizedBox(width: 8),
        Text('Add Coach by UUID', style: TextStyle(color: Colors.white)),
      ]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: uuidController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Coach UUID',
              hintText: 'e.g., 123e4567-e89b-12d3-a456-426614174000',
              labelStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.fingerprint, color: Color(0xFFE31837), size: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE31837), width: 2),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFFE31837)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ask the coach for their unique user ID (UUID) found in their profile.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
          onPressed: () {
            final uuid = uuidController.text.trim();
            if (uuid.isEmpty) return;
            Get.back();
            controller.inviteCoachByUuid(uuid);
          },
          child: const Text('ADD COACH'),
        ),
      ],
    ),
  );
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
            child: Text(
              coach.fullName.isNotEmpty ? coach.fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coach.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(coach.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                if (coach.specialty != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_outlined, size: 12, color: Color(0xFF2196F3)),
                        const SizedBox(width: 4),
                        Text(coach.specialty!, style: const TextStyle(color: Color(0xFF2196F3), fontSize: 11)),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                // Show a tiny hint of the UUID for reference
                GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: coach.id));
                    Get.snackbar(
                      'Copied',
                      'Coach UUID copied',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint, size: 12, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          coach.id,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Copy UUID button
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF2196F3)),
            tooltip: 'Copy coach UUID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: coach.id));
              Get.snackbar(
                'Copied',
                'Coach UUID copied to clipboard',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('COACH', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _ClubCoachesController extends GetxController {
  final _repo = ClubRepository();
  final coaches = <Coach>[].obs;
  final isLoading = false.obs;
  String? _clubId;

  @override
  void onInit() {
    super.onInit();
    _initClubId();
  }

  Future<void> _initClubId() async {
    _clubId = await _repo.resolveMyClubId();
    if (_clubId != null) load();
  }

  Future<void> load() async {
    if (_clubId == null) return;
    isLoading.value = true;
    try {
      coaches.value = await _repo.getClubCoaches(_clubId!);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // New method: directly invite by UUID (no email resolution)
  Future<void> inviteCoachByUuid(String coachUuid) async {
    try {
      await _repo.inviteCoach(coachUuid);
      Get.snackbar(
        'Invitation Sent',
        'Coach has been added to your club',
        backgroundColor: const Color(0xFF1B5E20),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      await load(); // Refresh list
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}