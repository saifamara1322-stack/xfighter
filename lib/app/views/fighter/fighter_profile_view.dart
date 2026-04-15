import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fighter_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/fighter_model.dart';

class FighterProfileView extends StatelessWidget {
  final FighterController _fighterController = Get.put(FighterController());
  final AuthController _authController = Get.find<AuthController>();
  
  FighterProfileView({super.key});
  
  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'FIGHTER PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _fighterController.isEditing.value ? Icons.save : Icons.edit,
                color: const Color(0xFFE31837),
              ),
              onPressed: () {
                if (_fighterController.isEditing.value) {
                  _fighterController.createOrUpdateProfile();
                } else {
                  _fighterController.toggleEditMode();
                }
              },
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (_fighterController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
            ),
          );
        }
        
        final fighter = _fighterController.currentFighter.value;
        
        if (fighter == null && !_fighterController.isEditing.value) {
          return _buildCreateProfileForm();
        }
        
        if (_fighterController.isEditing.value) {
          return _buildEditProfileForm();
        }
        
        return _buildProfileView(fighter!);
      }),
    );
  }
  
  Widget _buildProfileView(Fighter fighter) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(fighter),
          const SizedBox(height: 16),
          
          // Statistics Cards
          _buildStatisticsCards(fighter),
          const SizedBox(height: 16),
          
          // Fight Record
          _buildFightRecord(fighter),
          const SizedBox(height: 16),
          
          // Personal Information
          _buildPersonalInfo(fighter),
          const SizedBox(height: 16),
          
          // Recent Fights (placeholder)
          _buildRecentFights(),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader(Fighter fighter) {
    final user = _authController.currentUser.value;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE31837).withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_mma,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName.toUpperCase() ?? 'FIGHTER',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE31837).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE31837).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                fighter.weightClass.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Color(0xFFE31837),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fighter.verified 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: fighter.verified ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    fighter.verified ? Icons.verified : Icons.pending,
                    size: 14,
                    color: fighter.verified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fighter.verified ? 'VERIFIED' : 'PENDING VERIFICATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: fighter.verified ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticsCards(Fighter fighter) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'TOTAL FIGHTS',
            fighter.totalFights.toString(),
            Icons.sports_mma,
            const Color(0xFFE31837),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'WIN RATE',
            _fighterController.getWinRateText(),
            Icons.insights,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'KO/TKO',
            fighter.knockouts.toString(),
            Icons.sports_mma,
            const Color(0xFFE31837),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFightRecord(Fighter fighter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'FIGHT RECORD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRecordItem('WINS', fighter.wins, Colors.green),
                _buildRecordItem('LOSSES', fighter.losses, const Color(0xFFE31837)),
                _buildRecordItem('DRAWS', fighter.draws, Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: (fighter.winPercentage / 100) * Get.width,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE31837), Color(0xFFB8102E)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WIN DETAILS:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  'KO: ${fighter.knockouts}  •  SUB: ${fighter.submissions}  •  DEC: ${fighter.decisions}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecordItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPersonalInfo(Fighter fighter) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PERSONAL INFO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow('WEIGHT', '${fighter.weight} kg'),
            _buildInfoRow('HEIGHT', '${fighter.height} cm'),
            _buildInfoRow('REACH', '${fighter.reach} cm'),
            _buildInfoRow('STYLE', fighter.style),
            _buildInfoRow('GYM', fighter.gym),
            if (fighter.nationality != null)
              _buildInfoRow('NATIONALITY', fighter.nationality!),
            if (fighter.bio != null) ...[
              const SizedBox(height: 12),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Text(
                'BIOGRAPHY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fighter.bio!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentFights() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  color: const Color(0xFFE31837),
                ),
                const SizedBox(width: 12),
                const Text(
                  'RECENT FIGHTS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.sports_mma,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NO RECENT FIGHTS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCreateProfileForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE31837), Color(0xFFB8102E)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE31837).withValues(alpha: 0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.sports_mma,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CREATE FIGHTER PROFILE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your information to start fighting',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildEditProfileForm(),
        ],
      ),
    );
  }
  
  Widget _buildEditProfileForm() {
    return Column(
      children: [
        _buildFormTextField(
          controller: _fighterController.weightController,
          label: 'WEIGHT (KG)',
          hint: 'Enter your weight',
          icon: Icons.monitor_weight,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fighterController.updateWeightClass(int.parse(value));
            }
          },
        ),
        const SizedBox(height: 16),
        Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _fighterController.selectedWeightClass.value.isNotEmpty
                ? _fighterController.selectedWeightClass.value
                : null,
            decoration: InputDecoration(
              labelText: 'WEIGHT CLASS',
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFFE31837), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE31837)),
            items: WeightClass.allDisplayNames.map((weightClass) {
              return DropdownMenuItem(
                value: weightClass,
                child: Text(weightClass, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _fighterController.selectedWeightClass.value = value;
              }
            },
          ),
        )),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.heightController,
          label: 'HEIGHT (CM)',
          hint: 'Enter your height',
          icon: Icons.height,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.reachController,
          label: 'REACH (CM)',
          hint: 'Enter your reach',
          icon: Icons.straighten,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.styleController,
          label: 'FIGHTING STYLE',
          hint: 'Ex: Muay Thai, BJJ, Boxing...',
          icon: Icons.style,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.gymController,
          label: 'GYM / CLUB',
          hint: 'Your gym name',
          icon: Icons.fitness_center,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.nationalityController,
          label: 'NATIONALITY',
          hint: 'Your country',
          icon: Icons.flag,
          optional: true,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: _fighterController.bioController,
          label: 'BIOGRAPHY',
          hint: 'Tell your story...',
          icon: Icons.description,
          maxLines: 3,
          optional: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _fighterController.createOrUpdateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE31837),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            child: const Text('CREATE PROFILE'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool optional = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: optional ? '$label (OPTIONAL)' : label,
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFE31837)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE31837), width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}