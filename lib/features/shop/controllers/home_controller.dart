import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final carousalCurrentIndex = 0.obs;

  // var pageIndex = 0.obs;
  // var pageController = PageController();

  // void changePage(int index) {
  //   pageIndex.value = index;
  //   pageController.jumpToPage(index);
  //   update();
  // }

  void updatePageIndicator(int index) {
    carousalCurrentIndex.value = index;
  }
}