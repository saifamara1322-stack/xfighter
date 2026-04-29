import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/api_client.dart';
import '../controllers/matchmaking_controller.dart';
import '../../../data/models/fight_card_model.dart';

class FightCardBuilderView extends StatelessWidget {
  final String eventId;
  final String eventName;
  final MatchmakingController _controller = Get.put(MatchmakingController());
  
  FightCardBuilderView({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fight Card — $eventName')),
      body: const Center(child: Text('Fight card builder — coming soon')),
    );
  }
}
