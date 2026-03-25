import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/widgets/single_address.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    final addressController = Get.put(AddressController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const OAppBar(
        showBackArrow: true,
        title: Text("Mes adresses",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (addressController.isLoading.value) {
          return const Center(child: OLoader());
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (selectMode)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: OColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Iconsax.info_circle, color: OColors.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Selectionnez l'adresse a utiliser pour cette commande.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (addressController.addresses.isEmpty)
              _buildEmptyState(context)
            else
              ...addressController.addresses.map((address) {
                final isSelected = selectMode
                    ? addressController.selectedAddress.value?.id == address.id
                    : address.isDefault;

                return OSingleAddress(
                  address: address,
                  isSelected: isSelected,
                  onTap: () async {
                    if (selectMode) {
                      await addressController.selectAddress(address);
                      Get.back(result: address);
                    } else {
                      await addressController.selectAddress(address,
                          makeDefault: true);
                    }
                  },
                );
              }).toList(),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ]),
        child: ElevatedButton(
          onPressed: () => Get.to(() => const AddNewAddressScreen()),
          style: ElevatedButton.styleFrom(
              backgroundColor: OColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: OColors.primary.withOpacity(0.4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Iconsax.add, color: Colors.white),
              SizedBox(width: 8),
              Text("Ajouter une nouvelle adresse",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Aucune adresse',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Ajoutez une adresse pour faciliter vos prochaines commandes.',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
