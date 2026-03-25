import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:osho/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:osho/utils/validators/validation.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Headline
                Text(OText.forgetPasswordTitle, style: Theme.of(context).textTheme.headlineMedium,),
                const SizedBox(height: OSizes.spaceBtwItems,),
                Text(OText.forgetPassordSubTitle, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: OSizes.spaceBtwSections * 2 ),

                /// Text field
                Form(
                  key: controller.forgetPasswordFormKey,
                  child: TextFormField(
                    controller: controller.email,
                    validator: OValidator.validateEmail,
                    decoration: InputDecoration(
                      labelText: OText.email,
                      prefixIcon: Icon(Iconsax.direct_right),

                    ),
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwItems,),
                /// Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => controller.sendPasswordResetEmail(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OColors.primary,
                      foregroundColor: OColors.textprimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: OColors.white),
                    ),
                    child: Text(
                        OText.submit,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: OColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                    ),
                  ),
                )
              ],
            ),
        ),
      )
    );
  }
}
