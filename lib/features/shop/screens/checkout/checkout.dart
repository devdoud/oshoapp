import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/measurement/screens/onboarding/measurement_onboarding.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/shop/screens/checkout/payment.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = CustomizationController.instance;
    final addressController = Get.put(AddressController());
    final checkoutController = Get.put(CheckoutController());
    final measurementController = Get.put(MeasurementController());

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text('checkout_title'.tr,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Address Section ---
              Text('shipping_address'.tr,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildSavedAddressSection(
                  context, addressController, checkoutController),
              const SizedBox(height: 16),
              _buildAddressForm(context, controller, checkoutController),
              const SizedBox(height: 32),

              // --- 2. Measurement Section (Digital Tailor) ---
              Text("Mesures pour la confection",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Obx(() {
                if (measurementController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (measurementController.userMeasurements.isEmpty) {
                  return _buildNoMeasurementWidget(context);
                } else {
                  return _buildMeasurementSelector(
                      context, measurementController);
                }
              }),
              const SizedBox(height: 32),

              // --- 3. Order Summary (Items) ---
              Text("Résumé de la commande",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildOrderItem(context, controller),

              const SizedBox(height: 32),

              // --- 4. Billing Section ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 30,
                          offset: const Offset(0, 10))
                    ]),
                child: Column(
                  children: [
                    _buildBillingRow('subtotal'.tr,
                        '${controller.basePrice.value.toStringAsFixed(0)} FCFA'),
                    const SizedBox(height: 12),
                    _buildBillingRow('shipping_fee'.tr, '2.000 FCFA'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    _buildBillingRow('total'.tr,
                        '${(controller.basePrice.value + 2000).toStringAsFixed(0)} FCFA',
                        isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(OSizes.defaultPadding),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ]),
        child: ElevatedButton(
          onPressed: () {
            if (checkoutController.validateAddress()) {
              if (measurementController.selectedProfile.value == null) {
                _showMeasurementPrompt(context);
              } else {
                Get.to(() => PaymentScreen());
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: OColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Text("Continuer vers le paiement".tr,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    );
  }

  void _showMeasurementPrompt(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Mesures manquantes"),
        content: const Text(
            "Voulez-vous prendre vos mesures avec l'IA maintenant pour garantir un vêtement parfaitement ajusté ?"),
        actions: [
          TextButton(
            onPressed: () => Get.to(() => PaymentScreen()),
            child: const Text("Plus tard (Standard)",
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.to(() => const MeasurementOnboardingScreen(),
                      arguments: {'returnToCheckout': true})
                  ?.then((_) =>
                      MeasurementController.instance.fetchUserMeasurements());
            },
            style: ElevatedButton.styleFrom(backgroundColor: OColors.primary),
            child: const Text("Scanner maintenant"),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMeasurementWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Iconsax.info_circle, color: OColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Vous n'avez pas encore de mesures enregistrées. Pour un ajustement parfait, utilisez notre tailleur numérique.",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  Get.to(() => const MeasurementOnboardingScreen()),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: OColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Prendre mes mesures (IA)",
                  style: TextStyle(color: OColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementSelector(
      BuildContext context, MeasurementController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Profil de mesure sélectionné",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: controller.selectedProfile.value?.id,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.frame_1, color: OColors.primary),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items: controller.userMeasurements.map((profile) {
              return DropdownMenuItem(
                value: profile.id,
                child: Text("${profile.profileName} (${profile.gender})"),
              );
            }).toList(),
            onChanged: (value) {
              final selected =
                  controller.userMeasurements.firstWhere((p) => p.id == value);
              controller.selectedProfile.value = selected;
            },
          ),
        ],
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

  Widget _buildAddressForm(
      BuildContext context,
      CustomizationController controller,
      CheckoutController checkoutController) {
    return Column(
      children: [
        _buildTextField('full_name'.tr, Iconsax.user,
            checkoutController.fullNameController),
        const SizedBox(height: 16),
        _buildTextField('phone_number'.tr, Iconsax.call,
            checkoutController.phoneController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField('city'.tr, Iconsax.building,
                    checkoutController.cityController)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Quartier', Iconsax.location,
                    checkoutController.stateController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
            'address'.tr, Iconsax.home, checkoutController.addressController),
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

  Widget _buildOrderItem(
      BuildContext context, CustomizationController controller) {
    final isMale = controller.categoryType.value == 'homme';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: _isExpanded
                  ? OColors.primary.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isExpanded ? 0.08 : 0.02),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: controller.productImage.value.startsWith('http')
                          ? NetworkImage(controller.productImage.value)
                          : AssetImage(controller.productImage.value)
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.productName.value,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("Sur Mesure · Artisanal",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                  size: 20,
                  color: _isExpanded ? OColors.primary : Colors.grey,
                ),
              ],
            ),

            // Expanded Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildSummaryDetailRow(
                        "Tissu", controller.fabricName, Iconsax.shapes),
                    const SizedBox(height: 12),
                    _buildSummaryDetailRow(
                        isMale ? "Style / Broderie" : "Coupe / Style",
                        controller.getStep2Name(),
                        isMale ? Iconsax.magicpen : Iconsax.woman),
                    const SizedBox(height: 12),
                    _buildSummaryDetailRow(isMale ? "Finitions" : "Accessoires",
                        controller.getStep3Name(), Iconsax.add_circle),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: OColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Prix unitaire",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                          Text(
                              "${controller.basePrice.value.toStringAsFixed(0)} FCFA",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: OColors.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? Colors.black : Colors.grey[600])),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? OColors.primary : Colors.black)),
      ],
    );
  }
}
