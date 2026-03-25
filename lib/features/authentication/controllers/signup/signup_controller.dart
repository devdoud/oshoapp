import 'package:osho/features/authentication/screens/signup/verify_email.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/helpers/network_manager.dart';
import 'package:osho/utils/popups/full-screen_loader.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  /// Variables
  final hidePassword = true.obs; // Observable to toggle password visibility
  final privacyPolicy =
      false.obs; // Observable for privacy policy checkbox state
  final email = TextEditingController(); // Controller for email input
  final lastName = TextEditingController(); // Controller for last name input
  final firstName = TextEditingController(); // Controller for first name input
  final password = TextEditingController(); // Controller for password input
  final userName = TextEditingController(); // Controller for username input
  final phone = TextEditingController(); // Controller for phoneNumber input

  GlobalKey<FormState> signupFormKey =
      GlobalKey<FormState>(); // Form key for from validation

  /// -- SIGNUP
  void signup() async {
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog(
          'We are processing your information...', OImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        // Remove Loader
        OFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!signupFormKey.currentState!.validate()) {
        // Remove Loader
        OFullScreenLoader.stopLoading();
        return;
      }

      // Privacy Policy  Check
      if (!privacyPolicy.value) {
        // Remove Loader
        OFullScreenLoader.stopLoading();
        OLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message:
              'In order to proceed, you must agree to our Privacy Policy and Terms of Use.',
        );
        return;
      }

      // Register User in Supabase
      await AuthenticationRepository.instance.register(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        password: password.text.trim(),
        termsAccepted: privacyPolicy.value,
      );

      // Supabase automatically handles session persistence
      // await AuthenticationRepository.instance.saveToken(response.session?.accessToken ?? '');

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Show Success Message
      OLoaders.successSnackBar(
        title: 'Registration Successful',
        message: 'Your account has been created successfully.',
      );

      // Move to Verify Email Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Debugging: Crucial pour voir ce qui arrive du serveur
      print('Signup Error: $e');

      // Increased delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      // Show error to the user
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
