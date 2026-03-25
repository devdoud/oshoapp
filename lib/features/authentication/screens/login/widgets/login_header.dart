import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';

class OLoginHeader extends StatelessWidget {
  const OLoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: OSizes.spaceBtwInputFields,),
        Text(
          OText.loginTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: dark ? OColors.white : OColors.textprimary,
            fontSize: 41,
            fontWeight:FontWeight.w700,
          ),
        ),
      ],
    );
  }
}