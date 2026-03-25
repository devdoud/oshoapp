import 'package:flutter/material.dart';
import 'package:osho/features/authentication/controllers/signup/signup_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class OTermsAndConditionChackbox extends StatelessWidget {
  const OTermsAndConditionChackbox({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child:  Obx(() => Checkbox(
          value: controller.privacyPolicy.value, 
          onChanged: (value) => controller.privacyPolicy.value = !controller.privacyPolicy.value,
          )
        )
        ),
        const SizedBox(width: OSizes.sm,),
        Text.rich(
          softWrap: true,
            TextSpan(
          children: [
            TextSpan(text: '${OText.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
            TextSpan(text: '${OText.privacyPolicy}', style: Theme.of(context).textTheme.bodySmall!.apply(
              color: dark ? OColors.white : OColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: dark ? OColors.white : OColors.primary,
            )),
            TextSpan(text: '${OText.and} ', style: Theme.of(context).textTheme.bodySmall),
            TextSpan(text: OText.termsOfUse, style: Theme.of(context).textTheme.bodySmall!.apply(
              color: dark ? OColors.white : OColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: dark ? OColors.white : OColors.primary,
            )),
          ]
        ))
      ],
    );
  }
}