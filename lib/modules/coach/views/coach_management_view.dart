import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coach_controller.dart';
import '../../../data/models/coach_model.dart';

class CoachManagementView extends StatelessWidget {
  final CoachController _coachController = Get.put(CoachController());
  
  CoachManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Management')),
      body: const Center(child: Text('Coach management — coming soon')),
    );
  }
}
