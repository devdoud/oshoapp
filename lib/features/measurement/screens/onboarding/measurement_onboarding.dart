import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class MeasurementOnboardingScreen extends StatefulWidget {
  const MeasurementOnboardingScreen({super.key});

  @override
  State<MeasurementOnboardingScreen> createState() =>
      _MeasurementOnboardingScreenState();
}

class _MeasurementOnboardingScreenState
    extends State<MeasurementOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  static const _slides = [
    _Slide(
      title: 'Prenez vos mesures',
      desc:
          'Mesurez chaque partie de votre corps avec précision pour une confection parfaitement ajustée.',
      icon: Iconsax.ruler,
      accent: Color(0xFF1A1A1A),
    ),
    _Slide(
      title: 'Guide vidéo',
      desc:
          'Des tutoriels courts vous accompagnent pas à pas pour chaque zone du corps.',
      icon: Iconsax.video_play,
      accent: Color(0xFF3B7DD8),
    ),
    _Slide(
      title: 'Profil enregistré',
      desc:
          'Sauvegardez vos mesures une seule fois et réutilisez-les pour toutes vos commandes futures.',
      icon: Iconsax.user_tick,
      accent: Color(0xFF34C759),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage == _slides.length - 1) {
      MeasurementController.instance.completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            // ── Slides ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = i);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final s = _slides[index];
                  return _SlidePage(
                    slide: s,
                    isDark: isDark,
                    pulseAnim: _pulseAnim,
                  );
                },
              ),
            ),

            // ── Bottom controls ──────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : const Color(0xFFD6D0CB)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Primary button
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == _slides.length - 1
                              ? 'Commencer'
                              : 'Suivant',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Skip
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _currentPage == _slides.length - 1 ? 0 : 1,
                    child: GestureDetector(
                      onTap: () =>
                          MeasurementController.instance.completeOnboarding(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Passer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFFB0AAA2),
                          ),
                        ),
                      ),
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
}

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  final String title;
  final String desc;
  final IconData icon;
  final Color accent;

  const _Slide({
    required this.title,
    required this.desc,
    required this.icon,
    required this.accent,
  });
}

// ── Slide page ────────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  final bool isDark;
  final Animation<double> pulseAnim;

  const _SlidePage({
    required this.slide,
    required this.isDark,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // Icon container
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: slide.accent.withValues(
                    alpha: isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: slide.accent.withValues(alpha: 0.14),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  slide.icon,
                  size: 40,
                  color: isDark && slide.accent == const Color(0xFF1A1A1A)
                      ? Colors.white
                      : slide.accent,
                ),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Title
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            slide.desc,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : const Color(0xFF888480),
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
