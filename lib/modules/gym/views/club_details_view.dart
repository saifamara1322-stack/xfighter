import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/gym/controllers/club_controller.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/models/user_model.dart';

class ClubDetailsView extends StatelessWidget {
  final String clubId;
  final ClubController controller = Get.find<ClubController>();
  final AuthController authController = Get.find<AuthController>();

  ClubDetailsView({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadClubDetails(clubId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('CLUB PROFILE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 16)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
        }

        final club = controller.selectedClub.value;
        if (club == null) {
          return const Center(child: Text('Club details not found', style: TextStyle(color: Colors.white70)));
        }

        final user = authController.currentUser.value;
        final bool isMemberFighter =
            controller.clubFighters.any((f) => f.id == user?.id);
        final bool isMemberCoach =
            controller.clubCoaches.any((c) => c.id == user?.id);
        final bool isClubOwner = user?.role == UserRole.CLUB &&
            (controller.myClub.value?.id == club.id ||
                club.adminId == user?.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClubHeader(club, isClubOwner),
              const SizedBox(height: 20),
              
              if (user != null && !isMemberFighter && !isMemberCoach && !isClubOwner)
                _buildJoinActions(club, user.role),
                
              const SizedBox(height: 20),
              _buildInfoSection(club),
              const SizedBox(height: 20),
              
              _buildFightersSection(controller),
              const SizedBox(height: 20),
              
              _buildCoachesSection(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildClubHeader(Club club, bool isClubOwner) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE31837), Color(0xFFB8102E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.business, size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFFE31837)),
                    const SizedBox(width: 6),
                    Text(club.city ?? '—', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: club.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: club.status.color.withOpacity(0.5)),
                  ),
                  child: Text(
                    club.status.displayName.toUpperCase(),
                    style: TextStyle(color: club.status.color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinActions(Club club, UserRole role) {
    final bool canRequest = role == UserRole.FIGHTER || role == UserRole.COACH;
    if (!canRequest) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE31837),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.add_reaction),
        label: Text(role == UserRole.FIGHTER ? 'REQUEST TO JOIN CLUB AS FIGHTER' : 'REQUEST TO JOIN CLUB AS COACH'),
        onPressed: () {
          if (role == UserRole.FIGHTER) {
            controller.requestJoinClubForCurrentFighter(club.id);
          } else {
            controller.requestJoinClubForCurrentCoach(club.id);
          }
        },
      ),
    );
  }

  Widget _buildInfoSection(Club club) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLUB DETAILS',
            style: TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _infoRow('Address', club.address ?? '—'),
          _infoRow('Phone', club.phoneNumber ?? '—'),
          _infoRow('Email', club.email),
          _infoRow('Contact Person', club.fullName ?? '—'),
          _infoRow('Description', club.description ?? 'No description provided.'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildFightersSection(ClubController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FIGHTERS (${controller.clubFighters.length})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        if (controller.clubFighters.isEmpty)
          const Text('No fighters registered in this club.', style: TextStyle(color: Colors.white30, fontSize: 12))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.clubFighters.length,
            itemBuilder: (_, i) {
              final fighter = controller.clubFighters[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
                      child: Text(
                        fighter.fullName.isNotEmpty ? fighter.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fighter.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(fighter.category ?? 'Unassigned', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (fighter.weight != null)
                      Text('${fighter.weight} kg', style: const TextStyle(color: Color(0xFFE31837), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCoachesSection(ClubController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COACHES (${controller.clubCoaches.length})',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
        const SizedBox(height: 10),
        if (controller.clubCoaches.isEmpty)
          const Text('No coaches registered in this club.', style: TextStyle(color: Colors.white30, fontSize: 12))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.clubCoaches.length,
            itemBuilder: (_, i) {
              final coach = controller.clubCoaches[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
                      child: Text(
                        coach.fullName.isNotEmpty ? coach.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(coach.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(coach.specialty ?? 'No Specialty', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
