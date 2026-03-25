import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/authentication/controllers/signup/verify_email_controller.dart';
import 'package:osho/utils/constants/text_strings.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email,});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => AuthenticationRepository.instance.logout(), icon: Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              children: [
                /// Images
                Center(
                  child: Image(
                    image: AssetImage(OImages.logo),
                    width: 120,
                    height: OSizes.xxl,
                  ),
                ),

                const SizedBox(height: OSizes.spaceBtwSections,),
                const SizedBox(height: OSizes.spaceBtwSections,),

                /// Title & Subtitle
                Text(
                    OText.verifyEmail,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: OColors.textprimary,
                      fontSize: OSizes.lg,
                      fontWeight:FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields,),
                Text(
                  email ?? '',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    OText.confirmEmailSubtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwSections,),
                /// Buttond
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => controller.checkEmailverificationStatus(),
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
                      OText.continu,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                )
                ),
                const SizedBox(height: OSizes.spaceBtwItems,),
                SizedBox(width: double.infinity, child: TextButton(onPressed:() => controller.sendEmailVerification(), child: Text(OText.resendEmail)),)
              ],
            ),
        ),
      ),
    );
  }
}
