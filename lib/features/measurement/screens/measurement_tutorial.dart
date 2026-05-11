import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/video/video_player_view.dart';
import 'package:osho/features/measurement/controllers/measurement_tutorial_controller.dart';
import 'package:osho/features/measurement/models/measurement_tutorial_model.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class MeasurementTutorialScreen extends StatefulWidget {
  final bool allowBack;
  final bool returnToCheckout;

  const MeasurementTutorialScreen({
    super.key,
    this.allowBack = false,
    this.returnToCheckout = false,
  });

  @override
  State<MeasurementTutorialScreen> createState() =>
      _MeasurementTutorialScreenState();
}

class _MeasurementTutorialScreenState
    extends State<MeasurementTutorialScreen> {
  late final MeasurementTutorialController _ctrl;

  static const Map<String, String> _fallbackThumbnails = {
    'neck': 'assets/images/measurement/neck.png',
    'chest': 'assets/images/measurement/chest.png',
    'waist': 'assets/images/measurement/waist.png',
    'hips': 'assets/images/measurement/hips.png',
    'shoulder': 'assets/images/measurement/hips.png',
    'sleeve': 'assets/images/measurement/waist.png',
    'inseam': 'assets/images/measurement/hips.png',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<MeasurementTutorialController>()
        ? Get.find<MeasurementTutorialController>()
        : Get.put(MeasurementTutorialController());
  }

  void _goToHome() {
    final nav = Get.find<NavigationController>();
    nav.selectedIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: PopScope(
        canPop: widget.allowBack,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !widget.allowBack) _goToHome();
        },
        child: Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
          body: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              _buildHeader(isDark),

              // ── Body ────────────────────────────────────────────────
              Expanded(
                child: Obx(
                  () => RefreshIndicator(
                    color: OColors.primary,
                    onRefresh: _ctrl.fetchTutorials,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIntro(isDark),
                          const SizedBox(height: 22),
                          _buildSectionLabel('VIDÉOS', isDark),
                          const SizedBox(height: 12),
                          _buildContent(isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom bar ──────────────────────────────────────────
              _buildBottomBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              if (widget.allowBack) ...[
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFEEEBE6),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                'Guide de mesure',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Intro card ────────────────────────────────────────────────────────────────

  Widget _buildIntro(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.video_play,
                color: OColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apprenez à vous mesurer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivez ces courtes vidéos pour chaque zone du corps. Une seule fois suffit.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : const Color(0xFF888480),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────────

  Widget _buildContent(bool isDark) {
    if (_ctrl.isLoading.value && _ctrl.tutorials.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(color: OColors.primary)),
      );
    }
    if (_ctrl.errorMessage.isNotEmpty && _ctrl.tutorials.isEmpty) {
      return _buildErrorState(isDark);
    }
    if (_ctrl.tutorials.isEmpty) {
      return _buildEmptyState(isDark);
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _ctrl.tutorials.length,
      itemBuilder: (_, i) => _buildCard(_ctrl.tutorials[i], isDark),
    );
  }

  // ── Tutorial card ─────────────────────────────────────────────────────────────

  Widget _buildCard(MeasurementTutorialModel item, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(
        () => VideoPlayerView(videoUrl: item.videoUrl, title: item.title),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                _buildThumbnail(item),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.description,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF888480),
                      fontSize: 11,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        'Regarder',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : OColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 10,
                        color: isDark ? Colors.white60 : OColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Thumbnail ─────────────────────────────────────────────────────────────────

  Widget _buildThumbnail(MeasurementTutorialModel item) {
    if (item.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          item.thumbnailUrl,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(item),
        ),
      );
    }
    return _buildFallback(item);
  }

  Widget _buildFallback(MeasurementTutorialModel item) {
    final asset = _fallbackThumbnails[item.slug];
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          asset,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: OColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(Iconsax.video_circle, color: OColors.primary, size: 26),
    );
  }

  // ── Error / empty states ──────────────────────────────────────────────────────

  Widget _buildErrorState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OColors.warning.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                size: 24, color: OColors.warning),
          ),
          const SizedBox(height: 12),
          Text(
            'Impossible de charger les tutoriels',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _ctrl.fetchTutorials,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  color: isDark ? Colors.white70 : OColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.video_circle,
                size: 28, color: OColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun tutoriel disponible',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Les vidéos seront bientôt disponibles.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : const Color(0xFF888480),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => Get.to(
            () => ManualMeasurementEntryScreen(
              allowBack: widget.allowBack,
              returnToCheckout: widget.returnToCheckout,
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                "J'ai compris, saisir mes mesures",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
