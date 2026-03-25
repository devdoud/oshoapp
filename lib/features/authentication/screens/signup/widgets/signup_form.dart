import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/login_signup/form_divider.dart';
import 'package:osho/common/widgets/login_signup/social_button.dart';
import 'package:osho/features/authentication/controllers/signup/signup_controller.dart';
import 'package:osho/features/authentication/screens/signup/widgets/terms_conditions_checkbox.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:osho/utils/validators/validation.dart';

class OSignupForm extends StatelessWidget {
  const OSignupForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Signup text
        Text(
          OText.signupSubTitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: dark ? OColors.white : OColors.textprimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),
        Row(
          children: [
            Expanded(
                child: TextFormField(
                  controller: controller.firstName,
                  validator: (value) => OValidator.validateEmptyText('First name', value),
              expands: false,
              decoration: InputDecoration(
                labelText: OText.firstName,
                prefixIcon: const Icon(Iconsax.user,
                    color: OColors.grey, size: 12),
                labelStyle: TextStyle(
                    color: dark ? Colors.white : OColors.grey,
                    fontSize: 12
                ),
                // border: const OutlineInputBorder(),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
                // ),
                border: InputBorder.none,
                filled: true,
                fillColor: OColors.textFieldBackground,
              ),
            )),
            const SizedBox(width: OSizes.spaceBtwInputFields,),
            Expanded(
                child: TextFormField(
                  controller: controller.lastName,
                  validator: (value) => OValidator.validateEmptyText('Last Name', value),
                  expands: false,
                  decoration: InputDecoration(
                    labelText: OText.lastName,
                    prefixIcon: const Icon(Iconsax.user,
                        color: OColors.grey, size: 12),
                    labelStyle: TextStyle(
                        color: dark ? Colors.white : OColors.grey,
                        fontSize: 12,
                      ),
                    // border: const OutlineInputBorder(),
                    // focusedBorder: OutlineInputBorder(
                    //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
                    // ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: OColors.textFieldBackground,
                  ),
                )),
          ],
        ),

         const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),

        /// Email
        TextFormField(
          controller: controller.email,
          validator: (value) => OValidator.validateEmail(value),
          expands: false,
          decoration: InputDecoration(
            labelText: OText.email,
            prefixIcon: const Icon(Iconsax.direct,
                color: OColors.grey, size: 12),
            labelStyle: TextStyle(
                color: dark ? Colors.white : OColors.grey,
                fontSize: 12
            ),
            // border: const OutlineInputBorder(),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
            // ),
            border: InputBorder.none,
            filled: true,
            fillColor: OColors.textFieldBackground,
          ),
        ),
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),
        /// Phone
        TextFormField(
          controller: controller.phone,
          validator: (value) => OValidator.validatePhoneNumber(value),
          expands: false,
          decoration: InputDecoration(
            labelText: OText.phone,
            prefixIcon: const Icon(Iconsax.call,
                color: OColors.grey, size: 12),
            labelStyle: TextStyle(
                color: dark ? Colors.white : OColors.grey,
                fontSize: 12
            ),
            // border: const OutlineInputBorder(),
            // focusedBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: dark ? Colors.white : Colors.black),
            // ),
            border: InputBorder.none,
            filled: true,
            fillColor: OColors.textFieldBackground,
          ),
        ),
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),

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
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),
        /// Terms & conditions checkbox
        OTermsAndConditionChackbox(dark: dark),
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),
      /// Signupbutton
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed: () => controller.signup(),
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
              OText.signup,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: OColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )
          ),
          ),
        ),
    
        const SizedBox(
          height: OSizes.spaceBtwSections,
        ),
        /// Divider
        OFormDivider(dividertext: OText.orsignup),
    
        const SizedBox(
          height: OSizes.spaceBtwInputFields,
        ),
        /// Footer
        OSocialButon(dark: dark)
      ],
    ));
  }
}
