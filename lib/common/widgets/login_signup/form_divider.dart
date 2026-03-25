import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OFormDivider extends StatelessWidget {
  const OFormDivider({
    super.key, required this.dividertext,
  });

  final String dividertext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Divider(
              color: OColors.grey,
              thickness: 1,
            )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: OSizes.sm),
          child: Text(dividertext, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: OColors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          )),
        ),
        Expanded(
            child: Divider(
              color: OColors.grey,
              thickness: 1,
            )
        ),
      ],
    );
  }
}