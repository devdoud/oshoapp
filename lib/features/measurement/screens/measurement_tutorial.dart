import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/video/video_player_view.dart';
import 'package:osho/features/measurement/controllers/measurement_tutorial_controller.dart';
import 'package:osho/features/measurement/models/measurement_tutorial_model.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
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

class _MeasurementTutorialScreenState extends State<MeasurementTutorialScreen> {
  late final MeasurementTutorialController _tutorialController;

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
    _tutorialController = Get.isRegistered<MeasurementTutorialController>()
        ? Get.find<MeasurementTutorialController>()
        : Get.put(MeasurementTutorialController());
  }

  void _goToHome() {
    final navController = Get.find<NavigationController>();
    navController.selectedIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return PopScope(
      canPop: widget.allowBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !widget.allowBack) _goToHome();
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text(
            'Guide de mesure',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(widget.allowBack ? Icons.arrow_back : Iconsax.home),
            tooltip: widget.allowBack ? 'Retour' : 'Retour a l accueil',
            onPressed: () {
              if (widget.allowBack) {
                Get.back();
              } else {
                _goToHome();
              }
            },
          ),
        ),
        body: Obx(
          () => RefreshIndicator(
            color: OColors.primary,
            onRefresh: _tutorialController.fetchTutorials,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(OSizes.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apprenez a vous mesurer',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Les videos sont maintenant chargees depuis Supabase. Ajoutez vos fichiers dans Storage puis actualisez cet ecran.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (_tutorialController.isLoading.value &&
                        _tutorialController.tutorials.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(color: OColors.primary),
                        ),
                      )
                    else if (_tutorialController.errorMessage.isNotEmpty &&
                        _tutorialController.tutorials.isEmpty)
                      _buildErrorState(context, isDark)
                    else if (_tutorialController.tutorials.isEmpty)
                      _buildEmptyState(context, isDark)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _tutorialController.tutorials.length,
                        itemBuilder: (context, index) {
                          final item = _tutorialController.tutorials[index];
                          return _buildTutorialCard(context, item, isDark);
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.to(
              () => ManualMeasurementEntryScreen(
                allowBack: widget.allowBack,
                returnToCheckout: widget.returnToCheckout,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "J'ai compris, passer a la saisie",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialCard(
    BuildContext context,
    MeasurementTutorialModel item,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => Get.to(
        () => VideoPlayerView(
          videoUrl: item.videoUrl,
          title: item.title,
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildThumbnail(item),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: OColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Regarder la video',
                        style: TextStyle(
                          color: OColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildThumbnail(MeasurementTutorialModel item) {
    if (item.thumbnailUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          item.thumbnailUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(item),
        ),
      );
    }

    return _buildFallbackThumbnail(item);
  }

  Widget _buildFallbackThumbnail(MeasurementTutorialModel item) {
    final asset = _fallbackThumbnails[item.slug];
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          asset,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderThumbnail(),
        ),
      );
    }

    return _buildPlaceholderThumbnail();
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: OColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Iconsax.video_circle, color: OColors.primary, size: 32),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 40,
            color: OColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            'Impossible de charger les tutoriels',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _tutorialController.errorMessage.value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _tutorialController.fetchTutorials,
            child: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.ondemand_video_outlined,
            size: 40,
            color: OColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun tutoriel disponible',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoute des lignes dans la table measurement_tutorials puis upload les videos dans le bucket measurement-tutorials.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
