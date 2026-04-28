import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/gym/controllers/gym_controller.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/models/gym_model.dart';

class GymListView extends StatelessWidget {
  const GymListView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final GymController controller = Get.find<GymController>();
    final AuthController authController = Get.find<AuthController>();
    
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
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
              ),
            );
          }
          
          return TabBarView(
            children: [
              _buildActiveGymsTab(controller),
              _buildMyGymsTab(controller, authController),
            ],
          );
        }),
      ),
    );
  }
  
  Widget _buildActiveGymsTab(GymController controller) {
    final activeGyms = controller.gyms.where((g) => g.status == GymStatus.active).toList();
    
    if (activeGyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.business_outlined,
        title: 'NO ACTIVE GYMS',
        subtitle: 'Gyms will appear here after verification',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGyms.length,
      itemBuilder: (context, index) {
        final gym = activeGyms[index];
        return _buildGymCard(gym);
      },
    );
  }
  
  Widget _buildMyGymsTab(GymController controller, AuthController authController) {
    if (controller.userGyms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.add_business_outlined,
        title: 'NO GYMS REGISTERED',
        subtitle: 'Register your first gym to get started',
        showButton: authController.currentUser.value?.role.name == 'coach' ||
                   authController.currentUser.value?.role.name == 'organizer',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.userGyms.length,
      itemBuilder: (context, index) {
        final gym = controller.userGyms[index];
        return _buildGymCard(gym, showStatus: true);
      },
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
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
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/gym/${gym.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
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
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Color(0xFFE31837),
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
                      ],
                    ),
                    if (showStatus) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(gym.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          gym.statusDisplayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: _getStatusColor(gym.status),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFE31837),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(GymStatus status) {
    switch (status) {
      case GymStatus.active:
        return Colors.green;
      case GymStatus.pending:
        return Colors.orange;
      case GymStatus.suspended:
        return Colors.red;
      case GymStatus.rejected:
        return Colors.red;
    }
  }
}