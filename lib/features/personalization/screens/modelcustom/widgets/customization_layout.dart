import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/appbar/modelappbar.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class CustomizationLayout extends StatelessWidget {
  final String title;
  final String subTitle;
  final int step;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onNext;
  final String nextButtonText;
  final bool showBackArrow;
  final bool isNextEnabled;

  const CustomizationLayout({
    super.key,
    required this.title,
    required this.subTitle,
    required this.step,
    required this.totalSteps,
    required this.child,
    this.onNext,
    this.nextButtonText = 'Continuer',
    this.showBackArrow = true,
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: OModelAppBar(
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subTitle: Text(subTitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey)),
        showBackArrow: showBackArrow,
        step: step,
        totalSteps: totalSteps,
      ),
      body: Column(
        children: [
          // Content Area
          Expanded(
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: OSizes.defaultPadding),
              child: child,
            ),
          ),

          // Bottom Action Area
          if (onNext != null)
            Container(
              padding: const EdgeInsets.all(OSizes.defaultPadding),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isNextEnabled ? onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextButtonText == 'Continuer'
                              ? 'continue'.tr
                              : nextButtonText,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (isNextEnabled) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
