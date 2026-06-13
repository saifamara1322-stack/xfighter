import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/data/models/fighter_model.dart';
import 'package:xfighter/data/models/country_model.dart';
import 'package:xfighter/data/repositories/club_repository.dart';
import 'package:xfighter/data/repositories/country_repository.dart';
import 'package:xfighter/data/repositories/user_lookup_repository.dart';

class ClubFightersView extends StatelessWidget {
  final bool embedded;
  const ClubFightersView({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_ClubFightersController());
    final body = Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFE31837)));
      }
      if (controller.fighters.isEmpty) {
        return _emptyState(context, controller);
      }
      return RefreshIndicator(
        color: const Color(0xFFE31837),
        backgroundColor: const Color(0xFF0D0D1A),
        onRefresh: controller.load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.fighters.length,
          itemBuilder: (_, i) => _FighterCard(fighter: controller.fighters[i], controller: controller),
        ),
      );
    });

    if (embedded) {
      return Column(
        children: [
          _embeddedActions(context, controller),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('CLUB FIGHTERS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: const Color(0xFF0D0D1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Color(0xFFE31837)),
            tooltip: 'Add Fighter',
            onPressed: () => _showAddFighterSheet(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white54),
            tooltip: 'Invite Fighter by Email',
            onPressed: () => _showInviteSheet(context, controller),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _embeddedActions(BuildContext context, _ClubFightersController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE31837),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('ADD FIGHTER'),
              onPressed: () => _showAddFighterSheet(context, controller),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              icon: const Icon(Icons.email_outlined, size: 18),
              label: const Text('INVITE'),
              onPressed: () => _showInviteSheet(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, _ClubFightersController c) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.sports_mma, size: 72, color: Colors.white24),
      const SizedBox(height: 16),
      const Text('No fighters yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Add fighters to your club', style: TextStyle(color: Colors.white38, fontSize: 13)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
          icon: const Icon(Icons.add),
          label: const Text('Add Fighter'),
          onPressed: () => _showAddFighterSheet(context, c),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white54, side: const BorderSide(color: Colors.white24)),
          icon: const Icon(Icons.mail_outline),
          label: const Text('Invite'),
          onPressed: () => _showInviteSheet(context, c),
        ),
      ]),
    ]),
  );
}

void _showAddFighterSheet(BuildContext context, _ClubFightersController controller) {
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final birthCtrl = TextEditingController();
  final gender = RxString('MALE');
  final selectedCountry = Rx<Country?>(null);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D0D1A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const Row(children: [
            Icon(Icons.person_add, color: Color(0xFFE31837)),
            SizedBox(width: 8),
            Text('ADD FIGHTER TO CLUB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
          ]),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: scrollCtrl, children: [
            _field(nameCtrl, 'Full Name', Icons.person_outline),
            const SizedBox(height: 10),
            _field(emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _field(passCtrl, 'Password', Icons.lock_outline, obscure: true),
            const SizedBox(height: 10),
            _field(phoneCtrl, 'Phone (optional)', Icons.phone_outlined, type: TextInputType.phone),
            const SizedBox(height: 10),
            Obx(() => DropdownButtonFormField<Country>(
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              decoration: _deco('Country', Icons.flag_outlined),
              value: selectedCountry.value,
              items: controller.countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (v) => selectedCountry.value = v,
            )),
            const SizedBox(height: 10),
            _field(categoryCtrl, 'Age Category', Icons.category_outlined),
            const SizedBox(height: 10),
            _field(weightCtrl, 'Weight kg', Icons.monitor_weight_outlined, type: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 10),
            _field(birthCtrl, 'Birth Date (YYYY-MM-DD)', Icons.cake_outlined),
            const SizedBox(height: 10),
            Obx(() => DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              decoration: _deco('Gender', Icons.wc_outlined),
              value: gender.value,
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
              ],
              onChanged: (v) { if (v != null) gender.value = v; },
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) {
                    Get.snackbar('Required', 'Name, email, and password are required', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (selectedCountry.value == null) {
                    Get.snackbar('Required', 'Please select a country', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (categoryCtrl.text.trim().isEmpty || birthCtrl.text.trim().isEmpty) {
                    Get.snackbar('Required', 'Category and birth date are required', backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.back();
                  await controller.addFighter({
                    'email': emailCtrl.text.trim(),
                    'password': passCtrl.text,
                    'fullName': nameCtrl.text.trim(),
                    'phoneNumber': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
                    'countryId': selectedCountry.value!.id,
                    'clubId': controller.clubId,
                    'category': categoryCtrl.text.trim(),
                    'weight': double.tryParse(weightCtrl.text.trim()),
                    'birthDate': birthCtrl.text.trim(),
                    'gender': gender.value,
                  });
                },
                child: const Text('ADD FIGHTER', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ])),
        ]),
      ),
    ),
  );
}

