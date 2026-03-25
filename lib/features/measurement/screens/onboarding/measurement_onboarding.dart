import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/measurement/screens/body_pose.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

class MeasurementOnboardingScreen extends StatefulWidget {
  const MeasurementOnboardingScreen({super.key});

  @override
  State<MeasurementOnboardingScreen> createState() => _MeasurementOnboardingScreenState();
}



class _MeasurementOnboardingScreenState extends State<MeasurementOnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 3000)
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    final List<Map<String, dynamic>> slides = [
      {
        'title': 'onboarding_title_1'.tr,
        'desc': 'onboarding_desc_1'.tr,
        'icon': Iconsax.cpu_charge,
        'color': OColors.primary,
      },
      {
        'title': 'onboarding_title_2'.tr,
        'desc': 'onboarding_desc_2'.tr,
        'icon': Iconsax.camera,
        'color': Colors.blue,
      },
      {
        'title': 'onboarding_title_3'.tr,
        'desc': 'onboarding_desc_3'.tr,
        'icon': Iconsax.security_safe,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Stack(
        children: [
          // 1. Primary Dynamic Background Blob (Top-Right/Left logic)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            top: _currentPage == 0 ? -100 : (_currentPage == 1 ? 100 : -50),
            right: _currentPage == 0 ? -100 : (_currentPage == 1 ? 250 : -100),
            left: _currentPage == 2 ? -100 : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slides[_currentPage]['color'].withOpacity(0.12),
                boxShadow: [
                   BoxShadow(color: slides[_currentPage]['color'].withOpacity(0.1), blurRadius: 80, spreadRadius: 30)
                ]
              ),
            ),
          ),

          // 2. Secondary Blob (Bottom-Left/Right logic for Balance)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOut,
            bottom: _currentPage == 0 ? -50 : -150,
            left: _currentPage == 0 ? -50 : (_currentPage == 1 ? -100 : 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slides[_currentPage]['color'].withOpacity(0.08),
                boxShadow: [
                   BoxShadow(color: slides[_currentPage]['color'].withOpacity(0.05), blurRadius: 60)
                ]
              ),
            ),
          ),
          
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    HapticFeedback.lightImpact(); // Tactile feedback
                  },
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          // Breath Animated Glass Container
                          ScaleTransition(
                            scale: _breathingAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(40), // More breathing room
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white.withValues(alpha: .9),
                                border: Border.all(color: Colors.white.withValues(alpha: .5), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: slide['color'].withOpacity(0.3),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                    spreadRadius: -5
                                  )
                                ]
                              ),
                              child: Icon(slide['icon'], size: 80, color: slide['color']),
                            ),
                          ),
                          const Spacer(),
                          
                          // Typography
                          Column(
                            children: [
                              Text(
                                slide['title'],
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                slide['desc'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                  height: 1.6,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Control Area (Glassmorphism inspired pill)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  children: [
                    // Glass Indicator Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                            slides.length,
                            (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: _currentPage == index
                                          ? OColors.primary
                                          : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Primary Button with Shadow & Scale
                    SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () {
                             HapticFeedback.mediumImpact();
                            if (_currentPage == slides.length - 1) {
                               GetStorage().write('hasSeenMeasurementOnboarding', true);
                               Get.off(() => const AutoPoseCaptureView(), arguments: Get.arguments); // Use Get.off to replace
                            } else {
                               _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutQuart);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OColors.primary,
                            elevation: 15,
                            shadowColor: OColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text(
                             _currentPage == slides.length - 1 ? 'scan_now'.tr : 'next'.tr,
                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Skip Button
                       AnimatedOpacity(
                         duration: const Duration(milliseconds: 300),
                         opacity: _currentPage == slides.length - 1 ? 0.0 : 1.0,
                         child: TextButton(
                           onPressed: () {
                             GetStorage().write('hasSeenMeasurementOnboarding', true);
                             Get.off(() => const AutoPoseCaptureView(), arguments: Get.arguments);
                           },
                           child: Text('skip'.tr, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                         ),
                       )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

