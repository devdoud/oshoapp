import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:osho/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import '../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                image: OImages.onBoardingImage1,
                rectangleImage: OImages.onBoardingRectangle,
                title: 'auth_onboarding_title1'.tr,
                subTitle: 'auth_onboarding_sub1'.tr,
              ),
              OnBoardingPage(
                image: OImages.onBoardingImage2,
                rectangleImage: OImages.onBoardingRectangle,
                title: 'auth_onboarding_title2'.tr,
                subTitle: 'auth_onboarding_sub2'.tr,
                subTitle2: 'auth_onboarding_sub21'.tr,
                subTitle3: 'auth_onboarding_sub22'.tr,
              ),
            ],
          ),
          const OnBoardingSkip(),
          const OnBoardingDotNavigation(),
          OnBoardingElevatedButton(controller: controller),
        ],
      ),
    );
  }
}

class OnBoardingElevatedButton extends StatelessWidget {
  const OnBoardingElevatedButton({
    super.key,
    required this.controller,
  });

  final OnBoardingController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: OSizes.sm,
      left: OSizes.defaultSpace,
      right: OSizes.defaultSpace,
      child: SizedBox(
        width: OHelperFunctions.screenWidth(),
        child: Obx(
          () => ElevatedButton(
            onPressed: OnBoardingController.instance.nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.secondary,
              foregroundColor: OColors.textprimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              side: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  controller.currentPageIndex.value == 0
                      ? 'next'.tr
                      : 'start_btn'.tr,
                ),
                const SizedBox(width: OSizes.md),
                controller.currentPageIndex.value == 0
                    ? Image.asset(OImages.onBoardingArrow)
                    : const SizedBox(width: OSizes.interlineSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
