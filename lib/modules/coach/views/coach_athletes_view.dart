import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/repositories/coach_repository.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class CoachAthletesView extends StatelessWidget {
  const CoachAthletesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_CoachAthletesController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('My Athletes'),
        backgroundColor: const Color(0xFF0D0D1A),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        if (controller.athletes.isEmpty) {
          return const Center(
            child: Text(
              'No athletes assigned yet.\nUse POST /coach/request-train-fighter to request a fighter.',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFE31837),
          onRefresh: controller.load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.athletes.length,
            itemBuilder: (context, index) {
              final athlete = controller.athletes[index];
              return Card(
                color: const Color(0xFF141424),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFFE31837).withOpacity(0.2),
                    child: const Icon(Icons.sports_mma,
                        color: Color(0xFFE31837)),
                  ),
                  title: Text(athlete.fullName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    [
                      if (athlete.category != null) athlete.category,
                      if (athlete.weight != null) '${athlete.weight} kg',
                      athlete.email,
                    ].whereType<String>().join(' • '),
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _CoachAthletesController extends GetxController {
  final _repo = CoachRepository();
  final athletes = <Fighter>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final coachId = Get.find<AuthController>().currentUser.value?.id;
    if (coachId == null) return;

    isLoading.value = true;
    try {
      athletes.value = await _repo.getCoachFighters(coachId);
    } catch (e) {
      athletes.clear();
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
