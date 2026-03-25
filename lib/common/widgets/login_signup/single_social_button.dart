import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class SingleSocialButton extends StatelessWidget {
  const SingleSocialButton({
    super.key,
    required this.dark, required this.socialname, required this.sociallogo,
    required this.action
  });

  final bool dark;
  final String socialname;
  final String sociallogo;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          backgroundColor: OColors.textFieldBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          foregroundColor: OColors.grey,
          // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: OSizes.buttonPadding),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OColors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              width: OSizes.iconSm,
              height: OSizes.iconSm,
              image: AssetImage(sociallogo),
            ),
            const SizedBox(width: OSizes.defaultPadding,),
            Text(
              socialname,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? OColors.white : OColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        )
    );
  }
}