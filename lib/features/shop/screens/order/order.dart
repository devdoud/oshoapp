import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/shop/screens/order/widgets/order_list.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // S'assure que OrderRepository est enregistré avant le contrôleur
    if (!Get.isRegistered<OrderRepository>()) {
      Get.put(OrderRepository());
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      /// --- App Bar
      appBar: OAppBar(
        title: Text("Mes Commandes",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        showBackArrow: true,
      ),

      /// --- Body
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: OOrderListItems(),
      ),
    );
  }
}
