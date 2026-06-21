import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class MeasurementProfileDisplayScreen extends StatelessWidget {
  const MeasurementProfileDisplayScreen({super.key});

  // Nombre de champs de mesure que le profil peut contenir
  static const int _totalFields = 14; // neck, chest, waist, hips, shoulder, sleeve, inseam, upper_arm, back_length, dress_length, thigh, trouser_length, bust_height + height

  int _completedCount(MeasurementProfileModel p) {
    int count = 0;
    if (p.height != null) count++;
    if (p.neck != null) count++;
    if (p.chest != null) count++;
    if (p.waist != null) count++;
    if (p.hips != null) count++;
    if (p.shoulder != null) count++;
    if (p.sleeve != null) count++;
    if (p.inseam != null) count++;
    if (p.upperArm != null) count++;
    if (p.backLength != null) count++;
    if (p.dressLength != null) count++;
    if (p.thigh != null) count++;
    if (p.trouserLength != null) count++;
    if (p.bustHeight != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = MeasurementController.instance;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mes mesures',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.to(() => const ManualMeasurementEntryScreen()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.add,
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Nouveau',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
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
                          color: OColors.primary),
                    );
                  }

                  if (controller.userMeasurements.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }

                  return ListView(
                    padding:
                        const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '${controller.userMeasurements.length} profil${controller.userMeasurements.length > 1 ? 's' : ''} enregistré${controller.userMeasurements.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFFB0AAA2),
                          ),
                        ),
                      ),
                      ...controller.userMeasurements.map(
                        (profile) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildProfileCard(
                              context, profile, controller, isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildAddCard(isDark),
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

  // ── Profile card ─────────────────────────────────────────────────────────────

  Widget _buildProfileCard(
    BuildContext context,
    MeasurementProfileModel profile,
    MeasurementController controller,
    bool isDark,
  ) {
    final completed = _completedCount(profile);
    final progress = completed / _totalFields;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final isPrimary = profile.isPrimary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? OColors.primary.withValues(alpha: 0.25)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFEEEBE6)),
          width: isPrimary ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? OColors.primary.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: isDark ? 0.10 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nom + genre + badge ─────────────────────────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? OColors.primary.withValues(alpha: 0.10)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF4F1EC)),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    profile.gender == 'homme'
                        ? Iconsax.man
                        : Iconsax.woman,
                    size: 20,
                    color: isPrimary
                        ? OColors.primary
                        : (isDark
                            ? Colors.white54
                            : const Color(0xFF888480)),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.gender.capitalizeFirst ?? profile.gender,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0AAA2),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.star5,
                            color: OColors.primary, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          'Principal',
                          style: TextStyle(
                            color: OColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Complétion ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFF0EDE8),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0
                            ? const Color(0xFF34C759)
                            : OColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completed/$_totalFields',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: progress == 1.0
                        ? const Color(0xFF34C759)
                        : (isDark
                            ? Colors.white54
                            : const Color(0xFF888480)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── 3 mesures clés ──────────────────────────────────────
            Row(
              children: [
                _keyMeasure(
                  'Poitrine',
                  profile.chest,
                  'cm',
                  isDark,
                ),
                const SizedBox(width: 8),
                _keyMeasure(
                  'Taille',
                  profile.waist,
                  'cm',
                  isDark,
                ),
                const SizedBox(width: 8),
                _keyMeasure(
                  profile.gender == 'femme' ? 'Hanches' : 'Épaules',
                  profile.gender == 'femme'
                      ? profile.hips
                      : profile.shoulder,
                  'cm',
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Actions ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    icon: Iconsax.edit,
                    label: 'Modifier',
                    onTap: () => Get.to(
                      () => ManualMeasurementEntryScreen(
                          profile: profile),
                    ),
                    isDark: isDark,
                  ),
                ),
                if (!isPrimary && profile.id != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionBtn(
                      icon: Iconsax.star,
                      label: 'Définir principal',
                      onTap: () =>
                          controller.setPrimary(profile.id!),
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(
                        Iconsax.trash,
                        color: Colors.red.withValues(alpha: 0.65),
                        size: 15,
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

  Widget _keyMeasure(
      String label, double? value, String unit, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFF8F6F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? Colors.white38
                    : const Color(0xFFB0AAA2),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value != null
                  ? '${value.toStringAsFixed(0)} $unit'
                  : '—',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: value != null
                    ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                    : (isDark
                        ? Colors.white24
                        : const Color(0xFFCCC8C4)),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
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
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: OColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add card ─────────────────────────────────────────────────────────────────

  Widget _buildAddCard(bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => const ManualMeasurementEntryScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: OColors.primary.withValues(alpha: 0.20),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.add,
                  size: 14, color: OColors.primary),
            ),
            const SizedBox(width: 9),
            const Text(
              'Créer un nouveau profil',
              style: TextStyle(
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

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.ruler,
                  size: 44, color: OColors.primary),
            ),
            const SizedBox(height: 22),
            Text(
              'Aucun profil de mesure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Créez votre premier profil pour que nos tailleurs confectionnent vos vêtements sur mesure.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF888480),
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () =>
                  Get.to(() => const ManualMeasurementEntryScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.ruler,
                      size: 16,
                      color: isDark
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Créer mon profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
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

  // ── Delete dialog ─────────────────────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    MeasurementProfileModel profile,
    MeasurementController controller,
  ) {
    final isDark = OHelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer ce profil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer "${profile.profileName}" ? Cette action est irréversible.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF888480),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF888480),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMeasurement(profile.id!);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
