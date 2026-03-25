import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/authentication/controllers/forget_password/forget_password_controller.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../login/login.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Get.offAll(() => LoginScreen()), icon: Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              children: [
                ///Logo Image
                const SizedBox(height: OSizes.spaceBtwSections,),
                Center(
                  child: Image(
                    image: AssetImage(OImages.logo),
                    width: 120,
                    height: OSizes.xxl,
                  ),
                ),

                const SizedBox(height: OSizes.spaceBtwSections,),
                ///Title and SubTitle
                Text(
                  OText.changeYourPasswordTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: OColors.textprimary,
                    fontSize: OSizes.lg,
                    fontWeight:FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    OText.changeYourPasswordSubTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: OSizes.spaceBtwSections,),

                /// Buttons
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => Get.offAll(() => const LoginScreen()),
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
                      OText.done,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: OColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                )
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields,),
                SizedBox(width: double.infinity, child: TextButton(onPressed: (){ForgetPasswordController.instance.resendPasswordResetEmail(email);}, child: Text(OText.resendEmail)),)
              ],
            ),
        ),
      ),
    );
  }
}
