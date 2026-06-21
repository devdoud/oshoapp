import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/login_signup/single_social_button.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

class OSocialButon extends StatelessWidget {
  const OSocialButon({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleSocialButton(dark: dark, sociallogo: OImages.google, socialname: 'google'.tr, action: (){OLoaders.warningSnackBar(title: 'coming_soon'.tr, message: 'google_login_activating'.tr);},),
        const SizedBox(height: OSizes.spaceBtwInputFields / 2,),
        SingleSocialButton(dark: dark, sociallogo: OImages.facebook, socialname: 'facebook'.tr, action: (){OLoaders.warningSnackBar(title: 'coming_soon'.tr, message: 'facebook_login_activating'.tr);},)
      ],
    );
  }
}