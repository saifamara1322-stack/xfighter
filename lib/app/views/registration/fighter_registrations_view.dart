import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/app/repositories/api_client.dart';
import '../../controllers/registration_controller.dart';
import '../../models/event_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class FighterRegistrationsView extends StatelessWidget {
  FighterRegistrationsView({super.key});
  
  final RegistrationController _controller = Get.put(RegistrationController());
  final RegistrationTabController _tabController = Get.put(RegistrationTabController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'MY REGISTRATIONS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => TabBar(
            controller: _tabController.tabController,
            indicatorColor: const Color(0xFFE31837),
            indicatorWeight: 3,
            labelColor: const Color(0xFFE31837),
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: [
              Tab(text: 'PENDING (${_controller.pendingCount.value})'),
              Tab(text: 'APPROVED (${_controller.approvedCount.value})'),
            ],
          )),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
                ),
                SizedBox(height: 16),
                Text(
                  'LOADING REGISTRATIONS...',
                  style: TextStyle(color: Colors.white54, letterSpacing: 1),
                ),
              ],
            ),
          );
        }
        
        if (_controller.hasError.value) {
          return _buildErrorState();
        }
        
        if (_controller.fighterRegistrations.isEmpty) {
          return _buildEmptyState();
        }
        
        return TabBarView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildRegistrationsList(RegistrationStatus.pending),
            _buildRegistrationsList(RegistrationStatus.approvedByOrganizer),
          ],
        );
      }),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE31837).withOpacity(0.1),
                  const Color(0xFFB8102E).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 50,
              color: Color(0xFFE31837),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'LOADING ERROR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
              ),
            ),
            child: Text(
              _controller.errorMessage.value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _controller.loadFighterRegistrations(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text(
              'RETRY',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFE31837).withOpacity(0.1),
                  const Color(0xFFB8102E).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.event_busy,
              size: 60,
              color: Color(0xFFE31837),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NO REGISTRATIONS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFE31837).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE31837).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'You have no event registrations yet',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/events'),
            icon: const Icon(Icons.explore, size: 18),
            label: const Text(
              'DISCOVER EVENTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegistrationsList(RegistrationStatus status) {
    final registrations = _controller.getRegistrationsByStatus(status);
    
    if (registrations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (status == RegistrationStatus.pending 
                    ? Colors.orange 
                    : Colors.green).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                status == RegistrationStatus.pending 
                    ? Icons.access_time 
                    : Icons.check_circle_outline,
                size: 40,
                color: status == RegistrationStatus.pending ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              status == RegistrationStatus.pending 
                  ? 'NO PENDING REGISTRATIONS'
                  : 'NO APPROVED REGISTRATIONS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async => _controller.loadFighterRegistrations(),
      color: const Color(0xFFE31837),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: registrations.length,
        itemBuilder: (context, index) {
          final registration = registrations[index];
          return _buildRegistrationCard(registration);
        },
      ),
    );
  }
  
  Widget _buildRegistrationCard(EnhancedEventRegistration registration) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<Event?>(
        future: _controller.getEventDetails(registration.eventId),
        builder: (context, snapshot) {
          final event = snapshot.data;
          
          return InkWell(
            onTap: () => _navigateToEventDetails(registration.eventId),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Icon - Octagon style
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getStatusGradient(registration.status),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(registration.status).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getStatusIcon(registration.status),
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Registration Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event?.name?.toUpperCase() ?? 'EVENT #${registration.eventId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(Icons.category, 'Weight: ${registration.weightClass}'),
                            const SizedBox(height: 6),
                            _buildInfoRow(Icons.calendar_today, 'Registered: ${_formatDate(registration.registeredAt)}'),
                            if (event?.date != null) ...[
                              const SizedBox(height: 6),
                              _buildInfoRow(Icons.event, 'Date: ${_formatDate(event!.date!)}'),
                            ],
                            if (event?.location != null) ...[
                              const SizedBox(height: 6),
                              _buildInfoRow(Icons.location_on, event!.location!),
                            ],
                          ],
                        ),
                      ),
                      
                      // Status Chip
                      _buildStatusChip(registration),
                    ],
                  ),
                  
                  if (registration.status == RegistrationStatus.rejected && registration.rejectionReason != null)
                    _buildRejectionReason(registration.rejectionReason!),
                  
                  if (registration.status == RegistrationStatus.pending)
                    _buildCancelButton(registration),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<Color> _getStatusGradient(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return [Colors.orange, Colors.deepOrange];
      case RegistrationStatus.approvedByOrganizer:
        return [Colors.green, Colors.lightGreen];
      case RegistrationStatus.rejected:
        return [const Color(0xFFE31837), const Color(0xFFB8102E)];
      default:
        return [const Color(0xFFE31837), const Color(0xFFB8102E)];
    }
  }
  
  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return Colors.orange;
      case RegistrationStatus.approvedByOrganizer:
        return Colors.green;
      case RegistrationStatus.rejected:
        return const Color(0xFFE31837);
      default:
        return const Color(0xFFE31837);
    }
  }
  
  IconData _getStatusIcon(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return Icons.access_time;
      case RegistrationStatus.approvedByOrganizer:
        return Icons.check_circle;
      case RegistrationStatus.rejected:
        return Icons.cancel;
      default:
        return Icons.sports_mma;
    }
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFFE31837)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusChip(EnhancedEventRegistration registration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: registration.statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: registration.statusColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            registration.status == RegistrationStatus.pending 
                ? Icons.access_time 
                : (registration.status == RegistrationStatus.approvedByOrganizer 
                    ? Icons.check_circle 
                    : Icons.cancel),
            size: 10,
            color: registration.statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            registration.statusDisplay.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: registration.statusColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRejectionReason(String reason) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE31837).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE31837).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Color(0xFFE31837),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REJECTION REASON:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: const Color(0xFFE31837),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCancelButton(EnhancedEventRegistration registration) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showCancelConfirmationDialog(registration),
        icon: const Icon(Icons.cancel_outlined, size: 16),
        label: const Text(
          'CANCEL REGISTRATION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE31837),
          side: const BorderSide(color: Color(0xFFE31837)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
  
  void _showCancelConfirmationDialog(EnhancedEventRegistration registration) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFE31837).withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE31837).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Color(0xFFE31837),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CANCEL REGISTRATION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this registration? This action cannot be undone.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('NO'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        final success = await _controller.cancelRegistration(registration.id);
                        if (success) {
                          Get.snackbar(
                            'SUCCESS',
                            'Registration cancelled successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        } else {
                          Get.snackbar(
                            'ERROR',
                            'Unable to cancel registration',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFE31837),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE31837),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('YES, CANCEL'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  
  void _navigateToEventDetails(String eventId) {
    Get.toNamed('/events/$eventId', arguments: {'eventId': eventId});
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}