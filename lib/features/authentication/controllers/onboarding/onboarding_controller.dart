import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/navigation_menu.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int>  currentPageIndex = 0.obs;

  /// Update Current Index When Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpTo(index);
  }

  /// Update Current Index & jump to next page
  void nextPage() {
    if(currentPageIndex.value == 1) {
      // Get.to(LoginScreen());
      final storage = GetStorage();

      if(kDebugMode) {
        print('------- GET Storage ---------');
        print(storage.read('IsFirstTime'));
      }

      storage.write('IsFirstTime', false);
      Get.offAll(const NavigationMenu());
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// Update Current Index & jump to the last Page
  void skipPage() {
    currentPageIndex.value = 1;
    pageController.jumpToPage(1);
  }
}