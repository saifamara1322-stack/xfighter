import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../../../data/models/enhanced_event_registration.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/country_model.dart';

class FighterRegistrationsView extends StatelessWidget {
  FighterRegistrationsView({super.key});
  
  final RegistrationController _controller = Get.put(RegistrationController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('My Registrations'),
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.fighterRegistrations.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }
        
        if (_controller.fighterRegistrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_mma, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No registrations yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Register for tournaments to see them here',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          color: const Color(0xFFE31837),
          onRefresh: () async {
            await _controller.loadFighterRegistrations();
            await _controller.refreshCountries();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.fighterRegistrations.length,
            itemBuilder: (context, index) {
              final registration = _controller.fighterRegistrations[index];
              return FighterRegistrationCard(
                registration: registration,
                controller: _controller,
              );
            },
          ),
        );
      }),
    );
  }
}

class FighterRegistrationCard extends StatelessWidget {
  final EnhancedEventRegistration registration;
  final RegistrationController controller;
  
  const FighterRegistrationCard({
    super.key,
    required this.registration,
    required this.controller,
  });
  
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
  
  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'approvedbycoach': return 'Coach Approved';
      case 'approvedbyorganizer': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'approvedbyorganizer':
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'cancelled':
        color = Colors.orange;
        icon = Icons.remove_circle;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplay(status),
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tournament = registration.tournament;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
          child: const Icon(Icons.sports_mma, color: Color(0xFFE31837)),
        ),
        title: Text(
          tournament?.name ?? 'Tournament ${registration.eventId}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tournament != null)
              Text(
                '${tournament.city}, ${tournament.venue}',
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 4),
            _buildStatusChip(registration.status.name),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament details
                if (tournament != null) ...[
                  const Text('Tournament Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 8),
                  _infoRow('Level:', _getLevelDisplay(tournament.level)),
                  _infoRow('Country:', _getCountryName(tournament.countryId)),
                  _infoRow('Start:', _formatDate(tournament.startDate)),
                  _infoRow('End:', _formatDate(tournament.endDate)),
                  _infoRow('Registration closes:', _formatDate(tournament.registrationCloseAt)),
                  const SizedBox(height: 16),
                ],
                
                // Registration details
                const Text('Registration Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 8),
                _infoRow('Status:', registration.status.name.toUpperCase()),
                _infoRow('Weight Class:', registration.weightClass),
                _infoRow('Registered:', _formatDate(registration.registeredAt)),
                
                if (registration.notes != null) ...[
                  const SizedBox(height: 8),
                  _infoRow('Notes:', registration.notes!),
                ],
                
                const SizedBox(height: 16),
                
                // Cancel button (only if pending)
                if (registration.status == RegistrationStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCancelDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel Registration'),
                    ),
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
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
  
  void _showCancelDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Cancel Registration', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to cancel this registration?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              controller.cancelRegistration(registration.id);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}