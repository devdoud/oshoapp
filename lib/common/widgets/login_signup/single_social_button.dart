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
    final backgroundColor =
        dark ? const Color(0xFF171A1F) : const Color(0xFFF3EFE8);
    final borderColor =
        dark ? const Color(0xFF262C35) : const Color(0xFFE4DBCF);

    return OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: OColors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
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
                color: dark ? OColors.white : OColors.textprimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        )
    );
  }
}
