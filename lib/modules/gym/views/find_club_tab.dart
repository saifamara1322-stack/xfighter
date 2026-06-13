import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/core/routes/app_router.dart';
import 'package:xfighter/data/models/club_model.dart';
import 'package:xfighter/data/models/user_model.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/modules/gym/controllers/club_controller.dart';

/// Find clubs by account email and request membership.
class FindClubTab extends StatefulWidget {
  const FindClubTab({super.key});

  @override
  State<FindClubTab> createState() => _FindClubTabState();
}

class _FindClubTabState extends State<FindClubTab> {
  final _emailCtrl = TextEditingController();

  ClubController get _controller => Get.find<ClubController>();
  AuthController get _auth => Get.find<AuthController>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      Get.snackbar(
        'Required',
        'Enter the club email address',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    _controller.searchClubByEmail(email);
  }

  void _openDetails(Club club) {
    Get.toNamed(AppRouter.clubDetail.replaceAll(':id', club.id));
  }

  void _requestJoin(Club club) {
    final role = _auth.currentUser.value?.role;
    if (role == UserRole.FIGHTER) {
      _controller.requestJoinClubForCurrentFighter(club.id);
    } else if (role == UserRole.COACH) {
      _controller.requestJoinClubForCurrentCoach(club.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _auth.currentUser.value?.role;
    final canRequestJoin =
        role == UserRole.FIGHTER || role == UserRole.COACH;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Club email',
              hintText: 'e.g. club@elite-mma.com',
              labelStyle: const TextStyle(color: Colors.white54),
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE31837)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE31837), width: 2),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('FIND CLUB'),
              onPressed: _search,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search by the club account email to view profile and send a join request.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (_controller.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE31837)),
                );
              }
              final club = _controller.searchedClub.value;
              if (club == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_outlined,
                          size: 64, color: Colors.white.withOpacity(0.15)),
                      const SizedBox(height: 16),
                      const Text(
                        'No club loaded yet',
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the club email above',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                child: _ClubResultCard(
                  club: club,
                  canRequestJoin: canRequestJoin,
                  onViewDetails: () => _openDetails(club),
                  onRequestJoin: () => _requestJoin(club),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ClubResultCard extends StatelessWidget {
  final Club club;
  final bool canRequestJoin;
  final VoidCallback onViewDetails;
  final VoidCallback onRequestJoin;

  const _ClubResultCard({
    required this.club,
    required this.canRequestJoin,
    required this.onViewDetails,
    required this.onRequestJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.business, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.email,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Color(0xFFE31837)),
                        const SizedBox(width: 4),
                        Text(
                          club.city ?? '—',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (club.description?.isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text(
              club.description!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: club.status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              club.status.displayName.toUpperCase(),
              style: TextStyle(
                color: club.status.color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (canRequestJoin) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE31837),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_reaction),
                label: const Text('REQUEST TO JOIN CLUB'),
                onPressed: onRequestJoin,
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('VIEW FULL PROFILE'),
              onPressed: onViewDetails,
            ),
          ),
        ],
      ),
    );
  }
}
