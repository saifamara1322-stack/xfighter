import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/repositories/tournament_repository.dart';
import 'package:xfighter/data/repositories/user_repository.dart';
import 'package:xfighter/data/repositories/verification_repository.dart';
import 'package:xfighter/data/models/user_model.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_StatisticsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('PLATFORM STATISTICS',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        return RefreshIndicator(
          color: const Color(0xFFE31837),
          backgroundColor: const Color(0xFF0D0D1A),
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StatCard(
                title: 'TOTAL USERS',
                value: controller.totalUsers.value.toString(),
                icon: Icons.people,
                color: const Color(0xFFE31837),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'FIGHTERS',
                      value: controller.totalFighters.value.toString(),
                      icon: Icons.sports_mma,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'COACHES',
                      value: controller.totalCoaches.value.toString(),
                      icon: Icons.sports,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'TOURNAMENTS',
                      value: controller.totalEvents.value.toString(),
                      icon: Icons.event_note,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'PENDING VERIF.',
                      value: controller.pendingVerifications.value.toString(),
                      icon: Icons.verified_user_outlined,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1))),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatisticsController extends GetxController {
  final _users = UserRepository();
  final _tournaments = TournamentRepository();
  final _verification = VerificationRepository();

  final totalUsers = 0.obs;
  final totalFighters = 0.obs;
  final totalCoaches = 0.obs;
  final totalEvents = 0.obs;
  final pendingVerifications = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _users.getAllUsers(),
        _tournaments.getTournaments(page: 0, size: 1),
        _verification.getPendingUsers(page: 0, size: 1),
      ]);

      final users = results[0] as List<User>;
      final tournaments = results[1] as dynamic;
      final pending = results[2] as dynamic;

      totalUsers.value = users.length;
      totalFighters.value =
          users.where((u) => u.role == UserRole.FIGHTER).length;
      totalCoaches.value =
          users.where((u) => u.role == UserRole.COACH).length;
      totalEvents.value = tournaments.totalElements as int;
      pendingVerifications.value = pending.totalElements as int;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
