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

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: OSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Headline Title
              OLoginHeader(dark: dark),
              /// Form
              OLoginForm(dark: dark),
              const SizedBox(height: OSizes.spaceBtwSections / 2),
              /// Divider 
              OFormDivider(dividertext: OText.or,),
              const SizedBox(height: OSizes.spaceBtwInputFields / 2,),
              /// Footer 
              OSocialButon(dark: dark)
            ],
          ),
                  
        ),
      ),
    );
  }
}



