import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/validators/validation.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    final dark = OHelperFunctions.isDarkMode(context);
    final backgroundColor =
        dark ? const Color(0xFF090B0F) : const Color(0xFFFAF6F0);
    final panelColor = dark ? const Color(0xFF111419) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(),
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
                  'Recuperation',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: dark ? Colors.white70 : OColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: OSizes.spaceBtwInputFields),
              Text(
                OText.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: OSizes.spaceBtwItems),
              Text(
                OText.forgetPassordSubTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: dark ? Colors.white70 : OColors.grey2,
                      height: 1.5,
                    ),
              ),
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
                    Form(
                      key: controller.forgetPasswordFormKey,
                      child: TextFormField(
                        controller: controller.email,
                        validator: OValidator.validateEmail,
                        decoration: const InputDecoration(
                          labelText: OText.email,
                          hintText: 'exemple@email.com',
                          prefixIcon: Icon(Iconsax.direct_right, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: OSizes.spaceBtwItems),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.sendPasswordResetEmail(),
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
                          OText.submit,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: OColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
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
