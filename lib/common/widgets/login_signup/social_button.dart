import 'package:flutter/material.dart';
import 'package:osho/common/widgets/login_signup/single_social_button.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';

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
        SingleSocialButton(dark: dark, sociallogo: OImages.google, socialname: OText.google, action: (){OLoaders.warningSnackBar(title: "Bient\u00f4t disponible", message: "Connexion Google en cours d'activation.");},),
        const SizedBox(height: OSizes.spaceBtwInputFields / 2,),
        SingleSocialButton(dark: dark, sociallogo: OImages.facebook, socialname: OText.facebook, action: (){OLoaders.warningSnackBar(title: "Bient\u00f4t disponible", message: "Connexion Facebook en cours d'activation.");},)
      ],
    );
  }
}