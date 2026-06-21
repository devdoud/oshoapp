import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OLoginHeader extends StatelessWidget {
  const OLoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withOpacity(0.06)
                : OColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'client_access'.tr,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: dark ? Colors.white70 : OColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: OSizes.spaceBtwInputFields),
        Text(
          'login_title'.tr,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: dark ? OColors.white : OColors.textprimary,
            fontSize: 38,
            fontWeight:FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'login_header_sub'.tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? Colors.white60 : OColors.grey2,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
