import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/authentication/controllers/signup/signup_controller.dart';
import 'package:osho/features/authentication/screens/privacy_policy.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OTermsAndConditionChackbox extends StatelessWidget {
  const OTermsAndConditionChackbox({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = SignupController.instance;
    final linkColor = dark ? OColors.white : OColors.primary;
    final baseStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: dark ? Colors.white70 : OColors.grey2,
        );
    final linkStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (_) => controller.privacyPolicy.value =
                  !controller.privacyPolicy.value,
              activeColor: OColors.primary,
              side: BorderSide(
                color: dark ? Colors.white38 : const Color(0xFFB0AAA2),
              ),
            ),
          ),
        ),
        const SizedBox(width: OSizes.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              softWrap: true,
              TextSpan(
                children: [
                  TextSpan(
                    text: '${'i_agree_to'.tr} ',
                    style: baseStyle,
                  ),
                  TextSpan(
                    text: 'privacy_policy_label'.tr,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Get.to(() => const PrivacyPolicyScreen()),
                  ),
                  TextSpan(
                    text: ' ${'and_word'.tr} ',
                    style: baseStyle,
                  ),
                  TextSpan(
                    text: 'terms_of_use_label'.tr,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Get.to(() => const TermsConditionsScreen()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
