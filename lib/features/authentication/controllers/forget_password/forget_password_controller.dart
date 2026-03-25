import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:osho/utils/helpers/network_manager.dart';
import 'package:osho/utils/popups/full-screen_loader.dart';

import '../../../../common/widgets/loaders/loader.dart';
import '../../../../utils/constants/image_strings.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// vaiables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  // Send Reset Password Email
  sendPasswordResetEmail() async {
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog('processing your information...', OImages.docerAnimation);

      // Check the internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) {OFullScreenLoader.stopLoading(); return;}

      // Form vallidation
      if(!forgetPasswordFormKey.currentState!.validate()){
        OFullScreenLoader.stopLoading();
        return ;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Show Success Screen
      OLoaders.successSnackBar(title: 'Email Sent', message: 'Email link Sent to Reset your password'.tr);

      // Redirect
      Get.to(() => ResetPassword(email: email.text.trim()));
    
    } catch (e){}
  }

  resendPasswordResetEmail(String email) async {
    try {
      // Start Loading
      OFullScreenLoader.openLoadingDialog('processing your information...', OImages.docerAnimation);

      // Check the internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected) {OFullScreenLoader.stopLoading(); return;}

      // Form vallidation
      if(!forgetPasswordFormKey.currentState!.validate()){
        OFullScreenLoader.stopLoading();
        return ;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Remove Loader
      OFullScreenLoader.stopLoading();

      // Show Success Screen
      OLoaders.successSnackBar(title: 'Email Sent', message: 'Email link Sent to Reset your password'.tr);
    } catch (e){} }
}