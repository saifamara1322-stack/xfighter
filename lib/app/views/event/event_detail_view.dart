import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/app/models/auth_model.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/registration_controller.dart';
import '../../models/event_model.dart';
import '../../repositories/api_client.dart';

class EventDetailView extends StatelessWidget {
  final String eventId;
  final EventController _eventController = Get.find<EventController>();
  final AuthController _authController = Get.find<AuthController>();
  final RegistrationController _registrationController = Get.find<RegistrationController>();
  
  EventDetailView({super.key, required this.eventId});
  
  @override
  Widget build(BuildContext context) {
    _eventController.selectEvent(eventId);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Obx(() => Text(
          _eventController.selectedEvent.value?.name.toUpperCase() ?? 'EVENT DETAILS',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 16,
          ),
        )),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_authController.isAdmin())
            Obx(() {
              final event = _eventController.selectedEvent.value;
              if (event != null && event.status == EventStatus.pending) {
                return Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      onPressed: () => _eventController.updateEventStatus(eventId, 'approved'),
                      tooltip: 'Approve',
                    ),
                    _buildActionButton(
                      icon: Icons.cancel,
                      color: const Color(0xFFE31837),
                      onPressed: () => _eventController.updateEventStatus(eventId, 'cancelled'),
                      tooltip: 'Reject',
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),
        ],
      ),
      body: Obx(() {
        if (_eventController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
            ),
          );
        }
        
        final event = _eventController.selectedEvent.value;
        if (event == null) {
          return const Center(
            child: Text(
              'EVENT NOT FOUND',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEventHeader(event),
              const SizedBox(height: 16),
              _buildEventInfo(event),
              const SizedBox(height: 16),
              if (_authController.isFighter()) _buildRegistrationSection(event),
              _buildRegistrationsSection(),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
  
  Widget _buildEventHeader(Event event) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE31837), Color(0xFFB8102E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE31837).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  event.formattedDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  event.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(event.statusDisplay),
                    size: 12,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.statusDisplay.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventInfo(Event event) {
    return Container(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'EVENT INFORMATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow('DESCRIPTION', event.description),
            _buildInfoRow('CITY', event.city),
            _buildInfoRow('TICKET PRICE', '${event.ticketPrice} TND'),
            _buildInfoRow('DISCIPLINES', event.disciplines.join(' • ')),
            _buildInfoRow('WEIGHT CLASSES', event.weightClasses.join(' • ')),
            if (event.maxFighters > 0)
              _buildInfoRow('MAX FIGHTERS', event.maxFighters.toString()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRegistrationSection(Event event) {
    final registration = _eventController.eventRegistrations.firstWhereOrNull(
      (r) => r.fighterId == _authController.currentUser.value?.id
    );
    
    // Already registered
    if (registration != null) {
      return _buildAlreadyRegisteredCard(registration);
    }
    
    // Event not open for registration
    if (event.status != EventStatus.approved && event.status != EventStatus.upcoming) {
      return const SizedBox();
    }
    
    return Column(
      children: [
        // Eligibility result card
        Obx(() {
          if (_registrationController.eligibilityResult.value != null) {
            return _buildEligibilityCard();
          }
          return const SizedBox();
        }),
        // Registration form
        _buildRegistrationForm(event),
      ],
    );
  }
  
  Widget _buildRegistrationForm(Event event) {
    String? selectedWeightClass;
    
    return Container(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'REGISTRATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            const Text(
              'SELECT WEIGHT CLASS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Choose weight class',
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE31837)),
                items: event.weightClasses.map((wc) {
                  return DropdownMenuItem(
                    value: wc, 
                    child: Text(wc, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedWeightClass = value;
                  if (value != null) {
                    _registrationController.checkEligibility(event.id, value);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _registrationController.isLoading.value || selectedWeightClass == null
                    ? null
                    : () => _registrationController.registerForEvent(event.id, selectedWeightClass!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                child: _registrationController.isLoading.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('REGISTER FOR EVENT'),
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEligibilityCard() {
    final result = _registrationController.eligibilityResult.value!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isEligible 
            ? Colors.green.withOpacity(0.1) 
            : const Color(0xFFE31837).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isEligible 
              ? Colors.green.withOpacity(0.3) 
              : const Color(0xFFE31837).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isEligible ? Icons.check_circle : Icons.warning,
                color: result.isEligible ? Colors.green : const Color(0xFFE31837),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                result.isEligible ? 'ELIGIBLE' : 'NOT ELIGIBLE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 13,
                  color: result.isEligible ? Colors.green : const Color(0xFFE31837),
                ),
              ),
            ],
          ),
          if (!result.isEligible && result.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(left: 30, top: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE31837),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
  
  Widget _buildAlreadyRegisteredCard(EventRegistration registration) {
    String statusText = 'PENDING';
    Color statusColor = Colors.orange;
    IconData icon = Icons.access_time;
    
    if (registration.status == 'approved') {
      statusText = 'CONFIRMED';
      statusColor = Colors.green;
      icon = Icons.check_circle;
    } else if (registration.status == 'rejected') {
      statusText = 'REJECTED';
      statusColor = const Color(0xFFE31837);
      icon = Icons.cancel;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.15),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REGISTRATION $statusText',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 13,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weight Class: ${registration.weightClass}',
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegistrationsSection() {
    if (_eventController.eventRegistrations.isEmpty) {
      return const SizedBox();
    }
    
    // Show different views based on user role
    final user = _authController.currentUser.value;
    final bool isOrganizer = user?.role == UserRole.organizer || user?.role == UserRole.admin;
    final bool isCoach = user?.role == UserRole.coach;
    
    return Container(
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'REGISTRATIONS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE31837).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_eventController.eventRegistrations.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE31837),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            ..._eventController.eventRegistrations.map((reg) => 
              _buildRegistrationTile(reg, isOrganizer: isOrganizer, isCoach: isCoach)
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRegistrationTile(
    EventRegistration reg, {
    required bool isOrganizer,
    required bool isCoach,
  }) {
    return FutureBuilder(
      future: _getFighterName(reg.fighterId),
      builder: (context, snapshot) {
        final fighterName = snapshot.data ?? 'Fighter #${reg.fighterId}';
        
        Color statusColor;
        String statusText;
        
        if (reg.status == 'approved') {
          statusColor = Colors.green;
          statusText = 'CONFIRMED';
        } else if (reg.status == 'rejected') {
          statusColor = const Color(0xFFE31837);
          statusText = 'REJECTED';
        } else {
          statusColor = Colors.orange;
          statusText = 'PENDING';
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fighterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weight: ${reg.weightClass}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<String> _getFighterName(String fighterId) async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('users/$fighterId');
      if (response != null && response['firstName'] != null) {
        return '${response['firstName']} ${response['lastName']}';
      }
      return 'Fighter #$fighterId';
    } catch (e) {
      return 'Fighter #$fighterId';
    }
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}