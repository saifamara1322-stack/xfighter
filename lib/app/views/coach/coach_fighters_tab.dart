import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/coach_controller.dart';
import '../../models/fighter_model.dart';

class CoachFightersTab extends StatelessWidget {
  final CoachController _coachController = Get.find<CoachController>();
  
  CoachFightersTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_coachController.coachFighters.isEmpty) {
        return _buildEmptyState();
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _coachController.coachFighters.length,
        itemBuilder: (context, index) {
          final fighter = _coachController.coachFighters[index];
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
            'NO FIGHTERS IN YOUR CORNER',
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
              'You haven\'t been assigned any fighters yet',
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to fighter details
              // Get.toNamed('/fighter-details', arguments: fighter);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top row: Avatar, Name, Status
                  Row(
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
                              '#${fighter.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: Color(0xFFE31837),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fighter.name ?? 'Unnamed Fighter',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Stats Row - FighterRec style
                            Row(
                              children: [
                                _buildStatBadge(
                                  fighter.weightClass,
                                  Icons.fitness_center,
                                ),
                                const SizedBox(width: 8),
                                _buildStatBadge(
                                  fighter.winLossRecord,
                                  Icons.emoji_events,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Status Badge - VS style
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              size: 14,
                              color: fighter.verified ? Colors.green : const Color(0xFFE31837),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              fighter.verified ? 'VERIFIED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 10,
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
                  
                  const SizedBox(height: 16),
                  
                  // VS Separator
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFE31837).withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Additional Stats Row - FighterRec fighter card style
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('FIGHTS', _getFightCount(fighter)),
                      _buildMiniStat('WINS', _getWinsFromRecord(fighter.winLossRecord)),
                      _buildMiniStat('LOSSES', _getLossesFromRecord(fighter.winLossRecord)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
                          Icon(
                            icon,
                            size: 12,
                            color: const Color(0xFFE31837),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
  }
  
  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
  
  String _getFightCount(Fighter fighter) {
    // Parse W-L-D record to get total fights
    final record = fighter.winLossRecord;
    if (record.isEmpty) return '0';
    
    final parts = record.split('-');
    if (parts.length >= 2) {
      final wins = int.tryParse(parts[0]) ?? 0;
      final losses = int.tryParse(parts[1]) ?? 0;
      final draws = parts.length >= 3 ? (int.tryParse(parts[2]) ?? 0) : 0;
      return '${wins + losses + draws}';
    }
    return '0';
  }
  
  String _getWinsFromRecord(String record) {
    if (record.isEmpty) return '0';
    final parts = record.split('-');
    return parts.isNotEmpty ? parts[0] : '0';
  }
  
  String _getLossesFromRecord(String record) {
    if (record.isEmpty) return '0';
    final parts = record.split('-');
    return parts.length >= 2 ? parts[1] : '0';
  }
}

// Extension to add name property to Fighter model if it doesn't exist
extension FighterExtension on Fighter {
  String get name {
    // Assuming fighter has firstName and lastName properties
    // Adjust this based on your actual Fighter model structure
    if (this is _NamedFighter) {
      return (this as _NamedFighter).fullName;
    }
    return 'Fighter ${id ?? ''}';
  }
}

// Helper class - remove this if your Fighter model already has name properties
class _NamedFighter {
  String get fullName => '';
}