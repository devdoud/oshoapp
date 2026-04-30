import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/features/measurement/screens/measurement_tutorial.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class MeasurementProfileDisplayScreen extends StatelessWidget {
  const MeasurementProfileDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = MeasurementController.instance;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mon Profil de Mesures', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const MeasurementTutorialScreen()),
            icon: const Icon(Iconsax.video_circle, color: OColors.primary),
            tooltip: "Revoir le tutoriel",
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.selectedProfile.value;
        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.ruler, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("Aucun profil trouvé"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.to(() => const ManualMeasurementEntryScreen()),
                  child: const Text("Créer un profil"),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: OColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: OColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(
                          profile.gender == 'homme' ? Iconsax.man : Iconsax.woman,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.profileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.gender.capitalizeFirst!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  "Détails des mesures",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Measurements Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMeasurementCard("Taille", "${profile.height ?? '-'} cm", Iconsax.ruler, isDark),
                    _buildMeasurementCard("Poids", "${profile.weight ?? '-'} kg", Iconsax.weight, isDark),
                    _buildMeasurementCard("Cou", "${profile.neck ?? '-'} cm", Iconsax.mirror, isDark),
                    _buildMeasurementCard("Poitrine", "${profile.chest ?? '-'} cm", Iconsax.ruler, isDark),
                    _buildMeasurementCard("Taille", "${profile.waist ?? '-'} cm", Iconsax.ruler, isDark),
                    _buildMeasurementCard("Hanches", "${profile.hips ?? '-'} cm", Iconsax.ruler, isDark),
                    _buildMeasurementCard("Épaules", "${profile.shoulder ?? '-'} cm", Iconsax.ruler, isDark),
                    _buildMeasurementCard("Manches", "${profile.sleeve ?? '-'} cm", Iconsax.ruler, isDark),
                  ],
                ),
                const SizedBox(height: 32),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => ManualMeasurementEntryScreen(profile: profile)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Modifier mes mesures", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Secondary Tutorial Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.to(() => const MeasurementTutorialScreen()),
                    icon: const Icon(Iconsax.video_circle, size: 20),
                    label: const Text("Besoin d'aide ? Revoir le tutoriel"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMeasurementCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: OColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
