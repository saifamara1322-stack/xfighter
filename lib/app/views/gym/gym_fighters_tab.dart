import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gym_controller.dart';
import '../../models/fighter_model.dart';

class GymFightersTab extends StatelessWidget {
  final String gymId;
  
  const GymFightersTab({super.key, required this.gymId});
  
  @override
  Widget build(BuildContext context) {
    final GymController _gymController = Get.find<GymController>();
    
    return Obx(() {
      if (_gymController.gymFighters.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gymController.gymFighters.length,
        itemBuilder: (context, index) {
          final fighter = _gymController.gymFighters[index];
          return _buildFighterCard(fighter);
        },
      );
    });
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE31837).withOpacity(0.1),
                  const Color(0xFFB8102E).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 60,
              color: Color(0xFFE31837),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO FIGHTERS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'No fighters are affiliated with this gym yet',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFighterCard(Fighter fighter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Fighter Avatar - Octagon style
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE31837).withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_mma,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Fighter Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FIGHTER #${fighter.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Weight Class Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE31837).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE31837).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          fighter.weightClass.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Color(0xFFE31837),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Record Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 10,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              fighter.winLossRecord,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Verification Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: fighter.verified
                    ? LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.2),
                          Colors.green.withOpacity(0.1),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFFE31837).withOpacity(0.2),
                          const Color(0xFFB8102E).withOpacity(0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: fighter.verified
                      ? Colors.green.withOpacity(0.5)
                      : const Color(0xFFE31837).withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fighter.verified ? Icons.verified : Icons.pending,
                    size: 12,
                    color: fighter.verified ? Colors.green : const Color(0xFFE31837),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fighter.verified ? 'VERIFIED' : 'PENDING',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: fighter.verified ? Colors.green : const Color(0xFFE31837),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}