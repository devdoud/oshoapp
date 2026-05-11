import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:flutter/services.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class MeasurementProfileDisplayScreen extends StatelessWidget {
  const MeasurementProfileDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = MeasurementController.instance;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF8F6F3),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2E)
                              : const Color(0xFFF8F6F3),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: const Color(0xFFEEEBE6)),
                        ),
                        child: Icon(
                          Iconsax.arrow_left_2,
                          size: 17,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF4A4542),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Mes mesures',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontFamily: 'DMSans',
                        ),
                      ),
                    ),
                    // Nouveau profil
                    GestureDetector(
                      onTap: () =>
                          Get.to(() => const ManualMeasurementEntryScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: OColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.add, size: 15, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Nouveau',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenu ─────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: OColors.primary));
                  }

                  if (controller.userMeasurements.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          '${controller.userMeasurements.length} profil${controller.userMeasurements.length > 1 ? 's' : ''} enregistré${controller.userMeasurements.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF888480),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...controller.userMeasurements.map(
                        (profile) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildProfileCard(
                              context, profile, controller, isDark),
                        ),
                      ),
                      _buildAddProfileCard(isDark),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProfileCard(bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => const ManualMeasurementEntryScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: OColors.primary.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.add, size: 15, color: OColors.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'Créer un nouveau profil',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: OColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.ruler, size: 52, color: OColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun profil de mesure',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Créez votre premier profil pour que nos tailleurs puissent confectionner vos vêtements sur mesure.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF888480),
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Get.to(() => const ManualMeasurementEntryScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 15),
                decoration: BoxDecoration(
                  color: OColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.ruler, size: 17, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Créer mon profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    MeasurementProfileModel profile,
    MeasurementController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: profile.isPrimary
              ? OColors.primary.withValues(alpha: 0.28)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFEEEBE6)),
          width: profile.isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: profile.isPrimary
                ? OColors.primary.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile header row ──
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: profile.isPrimary
                        ? OColors.primary.withValues(alpha: 0.08)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF4F1EC)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    profile.gender == 'homme' ? Iconsax.man : Iconsax.woman,
                    color: profile.isPrimary
                        ? OColors.primary
                        : (isDark
                            ? Colors.white60
                            : const Color(0xFF4A4542)),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.profileName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.gender.capitalizeFirst!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888480),
                        ),
                      ),
                    ],
                  ),
                ),
                if (profile.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.star5, color: OColors.primary, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          'Principal',
                          style: TextStyle(
                            color: OColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            Container(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF0EDE8),
            ),
            const SizedBox(height: 14),

            // ── Measurements chips ──
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('Poitrine', profile.chest, 'cm', isDark),
                _buildChip('Taille', profile.waist, 'cm', isDark),
                if (profile.gender == 'femme')
                  _buildChip('Hanches', profile.hips, 'cm', isDark)
                else
                  _buildChip('Épaules', profile.shoulder, 'cm', isDark),
                if (profile.height != null)
                  _buildChip('Hauteur', profile.height, 'cm', isDark),
                if (profile.weight != null)
                  _buildChip('Poids', profile.weight, 'kg', isDark),
              ],
            ),
            const SizedBox(height: 14),

            // ── Actions ──
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Iconsax.edit,
                    label: 'Modifier',
                    onTap: () => Get.to(
                      () => ManualMeasurementEntryScreen(profile: profile),
                    ),
                    isDark: isDark,
                  ),
                ),
                if (!profile.isPrimary && profile.id != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      icon: Iconsax.star,
                      label: 'Principal',
                      onTap: () => controller.setPrimary(profile.id!),
                      isDark: isDark,
                    ),
                  ),
                ],
                if (profile.id != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        _confirmDelete(context, profile, controller),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Icon(
                        Iconsax.trash,
                        color: Colors.red.withValues(alpha: 0.7),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8F6F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: OColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: OColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, double? value, String unit, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF4F2EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : const Color(0xFFB0AAA2),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value != null ? '${value.toStringAsFixed(0)} $unit' : '—',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MeasurementProfileModel profile,
    MeasurementController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Supprimer ce profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Voulez-vous vraiment supprimer le profil "${profile.profileName}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteMeasurement(profile.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Supprimer',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
