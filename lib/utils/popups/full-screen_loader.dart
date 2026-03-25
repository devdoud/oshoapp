import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/animation_loader.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/utils/constants/colors.dart';

class OFullScreenLoader {
  /// Open a full-screen loading dialog with a given text and animation.
  /// This method doesn't return anything.
  /// 
  /// Parameters 
  ///  - text: The textto be displyed in the loading dialog
  ///  - animation: The Lottie animation to be shown
  /// 
  
  static void openLoadingDialog(String text, String animation) {
    Get.dialog(
      PopScope(
        canPop: false, // Disable Popping with the back button
        child: Container(
          color: OColors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              // Use the new Modern Spinner instead of Lottie animation
              const OLoader(size: 80), 
              const SizedBox(height: 24),
              Text(
                text,
                style: Theme.of(Get.context!).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Stop the currently open loading dialog.
  /// This method doesn't return anything
  static void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

}