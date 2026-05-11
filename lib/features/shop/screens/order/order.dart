import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/shop/screens/order/widgets/order_list.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    if (!Get.isRegistered<OrderRepository>()) {
      Get.put(OrderRepository());
    }
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111111) : const Color(0xFFF8F9FA),
      appBar: OAppBar(
        title: Text("Mes Commandes",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        showBackArrow: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: OOrderListItems(),
      ),
    );
  }
}
