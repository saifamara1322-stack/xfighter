import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/event_model.dart';
import 'event_detail_view.dart';
import 'create_event_view.dart';

class EventListView extends StatelessWidget {
  final EventController _eventController = Get.put(EventController());
  final AuthController _authController = Get.find<AuthController>();
  
  EventListView({super.key});
  // ...existing code...
}
