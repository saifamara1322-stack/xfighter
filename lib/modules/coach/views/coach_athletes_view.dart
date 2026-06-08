import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class CoachAthletesView extends StatelessWidget {
  const CoachAthletesView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    // Simulate athletes data since CoachController might not have the athletes endpoint fully integrated yet.
    final athletes = [
      {'name': 'Ali Hassan', 'weight': '77kg', 'record': '12-3-1', 'status': 'Active'},
      {'name': 'Samir Trabelsi', 'weight': '65kg', 'record': '8-1-0', 'status': 'Injured'},
      {'name': 'Yassine Mejri', 'weight': '84kg', 'record': '5-0-0', 'status': 'Active'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('My Athletes'),
        backgroundColor: const Color(0xFF0D0D1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFFE31837)),
            onPressed: () {
              Get.snackbar('Invite Athlete', 'Invitation functionality coming soon.', colorText: Colors.white);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: Color(0xFFE31837), size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Athletes', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('${athletes.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ROSTER',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: athletes.length,
                itemBuilder: (context, index) {
                  final athlete = athletes[index];
                  final isActive = athlete['status'] == 'Active';

                  return Card(
                    color: const Color(0xFF141424),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
                        child: const Icon(Icons.sports_mma, color: Color(0xFFE31837)),
                      ),
                      title: Text(athlete['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${athlete['weight']} • Record: ${athlete['record']}', style: const TextStyle(color: Colors.white54)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          athlete['status']!,
                          style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
