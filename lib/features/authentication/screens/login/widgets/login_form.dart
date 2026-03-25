import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:osho/features/authentication/screens/signup/signup.dart';
// import 'package:osho/features/authentication/screens/signup/verify_email.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:osho/utils/validators/validation.dart';

import '../../../../../navigation_menu.dart';


class OLoginForm extends StatelessWidget {
  const OLoginForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    
    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OSizes.spaceBtwSections),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// connexion text
            Text(
              OText.loginSubTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? OColors.white : OColors.textprimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: OSizes.spaceBtwInputFields,),
            /// Email input
            TextFormField(
              controller: controller.email,
              validator: (value) => OValidator.validateEmail(value),
              decoration: InputDecoration(
                labelText: OText.email,
                prefixIcon: const Icon(Iconsax.user, color: OColors.grey, size: 18),
                labelStyle: TextStyle(color: dark ? Colors.white : OColors.grey),
                // border: const OutlineInputBorder(),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
                // ),
                border: InputBorder.none,
                filled: true,
                fillColor: OColors.textFieldBackground ,
              ),
            ),
            const SizedBox(height: OSizes.spaceBtwInputFields,),

            /// PassWord
            Obx(
                () => TextFormField(
                controller: controller.password,
                validator: (value) => OValidator.validatePassword(value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.lock, color: OColors.grey, size: 14),
                    labelText: OText.password,
                    labelStyle: TextStyle(
                        color: dark ? Colors.white : OColors.grey,
                        fontSize: 12
                    ),
                    // border: const OutlineInputBorder(),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
                    // ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () {
                        controller.hidePassword.value = !controller.hidePassword.value;
                      },
                      icon: const Icon(Iconsax.eye_slash, color: OColors.primary, size: 18)
                    ),
                    filled: true,
                    fillColor: OColors.textFieldBackground
                ),
              ),
            ),
            const SizedBox(height: OSizes.spaceBtwInputFields / 2),

            /// Remember me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remember me
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(() => Checkbox(value: controller.rememberMe.value, onChanged: (value) => controller.rememberMe.value = !controller.rememberMe.value),),
                    Text(
                      OText.rememberMe,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: dark ? OColors.white : OColors.grey,
                      fontSize: 14,
                      fontWeight:FontWeight.w400,
                    ),
                    ),
                  ],
                ),

                /// Forget Paqqword
                TextButton(onPressed: () => Get.to( () => const ForgetPassword() ),
                child:  Text(
                  OText.forgotPassword,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? OColors.white : OColors.primary,
                    fontSize: 12,
                    fontWeight:FontWeight.w500,
                  ),
                )),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  OText.noCompte,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: dark ? OColors.white : OColors.grey,
                    fontSize: 14,
                    fontWeight:FontWeight.w400,
                  ),
                ),
                // TextButton(
                //   onPressed: () => Get.to(() => VerifyEmailScreen()), child: Text(
                //   OText.createAccount,
                // )
                TextButton(
                  onPressed: () => Get.to(() => SignupScreen()), child: Text(
                  OText.createAccount,
                )
                )
              ],
            ),

            const SizedBox(height: OSizes.spaceBtwInputFields),

            /// Sign In Button
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => controller.emailAndPasswordSignIn(),
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
                  OText.signIn,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: OColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )
              ),
            )
            ),

            const SizedBox(height: OSizes.spaceBtwItems),

            Center(
              child: TextButton(
                onPressed: () => Get.offAll(() => const NavigationMenu()),
                child: Text(
                  OText.continueAsGuest,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: dark ? OColors.white : OColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // const SizedBox(height: OSizes.spaceBtwItems),

            // /// Create Account Button
            // SizedBox(width: double.infinity, child: OutlinedButton(onPressed: (){}, child: Text(OText.createAccount),))

          ],
        ),
      ),
    );
  }
}