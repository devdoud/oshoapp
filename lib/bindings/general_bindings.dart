import 'package:get/get.dart';
import 'package:osho/utils/helpers/network_manager.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.put(CartController());
  }
}