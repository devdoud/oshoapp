import 'package:flutter/material.dart';
import 'package:osho/common/styles/spacing_styles.dart';
import 'package:osho/features/authentication/screens/login/widgets/login_form.dart';
import 'package:osho/features/authentication/screens/login/widgets/login_header.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_button.dart';
import '../../../../utils/constants/text_strings.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = OHelperFunctions.isDarkMode(context);
    final backgroundColor =
        dark ? const Color(0xFF090B0F) : const Color(0xFFFAF6F0);
    final panelColor = dark ? const Color(0xFF111419) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: OSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OLoginHeader(dark: dark),
              const SizedBox(height: OSizes.spaceBtwSections),
              Container(
                padding: const EdgeInsets.all(OSizes.defaultPadding),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: dark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.18 : 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OLoginForm(dark: dark),
                    const SizedBox(height: OSizes.spaceBtwSections / 2),
                    const OFormDivider(dividertext: OText.or),
                    const SizedBox(height: OSizes.spaceBtwInputFields / 2),
                    OSocialButon(dark: dark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



