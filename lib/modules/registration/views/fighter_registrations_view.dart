import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/api_client.dart';
import '../controllers/registration_controller.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/user_model.dart';

class FighterRegistrationsView extends StatelessWidget {
  FighterRegistrationsView({super.key});
  
  final RegistrationController _controller = Get.find<RegistrationController>();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value && _controller.fighterRegistrations.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      
      if (_controller.fighterRegistrations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_mma,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No fighter registrations',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fighters who register for events will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () => _controller.fetchFighterRegistrations(),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
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
    });
  }
}

class FighterRegistrationCard extends StatelessWidget {
  final Registration registration;
  final RegistrationController controller;
  
  const FighterRegistrationCard({
    super.key,
    required this.registration,
    required this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.sports_mma, color: Colors.blue),
        ),
        title: Text(
          registration.event?.name ?? 'Event Registration',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (registration.user != null)
              Text('Fighter: ${registration.user!.fullName}'),
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
                // Event Details
                if (registration.event != null) ...[
                  const Text(
                    'Event Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date:', _formatDate(registration.event!.date)),
                  _buildInfoRow('Location:', registration.event!.location),
                  _buildInfoRow('Venue:', registration.event!.venue),
                  const Divider(),
                ],
                
                // Fighter Details
                if (registration.user != null) ...[
                  const Text(
                    'Fighter Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Name:', registration.user!.fullName),
                  _buildInfoRow('Email:', registration.user!.email),
                  _buildInfoRow('Role:', registration.user!.roleDisplayName),
                  const Divider(),
                ],
                
                // Registration Details
                const Text(
                  'Registration Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Registered:', _formatDate(registration.registeredAt)),
                _buildInfoRow('Status:', registration.status.toUpperCase()),
                
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    if (registration.status == 'pending')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApprovalDialog(context, registration, 'approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    if (registration.status == 'pending') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showApprovalDialog(context, registration, 'rejected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                    ],
                    if (registration.status == 'approved')
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showApprovalDialog(context, registration, 'cancelled'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text('Cancel Registration'),
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
  
  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  void _showApprovalDialog(BuildContext context, Registration registration, String newStatus) {
    final String action = newStatus == 'approved' ? 'approve' : 
                         newStatus == 'rejected' ? 'reject' : 'cancel';
    final String message = newStatus == 'approved' 
        ? 'Are you sure you want to approve this registration?'
        : newStatus == 'rejected'
        ? 'Are you sure you want to reject this registration?'
        : 'Are you sure you want to cancel this registration?';
    
    Get.dialog(
      AlertDialog(
        title: Text('${action.toUpperCase()} Registration'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              controller.updateRegistrationStatus(registration.id, newStatus);
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'approved' ? Colors.green : 
                              newStatus == 'rejected' ? Colors.red : Colors.orange,
            ),
            child: Text('Yes, $action'),
          ),
        ],
      ),
    );
  }
}