import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/matchmaking/controllers/matchmaking_controller.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/fight_card_model.dart';

class FightCardBuilderView extends StatelessWidget {
  final String eventId;
  final String weightClass;

  const FightCardBuilderView({
    super.key,
    required this.eventId,
    required this.weightClass,
  });

  @override
  Widget build(BuildContext context) {
    // Unique tag in case we open multiple builders
    final tag = '${eventId}_$weightClass';
    final c = Get.put(MatchmakingController(eventId: eventId, weightClass: weightClass), tag: tag);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text('BUILD CARD: ${weightClass.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        return Row(
          children: [
            // Left Panel: Eligible Fighters Pool
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151520),
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.white.withOpacity(0.02),
                      child: Text('ELIGIBLE FIGHTERS (${c.fighters.length})', 
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    ),
                    Expanded(
                      child: c.fighters.isEmpty
                          ? const Center(child: Text('No more fighters', style: TextStyle(color: Colors.white38)))
                          : ListView.builder(
                              itemCount: c.fighters.length,
                              itemBuilder: (_, i) => _FighterDragItem(fighter: c.fighters[i]),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Panel: Match Cards
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white.withOpacity(0.02),
                    child: Text('MATCHUPS (${c.fightCards.length})', 
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  ),
                  Expanded(
                    child: c.fightCards.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sports_mma, size: 64, color: Colors.white12),
                                SizedBox(height: 16),
                                Text('Drag fighters here to build matchups', style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: c.fightCards.length,
                            itemBuilder: (_, i) => _MatchCard(card: c.fightCards[i], controller: c),
                          ),
                  ),
                  
                  // Drop Zone for creating a new match
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: DragTarget<Fighter>(
                      onWillAccept: (data) => data != null,
                      onAccept: (f1) {
                        _showOpponentSelector(context, f1, c.fighters.where((f) => f.id != f1.id).toList(), c);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty ? const Color(0xFFE31837).withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: candidateData.isNotEmpty ? const Color(0xFFE31837) : Colors.white.withOpacity(0.2),
                              style: BorderStyle.solid,
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_circle_outline, color: Colors.white54),
                                SizedBox(width: 8),
                                Text('DRAG FIGHTER HERE TO CREATE MATCH', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showOpponentSelector(BuildContext context, Fighter f1, List<Fighter> opponents, MatchmakingController c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT OPPONENT FOR ${f1.fullName.toUpperCase()}', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            if (opponents.isEmpty)
              const Text('No eligible opponents available.', style: TextStyle(color: Colors.white54))
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: opponents.length,
                  itemBuilder: (_, i) {
                    final op = opponents[i];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: const Color(0xFFE31837).withOpacity(0.2), child: const Icon(Icons.person, color: Color(0xFFE31837))),
                      title: Text(op.fullName, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${op.weight ?? '?'} kg', style: const TextStyle(color: Colors.white54)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
                        onPressed: () {
                          Get.back();
                          c.createMatch(f1, op);
                        },
                        child: const Text('PAIR'),
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

class _FighterDragItem extends StatelessWidget {
  final Fighter fighter;
  const _FighterDragItem({required this.fighter});

  @override
  Widget build(BuildContext context) {
    return Draggable<Fighter>(
      data: fighter,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE31837), borderRadius: BorderRadius.circular(8)),
          child: Text(fighter.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildTile()),
      child: _buildTile(),
    );
  }

  Widget _buildTile() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.1), child: const Icon(Icons.person, color: Colors.white)),
        title: Text(fighter.fullName, style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(fighter.club?.name ?? 'No Club', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: const Icon(Icons.drag_indicator, color: Colors.white24),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final FightCard card;
  final MatchmakingController controller;

  const _MatchCard({required this.card, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BOUT #${card.order}', style: const TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 12)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                onPressed: () => controller.removeMatch(card),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 28, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(card.fighter1Id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis), // Real names need API expansion
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 24, fontStyle: FontStyle.italic)),
              ),
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 28, backgroundColor: Colors.redAccent, child: Icon(Icons.person, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(card.fighter2Id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
