import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/authentication/controllers/signup/verify_email_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    final dark = OHelperFunctions.isDarkMode(context);
    final backgroundColor =
        dark ? const Color(0xFF090B0F) : const Color(0xFFFAF6F0);
    final panelColor = dark ? const Color(0xFF111419) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => AuthenticationRepository.instance.logout(),
            icon: const Icon(CupertinoIcons.clear),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Container(
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
                const SizedBox(height: OSizes.spaceBtwItems),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withOpacity(0.06)
                        : OColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Image.asset(
                      OImages.logo,
                      width: 42,
                      height: 42,
                    ),
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwSections),
                Text(
                  OText.verifyEmail,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: dark ? Colors.white : OColors.textprimary,
                        fontSize: OSizes.lg,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                Text(
                  email ?? '',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: dark ? Colors.white70 : OColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    OText.confirmEmailSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? Colors.white70 : OColors.grey2,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.checkEmailverificationStatus(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 18,
                      ),
                    ),
                    child: Text(
                      OText.continu,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: OColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => controller.sendEmailVerification(),
                    child: Text(
                      OText.resendEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dark ? Colors.white70 : OColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
