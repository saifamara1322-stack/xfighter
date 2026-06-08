import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';

class FighterRecordView extends StatelessWidget {
  const FighterRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
       body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsHeader(user?.fullName ?? 'Fighter'),
            const SizedBox(height: 24),
            const Text(
              'MATCH HISTORY',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            _buildMatchHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(String name) {
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
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pro MMA | Welterweight', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox('WINS', '12', Colors.green),
              _statBox('LOSSES', '3', Colors.red),
              _statBox('DRAWS', '1', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildMatchHistory() {
    // Simulated match history
    final matches = [
      {'opponent': 'John Doe', 'result': 'WIN', 'method': 'TKO (Punches)', 'event': 'X-Fighter 42', 'date': '2026-05-10'},
      {'opponent': 'Ali Hassan', 'result': 'LOSS', 'method': 'Submission (Rear-Naked Choke)', 'event': 'X-Fighter 39', 'date': '2026-02-15'},
      {'opponent': 'Samir Trabelsi', 'result': 'WIN', 'method': 'Decision (Unanimous)', 'event': 'X-Fighter 35', 'date': '2025-11-20'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isWin = match['result'] == 'WIN';
        final color = isWin ? Colors.green : Colors.red;

        return Card(
          color: const Color(0xFF141424),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(match['result']!, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('vs ${match['opponent']}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(match['method']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${match['event']} • ${match['date']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
