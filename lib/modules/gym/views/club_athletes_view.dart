import 'package:flutter/material.dart';
import 'package:xfighter/modules/gym/views/club_fighters_view.dart';
import 'package:xfighter/modules/gym/views/club_coaches_view.dart';
import 'package:xfighter/modules/gym/views/club_invitations_view.dart';

/// Unified club athlete management: fighters, coaches, and pending requests.
class ClubAthletesView extends StatelessWidget {
  const ClubAthletesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text(
            'ATHLETE MANAGEMENT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 15,
            ),
          ),
          backgroundColor: const Color(0xFF0D0D1A),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFE31837),
            labelColor: Color(0xFFE31837),
            unselectedLabelColor: Colors.white54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            tabs: [
              Tab(text: 'FIGHTERS'),
              Tab(text: 'COACHES'),
              Tab(text: 'REQUESTS'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FightersTab(),
            _CoachesTab(),
            ClubInvitationsView(embedded: true),
          ],
        ),
      ),
    );
  }
}

/// Fighters tab without nested scaffold.
class _FightersTab extends StatelessWidget {
  const _FightersTab();

  @override
  Widget build(BuildContext context) => const ClubFightersView(embedded: true);
}

class _CoachesTab extends StatelessWidget {
  const _CoachesTab();

  @override
  Widget build(BuildContext context) => const ClubCoachesView(embedded: true);
}
