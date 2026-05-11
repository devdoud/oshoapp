import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/measurement/screens/measurement_tutorial.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:osho/features/shop/screens/checkout/payment.dart';
import 'package:osho/features/shop/screens/checkout/widgets/logistics_rates_card.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  late final AddressController addressController;
  late final CheckoutController checkoutController;
  late final MeasurementController measurementController;

  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController());
    checkoutController = Get.put(CheckoutController());
    measurementController = Get.put(MeasurementController());
    checkoutController.countryController.addListener(_refreshLogistics);
  }

  @override
  void dispose() {
    checkoutController.countryController.removeListener(_refreshLogistics);
    super.dispose();
  }

  void _refreshLogistics() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final cartController = CartController.instance;
    final logisticsRate = checkoutController.cartLogisticsRate;
    final shippingFee = logisticsRate.fee;
    final totalAmount = cartController.subtotal + shippingFee;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? Colors.white : OColors.primary),
          ),
        ),
        title: Text(
          'Livraison',
          style: TextStyle(
            color: isDark ? Colors.white : OColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                Iconsax.location, 'Adresse de livraison', isDark),
            const SizedBox(height: 16),
            _buildSavedAddressSection(
                context, addressController, checkoutController, isDark),
            const SizedBox(height: 12),
            _buildAddressFormCard(checkoutController, isDark),
            const SizedBox(height: 12),
            LogisticsRatesCard(currentRate: logisticsRate),
            const SizedBox(height: 32),

            _buildSectionHeader(
                Iconsax.shopping_bag, 'Résumé du panier', isDark),
            const SizedBox(height: 16),
            _buildCartSummaryCard(cartController, logisticsRate,
                shippingFee, totalAmount, isDark),
            const SizedBox(height: 32),

            _buildSectionHeader(
                Iconsax.frame_1, 'Mesures pour la confection', isDark),
            const SizedBox(height: 16),
            Obx(() {
              if (measurementController.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: OColors.primary));
              }
              if (measurementController.userMeasurements.isEmpty) {
                return _buildNoMeasurementWidget(context, isDark);
              }
              return _buildMeasurementSelector(context, isDark);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(totalAmount, isDark, () {
        if (!checkoutController.validateAddress()) return;
        if (measurementController.selectedProfile.value == null) {
          OLoaders.warningSnackBar(
            title: 'Mesures manquantes',
            message: 'Sélectionnez un profil de mesure pour continuer.',
          );
          return;
        }
        Get.to(() =>
            PaymentScreen(isCart: true, totalAmount: totalAmount));
      }),
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(
      IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: OColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : OColors.primary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      double totalAmount, bool isDark, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total à payer',
                  style:
                      TextStyle(color: Colors.grey[500], fontSize: 13)),
              Text(
                OLogisticsCalculator.formatFee(totalAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : OColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: OColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text(
                'Passer au paiement',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Address ──────────────────────────────────────────────────────────────

  Widget _buildSavedAddressSection(
    BuildContext context,
    AddressController addressController,
    CheckoutController checkoutController,
    bool isDark,
  ) {
    return Obx(() {
      if (addressController.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: OLoader()),
        );
      }

      final selected = addressController.selectedAddress.value;
      if (selected == null) {
        return _buildNoSavedAddress(
            context, addressController, checkoutController, isDark);
      }

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            left: BorderSide(color: OColors.primary, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.location,
                  color: OColors.primary, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selected.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(selected.formattedAddress,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white60
                              : Colors.grey[600],
                          fontSize: 13,
                          height: 1.4)),
                  const SizedBox(height: 4),
                  Text(selected.phone,
                      style: TextStyle(
                          color: isDark
                              ? Colors.white60
                              : Colors.grey[600],
                          fontSize: 13)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Get.to(
                        () => const UserAddressScreen(selectMode: true))
                    ?.then((_) {
                  final updated =
                      addressController.selectedAddress.value;
                  if (updated != null) {
                    checkoutController.setAddress(updated,
                        overwrite: true);
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Changer',
                  style: TextStyle(
                      color: OColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNoSavedAddress(
    BuildContext context,
    AddressController addressController,
    CheckoutController checkoutController,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.location,
                color: Colors.grey[400], size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Aucune adresse enregistrée',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Get.to(() => const AddNewAddressScreen())?.then((_) {
                final updated =
                    addressController.selectedAddress.value;
                if (updated != null) {
                  checkoutController.setAddress(updated,
                      overwrite: true);
                }
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: OColors.primary),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ajouter',
                style: TextStyle(
                    color: OColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressFormCard(
      CheckoutController checkoutController, bool isDark) {
    final dividerColor =
        isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEEEEEE);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildFormField('Nom complet', Iconsax.user,
              checkoutController.fullNameController, isDark,
              isFirst: true),
          Divider(height: 1, color: dividerColor, indent: 54),
          _buildFormField('Téléphone', Iconsax.call,
              checkoutController.phoneController, isDark),
          Divider(height: 1, color: dividerColor, indent: 54),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildFormField('Ville', Iconsax.building,
                      checkoutController.cityController, isDark,
                      rounded: false),
                ),
                VerticalDivider(width: 1, color: dividerColor),
                Expanded(
                  child: _buildFormField('Quartier', Iconsax.location,
                      checkoutController.stateController, isDark,
                      rounded: false),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor, indent: 54),
          _buildFormField('Adresse', Iconsax.home,
              checkoutController.addressController, isDark),
          Divider(height: 1, color: dividerColor, indent: 54),
          _buildFormField('Pays', Iconsax.global,
              checkoutController.countryController, isDark,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isDark, {
    bool isFirst = false,
    bool isLast = false,
    bool rounded = true,
  }) {
    BorderRadius radius = BorderRadius.zero;
    if (rounded) {
      if (isFirst && isLast) {
        radius = BorderRadius.circular(20);
      } else if (isFirst) {
        radius =
            const BorderRadius.vertical(top: Radius.circular(20));
      } else if (isLast) {
        radius =
            const BorderRadius.vertical(bottom: Radius.circular(20));
      }
    }

    return ClipRRect(
      borderRadius: radius,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : OColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey[400],
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon,
              color: isDark ? Colors.white38 : Colors.grey[400],
              size: 18),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          filled: true,
          fillColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ─── Cart summary ─────────────────────────────────────────────────────────

  Widget _buildCartSummaryCard(
    CartController cartController,
    LogisticsRate logisticsRate,
    double shippingFee,
    double totalAmount,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          ...List.generate(cartController.items.length, (i) {
            final item = cartController.items[i];
            final isLast = i == cartController.items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Qté: ${item.quantity}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        OLogisticsCalculator.formatFee(item.price * item.quantity),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.grey.withValues(alpha: 0.08),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
          Divider(
              color: Colors.grey.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 14),
          _summaryRow(
              'Sous-total',
              OLogisticsCalculator.formatFee(cartController.subtotal),
              isDark),
          const SizedBox(height: 8),
          _summaryRow(
              'Livraison (${logisticsRate.zone})',
              OLogisticsCalculator.formatFee(shippingFee),
              isDark),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text(
                  OLogisticsCalculator.formatFee(totalAmount),
                  style: const TextStyle(
                    color: OColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Measurements ─────────────────────────────────────────────────────────

  Widget _buildNoMeasurementWidget(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: OColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.info_circle,
                    color: OColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Aucune mesure enregistrée. Ajoutez un profil pour que le tailleur confectionne vos articles.",
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Get.to(() => const MeasurementTutorialScreen(
                        allowBack: true,
                        returnToCheckout: true,
                      ))?.then((_) =>
                      measurementController.fetchUserMeasurements()),
              style: ElevatedButton.styleFrom(
                backgroundColor: OColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Iconsax.scan, size: 18),
              label: const Text('Prendre mes mesures',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementSelector(
      BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.frame_1,
                    color: OColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Profil de mesure',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue:
                measurementController.selectedProfile.value?.id,
            isExpanded: true,
            dropdownColor:
                isDark ? const Color(0xFF2A2A2A) : Colors.white,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.frame_1,
                  color: OColors.primary, size: 18),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF6F6F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: OColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
            ),
            items:
                measurementController.userMeasurements.map((profile) {
              return DropdownMenuItem(
                value: profile.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        '${profile.profileName} (${profile.gender})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (profile.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              OColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Principal',
                            style: TextStyle(
                                fontSize: 10,
                                color: OColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              final selected = measurementController.userMeasurements
                  .firstWhere((p) => p.id == value);
              measurementController.selectedProfile.value = selected;
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
