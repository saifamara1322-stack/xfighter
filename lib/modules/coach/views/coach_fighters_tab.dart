import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coach_controller.dart';
import '../../../data/models/fighter_model.dart';

class CoachFightersTab extends StatelessWidget {
  final CoachController _coachController = Get.find<CoachController>();
  
  CoachFightersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Coach fighters — coming soon'));
  }
}
