import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/repositories/registration_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/models/user_model.dart';

class ClubInvitationsView extends StatelessWidget {
  final bool embedded;
  const ClubInvitationsView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_ClubInvitationsController());
    final tabBar = TabBar(
      labelColor: const Color(0xFFE31837),
      unselectedLabelColor: Colors.white54,
      indicatorColor: const Color(0xFFE31837),
      tabs: [
        Tab(child: Obx(() => Text('FIGHTERS (${c.fighterRequests.length})', style: const TextStyle(fontSize: 11)))),
        Tab(child: Obx(() => Text('COACHES (${c.coachRequests.length})', style: const TextStyle(fontSize: 11)))),
      ],
    );
    final tabView = TabBarView(children: [
      _RequestList(
        requests: c.fighterRequests,
        isLoading: c.isLoading,
        icon: Icons.sports_mma,
        emptyText: 'No pending fighter requests',
        onAccept: (id) => c.respondFighter(id, 'ACCEPT'),
        onReject: (id) => c.respondFighter(id, 'REJECT'),
        onRefresh: c.load,
      ),
      _RequestList(
        requests: c.coachRequests,
        isLoading: c.isLoading,
        icon: Icons.sports,
        emptyText: 'No pending coach requests',
        onAccept: (id) => c.respondCoach(id, 'ACCEPT'),
        onReject: (id) => c.respondCoach(id, 'REJECT'),
        onRefresh: c.load,
      ),
    ]);

    if (embedded) {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Material(color: const Color(0xFF0D0D1A), child: tabBar),
            Expanded(child: tabView),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text('INVITATIONS & REQUESTS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 15)),
          backgroundColor: const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: tabBar,
        ),
        body: tabView,
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final RxList<Map<String, dynamic>> requests;
  final RxBool isLoading;
  final IconData icon;
  final String emptyText;
  final void Function(String) onAccept;
  final void Function(String) onReject;
  final Future<void> Function() onRefresh;

  const _RequestList({
    required this.requests,
    required this.isLoading,
    required this.icon,
    required this.emptyText,
    required this.onAccept,
    required this.onReject,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
      }
      if (requests.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(emptyText, style: const TextStyle(color: Colors.white54, fontSize: 15)),
          ]),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFE31837),
        backgroundColor: const Color(0xFF0D0D1A),
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (_, i) {
            final req = requests[i];
            final id = req['id']?.toString() ?? '';
            final name = req['fullName'] ?? req['name'] ?? 'Unknown';
            final email = req['email'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE31837).withOpacity(0.15),
                  child: Icon(icon, color: const Color(0xFFE31837), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  if (email.isNotEmpty) Text(email.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ])),
                Column(children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    onPressed: () => onAccept(id),
                    tooltip: 'Accept',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Color(0xFFE31837), size: 28),
                    onPressed: () => onReject(id),
                    tooltip: 'Reject',
                  ),
                ]),
              ]),
            );
          },
        ),
      );
    });
  }
}

class _ClubInvitationsController extends GetxController {
  final _clubRepo = ClubRepository();
  final fighterRequests = <Map<String, dynamic>>[].obs;
  final coachRequests = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load() async {
    isLoading.value = true;
    try {
      // The API doesn't have a direct "pending requests" list endpoint.
      // Load the club's fighters and coaches to show joined members.
      // Pending requests come in via push/real-time. For now show current members info.
      fighterRequests.value = [];
      coachRequests.value = [];
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondFighter(String membershipId, String action) async {
    try {
      await _clubRepo.respondToFighterRequest(membershipId, action);
      fighterRequests.removeWhere((r) => r['id'] == membershipId);
      Get.snackbar(action == 'ACCEPT' ? 'Accepted' : 'Rejected',
          'Fighter request ${action.toLowerCase()}ed',
          backgroundColor: action == 'ACCEPT' ? const Color(0xFF1B5E20) : Colors.grey[800],
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> respondCoach(String membershipId, String action) async {
    try {
      await _clubRepo.respondToCoachRequest(membershipId, action);
      coachRequests.removeWhere((r) => r['id'] == membershipId);
      Get.snackbar(action == 'ACCEPT' ? 'Accepted' : 'Rejected',
          'Coach request ${action.toLowerCase()}ed',
          backgroundColor: action == 'ACCEPT' ? const Color(0xFF1B5E20) : Colors.grey[800],
          colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
