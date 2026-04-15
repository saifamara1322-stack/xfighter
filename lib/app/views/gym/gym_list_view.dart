import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/gym_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/gym_model.dart';
import 'gym_detail_view.dart';
import 'gym_registration_dialog.dart';

class GymListView extends StatelessWidget {
  final GymController _gymController = Get.put(GymController());
  final AuthController _authController = Get.find<AuthController>();
  
  GymListView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text(
            'GYMS & CLUBS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFE31837),
            labelColor: Color(0xFFE31837),
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: [
              Tab(text: 'ACTIVE GYMS'),
              Tab(text: 'MY GYMS'),
            ],
          ),
          actions: [
            if (_authController.isCoach() || _authController.isOrganizer())
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.add_business, color: Color(0xFFE31837)),
                  onPressed: () => _showRegistrationDialog(),
                  tooltip: 'Register Gym',
                ),
              ),
          ],
        ),
        body: Obx(() {
          if (_gymController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
              ),
            );
          }
          
          return TabBarView(
            children: [
              _buildActiveGymsTab(),
              _buildMyGymsTab(),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildActiveGymsTab() {
    if (_gymController.activeGyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        title: 'NO ACTIVE GYMS',
        subtitle: 'Gyms will appear here after verification',
        showButton: false,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gymController.activeGyms.length,
      itemBuilder: (context, index) {
        final gym = _gymController.activeGyms[index];
        return _buildGymCard(gym);
      },
    );
  }
  
  Widget _buildMyGymsTab() {
    if (_gymController.userGyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.add_business_outlined,
        title: 'NO GYMS REGISTERED',
        subtitle: 'Register your first gym to get started',
        showButton: true,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gymController.userGyms.length,
      itemBuilder: (context, index) {
        final gym = _gymController.userGyms[index];
        return _buildGymCard(gym, showStatus: true);
      },
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showButton,
  }) {
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
            child: Icon(
              icon,
              size: 60,
              color: const Color(0xFFE31837),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
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
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showRegistrationDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'REGISTER GYM',
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
        ],
      ),
    );
  }
  
  Widget _buildGymCard(Gym gym, {bool showStatus = false}) {
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
      child: InkWell(
        onTap: () => Get.to(() => GymDetailView(gymId: gym.id)),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gym Icon - Octagon style
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE31837).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.business,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Gym Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // City row
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: const Color(0xFFE31837),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          gym.city,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Fighters and Phone row
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${gym.fighters.length} FIGHTERS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.phone,
                          size: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          gym.phone,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    if (showStatus) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: gym.statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: gym.statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(gym.status as String),
                              size: 10,
                              color: gym.statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              gym.statusDisplay.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: gym.statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // VS Arrow
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE31837).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFE31837),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  void _showRegistrationDialog() {
    Get.dialog(
      GymRegistrationDialog(),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }
}