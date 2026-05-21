import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import '../../../data/models/enhanced_event_registration.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/country_model.dart';

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
        onRefresh: () async {
          await _controller.loadFighterRegistrations();
          await _controller.refreshCountries();
        },
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
  final EnhancedEventRegistration registration;
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
          'Event: ${registration.eventId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fighter ID: ${registration.fighterId}'),
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
                if (registration.notes != null) ...[
                  const Text('Notes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(registration.notes!),
                  const Divider(),
                ],
                
                // Registration Details
                const Text(
                  'Registration Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Registered:', _formatDate(registration.registeredAt)),
                _buildInfoRow('Status:', registration.status.name.toUpperCase()),
                _buildInfoRow('Weight Class:', registration.weightClass),
                
                const SizedBox(height: 16),
                
                // Country Selection Section
                _buildCountrySection(),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    if (registration.status == RegistrationStatus.pending)
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
                    if (registration.status == RegistrationStatus.pending) ...[
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fighter Country',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        
        // Show loading state
        if (controller.isLoadingCountries.value) 
          _buildLoadingCountryWidget(),
        
        // Show error state
        if (controller.hasCountriesError.value)
          _buildErrorCountryWidget(),
        
        // Show country dropdown when countries are loaded
        if (!controller.isLoadingCountries.value && 
            !controller.hasCountriesError.value &&
            controller.countries.isNotEmpty)
          _buildCountryDropdown(),
        
        // Show empty state
        if (!controller.isLoadingCountries.value && 
            !controller.hasCountriesError.value &&
            controller.countries.isEmpty)
          _buildEmptyCountryWidget(),
      ],
    );
  }
  
  Widget _buildCountryDropdown() {
    return Obx(() {
      // Find the currently selected country (if any)
      Country? currentSelectedCountry;
      if (controller.selectedCountry.value != null) {
        currentSelectedCountry = controller.selectedCountry.value;
      }
      
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Country>(
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select fighter\'s country',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            value: currentSelectedCountry,
            items: controller.countries.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Country Flag
                      if (country.flagUrl != null && 
                          country.flagUrl!.isNotEmpty && 
                          country.flagUrl != 'string')
                        _buildFlagImage(country.flagUrl!),
                      if (country.flagUrl != null && 
                          country.flagUrl!.isNotEmpty && 
                          country.flagUrl != 'string')
                        const SizedBox(width: 12),
                      
                      // Country Name
                      Expanded(
                        child: Text(
                          country.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      
                      // Country Code
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          country.code,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (Country? country) {
              controller.setSelectedCountry(country);
              _showSnackbar('Country Selected', '${country?.name} selected for fighter');
            },
          ),
        ),
      );
    });
  }
  
  Widget _buildFlagImage(String flagUrl) {
    return Container(
      width: 30,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagUrl,
          width: 30,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.flag,
                size: 16,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildLoadingCountryWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading countries...'),
        ],
      ),
    );
  }
  
  Widget _buildErrorCountryWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
            color: Colors.red.shade50,
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.countriesErrorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => controller.refreshCountries(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyCountryWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('No countries available'),
          TextButton(
            onPressed: () => controller.refreshCountries(),
            child: const Text('Refresh'),
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
  
  void _showApprovalDialog(BuildContext context, EnhancedEventRegistration registration, String newStatus) {
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
  
  void _showSnackbar(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
          borderRadius: 10,
        );
      }
    });
  }
}