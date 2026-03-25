import 'package:flutter/material.dart';
import 'package:osho/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    return Positioned(
      top: OHelperFunctions.screenHeight() * 0.6,
      left: OHelperFunctions.screenWidth() * 0.4,
      child: SmoothPageIndicator(
        controller: controller.pageController, 
        onDotClicked: controller.dotNavigationClick,
        count: 2,
        effect: ExpandingDotsEffect(
          dotHeight: 4,
          activeDotColor: OColors.white,
          dotColor: Colors.grey,
      ),
      )
    );
  }
}