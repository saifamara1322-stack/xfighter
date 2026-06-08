import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../../../data/models/enhanced_event_registration.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/country_model.dart'; // for country name resolution

class OrganizerRegistrationsView extends StatelessWidget {
  OrganizerRegistrationsView({super.key});
  
  final RegistrationController _controller = Get.put(RegistrationController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Event Registrations', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.eventRegistrations.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }
        
        if (_controller.eventRegistrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.app_registration, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text('No pending registrations', style: TextStyle(fontSize: 18, color: Colors.grey[500])),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          color: const Color(0xFFE31837),
          onRefresh: () => _controller.loadOrganizerRegistrations(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.eventRegistrations.length,
            itemBuilder: (context, index) {
              final registration = _controller.eventRegistrations[index];
              return _RegistrationCard(registration: registration, controller: _controller);
            },
          ),
        );
      }),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final EnhancedEventRegistration registration;
  final RegistrationController controller;
  
  const _RegistrationCard({required this.registration, required this.controller});
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _getLevelDisplay(String level) {
    switch (level.toUpperCase()) {
      case 'LOCAL': return 'Local';
      case 'REGIONAL': return 'Regional';
      case 'NATIONAL': return 'National';
      case 'INTERNATIONAL': return 'International';
      default: return level;
    }
  }
  
  String _getCountryName(String countryId) {
    final country = controller.countries.firstWhereOrNull((c) => c.id == countryId);
    return country?.name ?? countryId;
  }
  
  Widget _buildStatusChip(RegistrationStatus status) {
    Color color;
    String text;
    switch (status) {
      case RegistrationStatus.approvedByOrganizer:
        color = Colors.green;
        text = 'APPROVED';
        break;
      case RegistrationStatus.rejected:
        color = Colors.red;
        text = 'REJECTED';
        break;
      case RegistrationStatus.approvedByCoach:
        color = Colors.blue;
        text = 'NEEDS YOUR APPROVAL';
        break;
      default:
        color = Colors.orange;
        text = 'PENDING';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tournament = registration.tournament;
    
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
          child: const Icon(Icons.person, color: Color(0xFFE31837)),
        ),
        title: Text(
          registration.fighterProfile?.fullName ?? 'Fighter: ${registration.fighterId}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament?.name ?? 'Tournament ${registration.eventId}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (tournament != null)
              Text(
                '${tournament.city}, ${tournament.venue}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            const SizedBox(height: 4),
            _buildStatusChip(registration.status),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament details (if available)
                if (tournament != null) ...[
                  const Text('Tournament Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  _infoRow('Level:', _getLevelDisplay(tournament.level)),
                  _infoRow('Country:', _getCountryName(tournament.countryId)),
                  _infoRow('Start Date:', _formatDate(tournament.startDate)),
                  _infoRow('End Date:', _formatDate(tournament.endDate)),
                  _infoRow('Registration Closes:', _formatDate(tournament.registrationCloseAt)),
                  const SizedBox(height: 16),
                ],
                
                // Fighter details
                const Text('Fighter Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                _infoRow('Registered:', _formatDate(registration.registeredAt)),
                _infoRow('Weight Class:', registration.weightClass),
                if (registration.notes != null) _infoRow('Notes:', registration.notes!),
                
                const SizedBox(height: 16),
                
                // Action buttons (only if registration needs organizer approval)
                if (registration.status == RegistrationStatus.approvedByCoach)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApprovalDialog(context, 'approved'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApprovalDialog(context, 'rejected'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Reject', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white54))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
  
  void _showApprovalDialog(BuildContext context, String newStatus) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('${newStatus.toUpperCase()} Registration', style: const TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to proceed?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              if (newStatus == 'approved') {
                controller.approveByOrganizer(registration.id);
              } else {
                controller.rejectRegistration(registration.id, 'Rejected by organizer');
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}