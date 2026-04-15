import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';

class CreateEventView extends StatelessWidget {
  final EventController _eventController = Get.find<EventController>();
  
  CreateEventView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF0A0A0A),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE31837).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 750),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with VS style
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    color: const Color(0xFFE31837),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CREATE EVENT',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Organize a new fight night',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Event Name
              _buildFormTextField(
                controller: _eventController.nameController,
                label: 'EVENT NAME',
                hint: 'Ex: UFW Tunisia Championship',
                icon: Icons.event,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              // Description
              _buildFormTextField(
                controller: _eventController.descriptionController,
                label: 'DESCRIPTION',
                hint: 'Describe the event...',
                icon: Icons.description,
                maxLines: 3,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              // Location
              _buildFormTextField(
                controller: _eventController.locationController,
                label: 'LOCATION',
                hint: 'Ex: Salle Omnisport de Radès',
                icon: Icons.location_on,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              // City
              _buildFormTextField(
                controller: _eventController.cityController,
                label: 'CITY',
                hint: 'Ex: Tunis, Sousse, Sfax...',
                icon: Icons.location_city,
                isRequired: true,
              ),
              const SizedBox(height: 16),
              
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: _buildFormTextField(
                      controller: _eventController.dateController,
                      label: 'DATE',
                      hint: 'YYYY-MM-DD',
                      icon: Icons.calendar_today,
                      isRequired: true,
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFE31837),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1A1A1A),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          _eventController.dateController.text = date.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormTextField(
                      controller: _eventController.timeController,
                      label: 'TIME',
                      hint: 'HH:MM',
                      icon: Icons.access_time,
                      isRequired: true,
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: Get.context!,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFE31837),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFF1A1A1A),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          _eventController.timeController.text = time.format(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Disciplines
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.sports_mma,
                          size: 18,
                          color: Color(0xFFE31837),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DISCIPLINES *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['MMA', 'Kickboxing', 'Boxing', 'BJJ', 'Muay Thai'].map((discipline) {
                        return _buildSelectionChip(
                          label: discipline,
                          isSelected: _eventController.selectedDisciplines.contains(discipline),
                          onSelected: () => _eventController.toggleDiscipline(discipline),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Weight Classes
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          size: 18,
                          color: Color(0xFFE31837),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'WEIGHT CLASSES *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Flyweight', 'Bantamweight', 'Featherweight',
                        'Lightweight', 'Welterweight', 'Middleweight',
                        'Light Heavyweight', 'Heavyweight'
                      ].map((weightClass) {
                        return _buildSelectionChip(
                          label: weightClass,
                          isSelected: _eventController.selectedWeightClasses.contains(weightClass),
                          onSelected: () => _eventController.toggleWeightClass(weightClass),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Ticket Price and Max Fighters
              Row(
                children: [
                  Expanded(
                    child: _buildFormTextField(
                      controller: _eventController.ticketPriceController,
                      label: 'TICKET PRICE (TND)',
                      hint: '0',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFormTextField(
                      controller: _eventController.maxFightersController,
                      label: 'MAX FIGHTERS',
                      hint: 'Optional',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                      isRequired: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              
              // Buttons - VS Style
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: _eventController.isCreating.value
                          ? null
                          : _eventController.createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _eventController.isCreating.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'CREATE EVENT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.5),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE31837)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE31837), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
  
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFFE31837),
      checkmarkColor: Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: isSelected 
              ? const Color(0xFFE31837) 
              : Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}