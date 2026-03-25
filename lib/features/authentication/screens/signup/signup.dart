import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
            children: [
              /// Title
              Text(
                OText.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: dark ? OColors.white : OColors.textprimary,
                      fontSize: 41,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(
                height: OSizes.spaceBtwSections,
              ),

              ///  Form
              OSignupForm(dark: dark)
            ],
          ),
        ),
      ),
    );
  }
}