import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'payment.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class CartCheckoutScreen extends StatelessWidget {
  final double totalAmount;
  final double shippingFee;

  const CartCheckoutScreen({
    super.key,
    required this.totalAmount,
    required this.shippingFee,
  });

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());
    final checkoutController = Get.put(CheckoutController());
    final cartController = CartController.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text('Livraison',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OSizes.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adresse de livraison',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSavedAddressSection(
                context, addressController, checkoutController),
            const SizedBox(height: 16),
            _buildAddressForm(checkoutController),
            const SizedBox(height: 28),

            Text('Résumé du panier',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
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
                  ...cartController.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.title} x${item.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${(item.price * item.quantity).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  _summaryRow('Sous-total',
                      '${cartController.subtotal.toStringAsFixed(0)} FCFA'),
                  const SizedBox(height: 8),
                  _summaryRow('Livraison',
                      '${shippingFee.toStringAsFixed(0)} FCFA'),
                  const SizedBox(height: 8),
                  _summaryRow('Total',
                      '${totalAmount.toStringAsFixed(0)} FCFA',
                      isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(OSizes.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            if (checkoutController.validateAddress()) {
              Get.to(() => PaymentScreen(
                    isCart: true,
                    totalAmount: totalAmount,
                  ));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: OColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Continuer vers le paiement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSavedAddressSection(
      BuildContext context,
      AddressController addressController,
      CheckoutController checkoutController) {
    return Obx(() {
      if (addressController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: OLoader()),
        );
      }

      final selected = addressController.selectedAddress.value;
      if (selected == null) {
        return _buildNoSavedAddress(context, addressController, checkoutController);
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.location, color: OColors.primary, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Adresse enregistree',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const UserAddressScreen(selectMode: true))
                        ?.then((_) {
                      final updated = addressController.selectedAddress.value;
                      if (updated != null) {
                        checkoutController.setAddress(updated, overwrite: true);
                      }
                    });
                  },
                  child: const Text('Changer'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(selected.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(selected.formattedAddress,
                style: TextStyle(color: Colors.grey[600], height: 1.4)),
            const SizedBox(height: 6),
            Text(selected.phone,
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ],
        ),
      );
    });
  }

  Widget _buildNoSavedAddress(
      BuildContext context,
      AddressController addressController,
      CheckoutController checkoutController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aucune adresse enregistree',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Ajoutez une adresse pour remplir plus vite votre commande.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Get.to(() => const AddNewAddressScreen())?.then((_) {
                final updated = addressController.selectedAddress.value;
                if (updated != null) {
                  checkoutController.setAddress(updated, overwrite: true);
                }
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: OColors.primary),
            ),
            icon: const Icon(Iconsax.add, color: OColors.primary, size: 18),
            label: const Text('Ajouter une adresse',
                style: TextStyle(color: OColors.primary)),
          ),
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

  Widget _buildAddressForm(CheckoutController checkoutController) {
    return Column(
      children: [
        _buildTextField('Nom complet', Iconsax.user,
            checkoutController.fullNameController),
        const SizedBox(height: 16),
        _buildTextField('Telephone', Iconsax.call,
            checkoutController.phoneController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField('Ville', Iconsax.building,
                    checkoutController.cityController)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Quartier', Iconsax.location,
                    checkoutController.stateController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Adresse', Iconsax.home,
            checkoutController.addressController),
      ],
    );
  }

  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ]),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: OColors.primary)),
            enabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }
}
