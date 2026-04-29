import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coach_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/coach_model.dart';
import 'coach_fighters_tab.dart';

class CoachProfileView extends StatelessWidget {
  final CoachController _coachController = Get.put(CoachController());
  final AuthController _authController = Get.find<AuthController>();
  
  CoachProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Profile')),
      body: const Center(child: Text('Coach profile — coming soon')),
    );
  }
}
