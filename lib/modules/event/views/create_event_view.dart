import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';

class CreateEventView extends StatelessWidget {
  final EventController _eventController = Get.find<EventController>();

  CreateEventView({super.key});

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF14213D),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(
                  _eventController.nameController, 'Event name', Icons.event),
              _buildTextField(_eventController.descriptionController,
                  'Description', Icons.description),
              _buildTextField(_eventController.locationController,
                  'Location', Icons.location_on),
              _buildTextField(_eventController.cityController, 'Venue',
                  Icons.location_city),
              _buildTextField(_eventController.dateController, 'Date',
                  Icons.calendar_today,
                  keyboardType: TextInputType.datetime),
              _buildTextField(_eventController.timeController, 'Time',
                  Icons.access_time,
                  keyboardType: TextInputType.datetime),
              _buildTextField(_eventController.ticketPriceController,
                  'Ticket price', Icons.attach_money,
                  keyboardType: TextInputType.number),
              _buildTextField(_eventController.maxFightersController,
                  'Max fighters', Icons.group,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _eventController.isCreating.value
                      ? null
                      : _eventController.createEvent,
                  child: _eventController.isCreating.value
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Text('Create event'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
