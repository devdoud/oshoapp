import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:osho/features/authentication/screens/signup/widgets/signup_form.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = OHelperFunctions.isDarkMode(context);
    final backgroundColor =
        dark ? const Color(0xFF090B0F) : const Color(0xFFFAF6F0);
    final panelColor = dark ? const Color(0xFF111419) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: backgroundColor,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: backgroundColor,
            ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
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
                  'Nouveau compte',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: dark ? Colors.white70 : OColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: OSizes.spaceBtwInputFields),
              Text(
                OText.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: dark ? OColors.white : OColors.textprimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Creez votre espace client pour enregistrer vos mesures et suivre vos commandes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? Colors.white60 : OColors.grey2,
                      height: 1.5,
                    ),
              ),
              const SizedBox(
                height: OSizes.spaceBtwSections,
              ),
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
                child: OSignupForm(dark: dark),
              )
            ],
          ),
        ),
        ),
      ),
    );
  }
}
