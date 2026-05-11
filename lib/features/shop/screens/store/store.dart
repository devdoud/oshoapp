import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/models/cart_item_model.dart';
import 'package:osho/features/shop/screens/checkout/cart_checkout.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CartController());

    return Scaffold(
      appBar: OAppBar(
        title: Text("Mon Panier",
            style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (cartController.items.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: OSizes.defaultPadding * 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(OImages.basket),
                  ),
                  const SizedBox(height: OSizes.defaultSpace),
                  Text(
                    "Votre panier est vide",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: OSizes.sm),
                  Text(
                    "Ajoutez vos modèles préférés pour les retrouver ici.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OSizes.defaultSpace),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Get.offAll(() => const NavigationMenu()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OColors.primary,
                          foregroundColor: OColors.textprimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: OColors.white),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(OText.seeCatalogue,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: OColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    )),
                            const Icon(
                              Icons.arrow_forward,
                              size: 24,
                              color: OColors.white,
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }

        final itemCount = cartController.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
        final logisticsRate =
            OLogisticsCalculator.quoteForCountry('Benin', itemCount: itemCount);
        final shippingFee = logisticsRate.fee;
        final subtotal = cartController.subtotal;
        final total = subtotal + shippingFee;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cartController.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartController.items[index];
                  return _buildCartItem(context, item, cartController);
                },
              ),
              const SizedBox(height: 24),
              _buildSummaryCard(subtotal, logisticsRate, total),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const CartCheckoutScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Valider le panier",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItemModel item, CartController controller) {
    final hasImage = item.image.isNotEmpty;
    final imageProvider = hasImage
        ? (item.image.startsWith('http')
            ? NetworkImage(item.image)
            : AssetImage(item.image) as ImageProvider)
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasImage
                ? Image(
                    image: imageProvider!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Iconsax.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Affichage des spécifications produit (tissu, broderie, accessoire)
                if (item.customizationDetails != null) ...[
                  const SizedBox(height: 5),
                  _buildCartItemSpecs(item.customizationDetails!),
                ],
                const SizedBox(height: 6),
                Text(
                  OLogisticsCalculator.formatFee(item.price),
                  style: const TextStyle(
                    color: OColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Row(
                children: [
                  _qtyButton(
                    icon: Iconsax.minus,
                    onTap: () async => await controller.updateQuantity(
                        item.productId, item.quantity - 1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _qtyButton(
                    icon: Iconsax.add,
                    onTap: () async => await controller.updateQuantity(
                        item.productId, item.quantity + 1),
                  ),
                ],
              ),
              IconButton(
                onPressed: () async =>
                    await controller.removeItem(item.productId),
                icon: const Icon(Iconsax.trash, color: Colors.red, size: 18),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: Colors.black87),
      ),
    );
  }

  /// Affiche les specs produit (tissu, broderie, accessoire) sous forme de chips
  Widget _buildCartItemSpecs(Map<String, dynamic> details) {
    final specs = <String>[];
    if (details['tissu'] != null && details['tissu'].toString().isNotEmpty) {
      specs.add(details['tissu'].toString());
    }
    if (details['broderie'] != null &&
        details['broderie'].toString().isNotEmpty) {
      specs.add(details['broderie'].toString());
    }
    if (details['accessoire'] != null &&
        details['accessoire'].toString().isNotEmpty) {
      specs.add(details['accessoire'].toString());
    }
    if (specs.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: specs
          .map((spec) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  spec,
                  style: const TextStyle(
                    fontSize: 10,
                    color: OColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryCard(
      double subtotal, LogisticsRate logisticsRate, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Sous-total', OLogisticsCalculator.formatFee(subtotal)),
          const SizedBox(height: 8),
          _summaryRow('Livraison (${logisticsRate.weightLabel})',
              OLogisticsCalculator.formatFee(logisticsRate.fee)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Iconsax.airplane, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Estimation Benin. Le pays au checkout peut ajuster ce tarif.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _summaryRow('Total', OLogisticsCalculator.formatFee(total),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? OColors.primary : Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
