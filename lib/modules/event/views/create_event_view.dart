import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key});

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final EventController _eventController = Get.find<EventController>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _cityController;
  late final TextEditingController _venueController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _registrationOpenController;
  late final TextEditingController _registrationCloseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
    _venueController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _registrationOpenController = TextEditingController();
    _registrationCloseController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _registrationOpenController.dispose();
    _registrationCloseController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE31837)),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    TextEditingController controller,
    String label,
    IconData icon, {
    required bool includeTime,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _selectDateTime(context, controller, includeTime: includeTime),
        child: IgnorePointer(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Icon(icon, color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF14213D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller, {required bool includeTime}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && includeTime) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final dateTime = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day,
          pickedTime.hour, pickedTime.minute,
        );
        controller.text = dateTime.toIso8601String();
      }
    } else if (pickedDate != null) {
      controller.text = pickedDate.toIso8601String();
    }
  }

  void _createTournament() {
    _eventController.createEventWithValues(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      city: _cityController.text.trim(),
      venue: _venueController.text.trim(),
      startDate: DateTime.parse(_startDateController.text.trim()),
      endDate: DateTime.parse(_endDateController.text.trim()),
      registrationOpenAt: DateTime.parse(_registrationOpenController.text.trim()),
      registrationCloseAt: DateTime.parse(_registrationCloseController.text.trim()),
      level: _eventController.selectedLevel.value,
      countryId: _eventController.selectedCountryId.value!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Create Tournament'),
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
      ),
      body: Obx(() {
        if (_eventController.isLoadingCountries.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Basic Information', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Tournament Name *', Icons.emoji_events),
              _buildTextField(_descriptionController, 'Description', Icons.description),

              const SizedBox(height: 8),
              const Text('Location', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(_cityController, 'City *', Icons.location_city),
              _buildTextField(_venueController, 'Venue *', Icons.location_on),

              const SizedBox(height: 8),
              const Text('Schedule', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDateField(_startDateController, 'Start Date *', Icons.calendar_today, includeTime: false),
              _buildDateField(_endDateController, 'End Date *', Icons.calendar_today, includeTime: false),
              _buildDateField(_registrationOpenController, 'Registration Open *', Icons.lock_open, includeTime: true),
              _buildDateField(_registrationCloseController, 'Registration Close *', Icons.lock, includeTime: true),

              const SizedBox(height: 8),
              const Text('Tournament Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Level dropdown
              _buildDropdown(
                value: _eventController.selectedLevel.value,
                items: const ['LOCAL', 'REGIONAL', 'NATIONAL', 'INTERNATIONAL'],
                label: 'Level *',
                icon: Icons.trending_up,
                onChanged: (val) => _eventController.selectedLevel.value = val!,
              ),

              // Country dropdown
              _buildCountryDropdown(),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE31837),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _eventController.isCreating.value ? null : _createTournament,
                  child: _eventController.isCreating.value
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('CREATE TOURNAMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14213D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label, style: const TextStyle(color: Colors.white70)),
          dropdownColor: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Obx(() {
      if (_eventController.countries.isEmpty) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF14213D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('No countries available', style: TextStyle(color: Colors.white70)),
        );
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF14213D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _eventController.selectedCountryId.value,
            hint: const Text('Select Country *', style: TextStyle(color: Colors.white70)),
            dropdownColor: const Color(0xFF1A1A2E),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
            isExpanded: true,
            style: const TextStyle(color: Colors.white),
            onChanged: (String? newValue) {
              _eventController.selectedCountryId.value = newValue;
            },
            items: _eventController.countries.map<DropdownMenuItem<String>>((country) {
              return DropdownMenuItem<String>(
                value: country.id,
                child: Text(country.name),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}