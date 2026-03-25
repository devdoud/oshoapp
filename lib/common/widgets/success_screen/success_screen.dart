import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:osho/features/authentication/screens/login/login.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../styles/spacing_styles.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.image, required this.title, required this.subTitle, required this.onPressed});

  final String image, title, subTitle;
  final VoidCallback  onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: OSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
              children: [
          /// Images
          Lottie.asset(image, width: MediaQuery.of(context).size.width * 0.6),


          const SizedBox(height: OSizes.spaceBtwItems,),

      /// Title & Subtitle
      Text(
        title,
        style: Theme
            .of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(
          color: OColors.textprimary,
          fontSize: OSizes.lg,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: OSizes.spaceBtwInputFields,),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          subTitle,
          style: Theme
              .of(context)
              .textTheme
              .labelMedium,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: OSizes.spaceBtwSections,),

      /// Buttons
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OColors.primary,
          foregroundColor: OColors.textprimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OColors.white),
        ),
        child: Text(
            OText.continu,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: OColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )
        ),
      )
      ),
      ]
    ),
    )
    )
    );
  }
}


