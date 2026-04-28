import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xfighter/modules/fighter/controllers/fighter_controller.dart';
import 'package:xfighter/modules/auth/controllers/auth_controller.dart';
import 'package:xfighter/data/models/fighter_model.dart';

class FighterProfileView extends StatelessWidget {
  const FighterProfileView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final FighterController controller = Get.find<FighterController>();
    final AuthController authController = Get.find<AuthController>();
    
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
                controller.isEditing.value ? Icons.save : Icons.edit,
                color: const Color(0xFFE31837),
              ),
              onPressed: () {
                if (controller.isEditing.value) {
                  controller.updateFighterProfile();
                } else {
                  controller.toggleEditing();
                }
              },
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
            ),
          );
        }
        
        final fighter = controller.currentFighter.value;
        
        if (fighter == null && !controller.isEditing.value) {
          return _buildCreateProfileForm(controller, authController);
        }
        
        if (controller.isEditing.value) {
          return _buildEditProfileForm(controller);
        }
        
        return _buildProfileView(fighter!, authController);
      }),
    );
  }
  
  Widget _buildProfileView(Fighter fighter, AuthController authController) {
    final user = authController.currentUser.value;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(fighter, user?.fullName ?? 'Fighter'),
          const SizedBox(height: 16),
          _buildStatisticsCards(fighter),
          const SizedBox(height: 16),
          _buildFightRecord(fighter),
          const SizedBox(height: 16),
          _buildPersonalInfo(fighter),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader(Fighter fighter, String userName) {
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
              userName.toUpperCase(),
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
            '${fighter.winPercentage.toStringAsFixed(0)}%',
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
  
  Widget _buildCreateProfileForm(FighterController controller, AuthController authController) {
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
          _buildEditProfileForm(controller),
        ],
      ),
    );
  }
  
  Widget _buildEditProfileForm(FighterController controller) {
    return Column(
      children: [
        _buildFormTextField(
          controller: controller.weightController,
          label: 'WEIGHT (KG)',
          hint: 'Enter your weight',
          icon: Icons.monitor_weight,
          keyboardType: TextInputType.number,
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
            value: controller.selectedWeightClass.value.isNotEmpty
                ? controller.selectedWeightClass.value
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
            items: WeightClass.classes.map((weightClass) {
              return DropdownMenuItem(
                value: weightClass,
                child: Text(weightClass, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectedWeightClass.value = value;
              }
            },
          ),
        )),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.heightController,
          label: 'HEIGHT (CM)',
          hint: 'Enter your height',
          icon: Icons.height,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.reachController,
          label: 'REACH (CM)',
          hint: 'Enter your reach',
          icon: Icons.straighten,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.styleController,
          label: 'FIGHTING STYLE',
          hint: 'Ex: Muay Thai, BJJ, Boxing...',
          icon: Icons.style,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.gymController,
          label: 'GYM / CLUB',
          hint: 'Your gym name',
          icon: Icons.fitness_center,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.nationalityController,
          label: 'NATIONALITY',
          hint: 'Your country',
          icon: Icons.flag,
          optional: true,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          controller: controller.bioController,
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
            onPressed: controller.createFighterProfile,
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFFE31837), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}