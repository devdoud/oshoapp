import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/helpers/network_manager.dart';
import 'package:osho/utils/popups/full-screen_loader.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  /// variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void onInit() {
    // Load saved email and password if "Remember Me" was checked
    String? savedEmail = localStorage.read('REMEMBER_ME_EMAIL');
    if (savedEmail != null) {
      email.text = savedEmail;
      rememberMe.value = true;
    }
    super.onInit();
  }

  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final userController = Get.put(UserController());

  /// --Email and Password Login
  Future<void> emailAndPasswordSignIn() async {
    // Implement login logic here
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog(
          'Login you in...', OImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        // Remove Loader
        OFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!loginFormKey.currentState!.validate()) {
        // Remove Loader
        OFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is checked
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
      } else {
        localStorage.remove('REMEMBER_ME_EMAIL');
      }
      // Never store passwords on device.
      localStorage.remove('REMEMBER_ME_PASSWORD');

      // Login user using Supabase
      await AuthenticationRepository.instance
          .login(email.text.trim(), password.text.trim());

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Show Success Message
      OLoaders.successSnackBar(
          title: 'Login Successful', message: 'Welcome back!');

      // Delay to ensure snackbar is visible before redirection
      await Future.delayed(const Duration(milliseconds: 500));

      // Redirect User to relevant screen
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Increased delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      // Show Error Snackbar
      OLoaders.errorSnackBar(title: 'Login Failed', message: e.toString());
    }
  }

  /// -- Google SignIn Authentification
  Future<void> googleSignIn() async {
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog(
          'Logging you in...', OImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        OFullScreenLoader.stopLoading();
        return;
      }

      // Google  authentication
      final userCredentials =
          await AuthenticationRepository.instance.signInWithGoogle();

      // Save User Record
      await userController.saveUserRecord(userCredentials);

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Increased delay
      await Future.delayed(const Duration(milliseconds: 300));

      OLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// -- Logout
  Future<void> logout() async {
    try {
      await AuthenticationRepository.instance.logout();
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