void _showInviteSheet(BuildContext context, _ClubFightersController controller) {
  final emailCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0D0D1A),
      title: const Text('Invite Fighter', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Fighter email',
          labelStyle: const TextStyle(color: Colors.white54),
          hintText: 'fighter@example.com',
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE31837), size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE31837), width: 2)),
          filled: true, fillColor: Colors.black.withOpacity(0.3),
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE31837), foregroundColor: Colors.white),
          onPressed: () {
            if (emailCtrl.text.trim().isEmpty) return;
            Get.back();
            controller.inviteFighterByEmail(emailCtrl.text.trim());
          },
          child: const Text('SEND INVITE'),
        ),
      ],
    ),
  );
}

class _FighterCard extends StatelessWidget {
  final Fighter fighter;
  final _ClubFightersController controller;
  const _FighterCard({required this.fighter, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.07), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE31837).withOpacity(0.2),
          child: Text(
            fighter.fullName.isNotEmpty ? fighter.fullName[0].toUpperCase() : '?',
            style: const TextStyle(color: Color(0xFFE31837), fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(fighter.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          Text(fighter.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          if (fighter.category != null || fighter.weight != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                if (fighter.category != null) ...[
                  const Icon(Icons.category_outlined, size: 12, color: Color(0xFFE31837)),
                  const SizedBox(width: 4),
                  Text(fighter.category!, style: const TextStyle(color: Color(0xFFE31837), fontSize: 11)),
                  const SizedBox(width: 8),
                ],
                if (fighter.weight != null) ...[
                  const Icon(Icons.monitor_weight_outlined, size: 12, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text('${fighter.weight} kg', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ]),
            ),
        ])),
        PopupMenuButton<String>(
          color: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (v) async {
            if (v == 'verify') await controller.verifyFighter(fighter.id);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'verify', child: Row(children: [
              Icon(Icons.verified_user, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Verify Fighter', style: TextStyle(color: Colors.white)),
            ])),
          ],
        ),
      ]),
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class _ClubFightersController extends GetxController {
  final _repo = ClubRepository();
  final _countryRepo = CountryRepository();
  final _lookup = UserLookupRepository();

  final fighters = <Fighter>[].obs;
  final countries = <Country>[].obs;
  final isLoading = false.obs;
  String? _clubId;
  String? get clubId => _clubId;

  @override
  void onInit() {
    super.onInit();
    _initClubId();
  }

  Future<void> _initClubId() async {
    _clubId = await _repo.resolveMyClubId();
    if (_clubId != null) load();
  }

  Future<void> load() async {
    if (_clubId == null) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getClubFighters(_clubId!),
        _countryRepo.getAllCountries(),
      ]);
      fighters.value = results[0] as List<Fighter>;
      countries.value = results[1] as List<Country>;
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFighter(Map<String, dynamic> data) async {
    if (_clubId == null) return;
    try {
      final f = await _repo.addFighterToClub(_clubId!, data);
      fighters.insert(0, f);
      Get.snackbar('Added', '${f.fullName} added to club', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> inviteFighterByEmail(String email) async {
    try {
      final fighterId = await _lookup.resolveFighterIdByEmail(email);
      await inviteFighter(fighterId);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> inviteFighter(String fighterId) async {
    try {
      await _repo.inviteFighter(fighterId);
      Get.snackbar('Invitation Sent', 'Fighter has been invited to your club', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> verifyFighter(String fighterId) async {
    try {
      await _repo.verifyFighter(fighterId);
      Get.snackbar('Verified', 'Fighter verified successfully', backgroundColor: const Color(0xFF1B5E20), colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _field(TextEditingController ctrl, String label, IconData icon,
    {TextInputType? type, bool obscure = false}) =>
    TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: _deco(label, icon),
    );

InputDecoration _deco(String label, IconData icon) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Colors.white54),
  prefixIcon: Icon(icon, color: const Color(0xFFE31837), size: 20),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE31837), width: 2)),
  filled: true, fillColor: Colors.black.withOpacity(0.3),
);
