import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/measurement/screens/measurement_tutorial.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/shop/screens/checkout/widgets/logistics_rates_card.dart';
import 'package:osho/features/shop/screens/checkout/payment.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isExpanded = false;
  late final AddressController addressController;
  late final CheckoutController checkoutController;

  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController());
    checkoutController = Get.put(CheckoutController());
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
    final controller = CustomizationController.instance;
    final measurementController = Get.put(MeasurementController());
    final logisticsRate = checkoutController.currentLogisticsRate;
    final shippingFee = logisticsRate.fee;
    final totalAmount = controller.basePrice.value + shippingFee;

    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF7F4F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(left: 16),
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
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
        title: Text(
          'Récapitulatif',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Étape 1/2',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: OColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Livraison ───────────────────────────────────────────────
              _sectionLabel('Livraison'),
              _buildSavedAddressSection(
                  context, addressController, checkoutController, isDark),
              const SizedBox(height: 10),
              _buildAddressFormCard(context, checkoutController, isDark),
              const SizedBox(height: 10),
              LogisticsRatesCard(currentRate: logisticsRate),

              const SizedBox(height: 28),

              // ── Taille & Mesures ────────────────────────────────────────
              _sectionLabel('Taille & Mesures'),
              Obx(() {
                if (controller.standardTopSize.value.isNotEmpty) {
                  return _buildStandardSizeCard(context, controller, isDark);
                }
                if (measurementController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (measurementController.userMeasurements.isEmpty) {
                  return _buildNoMeasurementWidget(context, isDark);
                }
                final isCouple = controller.categoryType.value
                    .toLowerCase()
                    .contains('couple');
                return _buildMeasurementSelector(
                    context, measurementController, isDark,
                    isCouple: isCouple);
              }),

              const SizedBox(height: 28),

              // ── Ma Commande ─────────────────────────────────────────────
              _sectionLabel('Ma Commande'),
              _buildOrderItem(context, controller, isDark),

              const SizedBox(height: 28),

              // ── Récapitulatif financier ──────────────────────────────────
              _sectionLabel('Récapitulatif'),
              _buildBillingCard(
                  controller, logisticsRate, shippingFee, totalAmount, isDark),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.shield_tick,
                        size: 13, color: Color(0xFFD0CCC8)),
                    const SizedBox(width: 6),
                    const Text(
                      'Paiement sécurisé · Confection artisanale',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD0CCC8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(totalAmount, isDark, () {
        if (checkoutController.validateAddress()) {
          final hasStandard = controller.standardTopSize.value.isNotEmpty &&
              controller.standardBottomSize.value.isNotEmpty;
          final hasProfile =
              measurementController.selectedProfile.value != null;
          if (!hasStandard && !hasProfile) {
            _showMeasurementPrompt(context);
            return;
          }
          final isCouple = controller.categoryType.value
              .toLowerCase()
              .contains('couple');
          if (isCouple && hasStandard) {
            final top2 = controller.standardTopSize2.value;
            final bot2 = controller.standardBottomSize2.value;
            if (top2.isEmpty || bot2.isEmpty) {
              OLoaders.warningSnackBar(
                title: 'Tailles manquantes',
                message: 'Veuillez renseigner les tailles du 2ème partenaire.',
              );
              return;
            }
          }
          if (isCouple &&
              !hasStandard &&
              measurementController.selectedProfile2.value == null) {
            OLoaders.warningSnackBar(
              title: 'Profil manquant',
              message:
                  'Veuillez sélectionner un profil pour le 2ème partenaire.',
            );
            return;
          }
          Get.to(() => PaymentScreen(totalAmount: totalAmount));
        }
      }),
    );
  }

  // ─── Section label ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: OColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF8A8480),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(
      double totalAmount, bool isDark, VoidCallback onTap) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 32,
            offset: const Offset(0, -8),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total à payer',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                OLogisticsCalculator.formatFee(totalAmount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 17),
                decoration: BoxDecoration(
                  color: OColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: OColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Passer au paiement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Iconsax.arrow_right_3, color: Colors.white, size: 16),
                  ],
                ),
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

      final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.location,
                  color: OColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    selected.formattedAddress,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white60
                          : const Color(0xFF6B6560),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected.phone,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white60
                          : const Color(0xFF6B6560),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Get.to(() => const UserAddressScreen(selectMode: true))
                    ?.then((_) {
                  final updated =
                      addressController.selectedAddress.value;
                  if (updated != null) {
                    checkoutController.setAddress(updated,
                        overwrite: true);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Changer',
                  style: TextStyle(
                    color: OColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEBE6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.location, color: Colors.grey[400], size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Aucune adresse enregistrée',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => const AddNewAddressScreen())?.then((_) {
                final updated =
                    addressController.selectedAddress.value;
                if (updated != null) {
                  checkoutController.setAddress(updated,
                      overwrite: true);
                }
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Ajouter',
                style: TextStyle(
                  color: OColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressFormCard(
    BuildContext context,
    CheckoutController checkoutController,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor =
        isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF0EDEA);
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
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
          _buildFormField('full_name'.tr, Iconsax.user,
              checkoutController.fullNameController, isDark,
              isFirst: true),
          Divider(height: 1, color: dividerColor, indent: 54),
          _buildFormField('phone_number'.tr, Iconsax.call,
              checkoutController.phoneController, isDark),
          Divider(height: 1, color: dividerColor, indent: 54),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildFormField('city'.tr, Iconsax.building,
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
          _buildFormField('address'.tr, Iconsax.home,
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
        radius = const BorderRadius.vertical(top: Radius.circular(20));
      } else if (isLast) {
        radius = const BorderRadius.vertical(bottom: Radius.circular(20));
      }
    }

    return ClipRRect(
      borderRadius: radius,
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFFD0CCC8),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon,
              color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
              size: 17),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // ─── Measurements / Size ──────────────────────────────────────────────────

  Widget _buildNoMeasurementWidget(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OColors.primary.withValues(alpha: 0.15)),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.info_circle,
                    color: OColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Aucune mesure enregistrée. Prenez vos mesures avec notre tailleur numérique pour un ajustement parfait.",
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF6B6560)),
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
                      MeasurementController.instance
                          .fetchUserMeasurements()),
              style: ElevatedButton.styleFrom(
                backgroundColor: OColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Iconsax.scan, size: 17),
              label: const Text('Prendre mes mesures (IA)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showMeasurementPrompt(context),
              child: const Text(
                'Choisir une taille standard',
                style: TextStyle(
                  color: Color(0xFF888480),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardSizeCard(
      BuildContext context, CustomizationController controller, bool isDark) {
    final top = controller.standardTopSize.value;
    final bottom = controller.standardBottomSize.value;
    final top2 = controller.standardTopSize2.value;
    final bottom2 = controller.standardBottomSize2.value;
    final recipient = controller.sizeRecipientName.value;
    final isCouple = top2.isNotEmpty;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isCouple ? Iconsax.profile_2user : Iconsax.frame_1,
                  color: OColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCouple
                          ? 'Commande couple'
                          : 'Taille standard',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      isCouple
                          ? 'Deux partenaires'
                          : 'Taille prête-à-porter',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFB0AAA2)),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.standardTopSize.value = '';
                  controller.standardBottomSize.value = '';
                  controller.sizeRecipientName.value = '';
                  controller.standardTopSize2.value = '';
                  controller.standardBottomSize2.value = '';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4E0DA)),
                  ),
                  child: const Text(
                    'Modifier',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B6560),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF0EDEA)),
          const SizedBox(height: 14),

          // ── Size display ──
          if (isCouple) ...[
            _partnerSizeRow('① Partenaire 1', top, bottom, isDark),
            const SizedBox(height: 12),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: const Color(0xFFF0EDEA),
            ),
            const SizedBox(height: 12),
            _partnerSizeRow('② Partenaire 2', top2, bottom2, isDark),
          ] else ...[
            Row(children: [
              Expanded(child: _buildSizeChip('Haut', top, isDark)),
              const SizedBox(width: 10),
              Expanded(child: _buildSizeChip('Bas', bottom, isDark)),
            ]),
            if (recipient.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Iconsax.user,
                      size: 12, color: Colors.grey[500]),
                ),
                const SizedBox(width: 8),
                Text(
                  'Pour : $recipient',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B6560)),
                ),
              ]),
            ],
          ],
        ],
      ),
    );
  }

  Widget _partnerSizeRow(
      String label, String top, String bottom, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B6560),
          ),
        ),
        const Spacer(),
        _buildSizeChip('Haut', top, isDark),
        const SizedBox(width: 8),
        _buildSizeChip('Bas', bottom, isDark),
      ],
    );
  }

  Widget _buildSizeChip(String label, String size, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: OColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB0AAA2),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            size,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: OColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementSelector(
    BuildContext context,
    MeasurementController controller,
    bool isDark, {
    bool isCouple = false,
  }) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Iconsax.magic_star,
                    color: OColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCouple ? 'Sur Mesure — Couple' : 'Sur Mesure',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Text(
                    'Ajustement artisanal',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFFB0AAA2)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isCouple) ...[
            _buildProfileLabel('Partenaire 1', isDark),
            const SizedBox(height: 6),
          ],
          _buildProfileDropdown(
            context,
            controller,
            isSecond: false,
            hint: isCouple ? 'Profil partenaire 1' : 'Choisir un profil',
            isDark: isDark,
          ),
          if (isCouple) ...[
            const SizedBox(height: 14),
            _buildProfileLabel('Partenaire 2', isDark),
            const SizedBox(height: 6),
            _buildProfileDropdown(
              context,
              controller,
              isSecond: true,
              hint: 'Profil partenaire 2',
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white54 : const Color(0xFF888480),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildProfileDropdown(
    BuildContext context,
    MeasurementController controller, {
    required bool isSecond,
    required String hint,
    required bool isDark,
  }) {
    final currentId = isSecond
        ? controller.selectedProfile2.value?.id
        : controller.selectedProfile.value?.id;

    return DropdownButtonFormField<String>(
      initialValue: currentId,
      isExpanded: true,
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(
          isSecond ? Iconsax.woman : Iconsax.man,
          color: OColors.primary,
          size: 17,
        ),
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF7F4F0),
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
          borderSide:
              const BorderSide(color: OColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey[400], fontSize: 13),
      ),
      items: controller.userMeasurements.map((profile) {
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
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (profile.isPrimary) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: OColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(
                      fontSize: 10,
                      color: OColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        final selected = controller.userMeasurements
            .firstWhere((p) => p.id == value);
        if (isSecond) {
          controller.selectedProfile2.value = selected;
        } else {
          controller.selectedProfile.value = selected;
        }
      },
    );
  }

  // ─── Order summary ────────────────────────────────────────────────────────

  Widget _buildOrderItem(
      BuildContext context, CustomizationController controller, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final days = controller.estimatedDays.value;
    final isMale = controller.categoryType.value == 'homme';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: _isExpanded
              ? Border.all(
                  color: OColors.primary.withValues(alpha: 0.2))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: _isExpanded ? 0.06 : 0.04),
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
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFF4F1EC),
                    child: controller.productImage.value.startsWith('http')
                        ? Image.network(
                            controller.productImage.value,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Iconsax.image,
                                color: Color(0xFFD0CCC8),
                                size: 28),
                          )
                        : Image.asset(controller.productImage.value,
                            fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.productName.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Dynamic size badge
                      Obx(() {
                        final t1 = controller.standardTopSize.value;
                        final b1 = controller.standardBottomSize.value;
                        final t2 = controller.standardTopSize2.value;
                        final b2 = controller.standardBottomSize2.value;
                        final String label;
                        if (t1.isEmpty) {
                          label = '✦  Sur Mesure · Artisanal';
                        } else if (t2.isNotEmpty) {
                          label = '① $t1 / $b1   ② $t2 / $b2';
                        } else {
                          label = '$t1 / $b1';
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                OColors.primary.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: OColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }),

                      // Estimated days
                      if (days > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.timer_1,
                                size: 11, color: Colors.grey[500]),
                            const SizedBox(width: 5),
                            Text(
                              'Confection : $days–${days + 3} jours',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Iconsax.arrow_up_2
                      : Iconsax.arrow_down_1,
                  size: 18,
                  color: _isExpanded
                      ? OColors.primary
                      : Colors.grey[400],
                ),
              ],
            ),

            // Expandable details
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    Container(height: 1, color: const Color(0xFFF0EDEA)),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Tissu',
                        controller.fabricName,
                        Iconsax.shapes,
                        isDark),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      isMale ? 'Style / Broderie' : 'Coupe / Style',
                      controller.getStep2Name(),
                      isMale ? Iconsax.magicpen : Iconsax.woman,
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      isMale ? 'Finitions' : 'Accessoires',
                      controller.getStep3Name(),
                      Iconsax.add_circle,
                      isDark,
                    ),
                    if (days > 0) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        'Délai de confection',
                        '$days–${days + 3} jours ouvrés',
                        Iconsax.timer_1,
                        isDark,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: OColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Prix unitaire',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF6B6560),
                            ),
                          ),
                          Text(
                            OLogisticsCalculator.formatFee(controller.basePrice.value),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: OColors.primary,
                              fontSize: 14,
                            ),
                          ),
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

  Widget _buildDetailRow(
      String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : const Color(0xFF888480),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // ─── Billing ──────────────────────────────────────────────────────────────

  Widget _buildBillingCard(
    CustomizationController controller,
    LogisticsRate logisticsRate,
    double shippingFee,
    double totalAmount,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
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
          _buildBillingRow(
            'Produit',
            OLogisticsCalculator.formatFee(controller.basePrice.value),
            isDark,
          ),
          const SizedBox(height: 10),
          _buildBillingRow(
            'Livraison (${logisticsRate.zone})',
            OLogisticsCalculator.formatFee(shippingFee),
            isDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(height: 1, color: const Color(0xFFF0EDEA)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  OColors.primary.withValues(alpha: 0.10),
                  OColors.primary.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: OColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL À PAYER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Color(0xFFB0AAA2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Livraison incluse',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB0AAA2),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Text(
                  OLogisticsCalculator.formatFee(totalAmount),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: OColors.primary,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : const Color(0xFF888480),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  void _showMeasurementPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MeasurementPromptBottomSheet(),
    );
  }
}

// ─── Measurement prompt bottom sheet ──────────────────────────────────────────

class _MeasurementPromptBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
          OSizes.defaultPadding,
          OSizes.defaultPadding,
          OSizes.defaultPadding,
          32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Iconsax.frame_1,
                size: 48, color: OColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            "Mesures pour la confection",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Pour vous garantir un vêtement parfaitement ajusté, nous vous recommandons de prendre vos mesures avec notre tailleur numérique.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.to(() => const MeasurementTutorialScreen(
                      allowBack: true,
                      returnToCheckout: true,
                    ))?.then((_) {
                  MeasurementController.instance
                      .fetchUserMeasurements();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              icon: const Icon(Iconsax.scan,
                  color: Colors.white, size: 18),
              label: const Text('Prendre mes mesures (IA)',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.back();
                Get.bottomSheet(
                  const _StandardSizePickerSheet(),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              },
              child: Text(
                'Choisir une taille standard',
                style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Standard size picker sheet ───────────────────────────────────────────────

class _StandardSizePickerSheet extends StatefulWidget {
  const _StandardSizePickerSheet();

  @override
  State<_StandardSizePickerSheet> createState() =>
      _StandardSizePickerSheetState();
}

class _StandardSizePickerSheetState
    extends State<_StandardSizePickerSheet> {
  String _gender = 'femme';
  String? _topSize;
  String? _bottomSize;

  String _gender2 = 'homme';
  String? _topSize2;
  String? _bottomSize2;

  static const _topSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _bottomSizes = [
    '30', '32', '34', '36', '38', '40', '42', '44', '46', '48'
  ];

  bool get _isCouple => CustomizationController.instance.categoryType.value
      .toLowerCase()
      .contains('couple');

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final couple = _isCouple;
    final canConfirm = _topSize != null &&
        _bottomSize != null &&
        (!couple || (_topSize2 != null && _bottomSize2 != null));

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E4DE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  couple
                      ? 'Tailles standards — Couple'
                      : 'Taille standard',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),

              if (couple) _partnerLabel('Partenaire 1', '1', isDark),
              if (couple) const SizedBox(height: 14),

              const Text('GENRE', style: _labelStyle),
              const SizedBox(height: 8),
              _genderRow(_gender, (v) => setState(() {
                    _gender = v;
                    _topSize = null;
                    _bottomSize = null;
                  })),
              const SizedBox(height: 14),

              const Text('TAILLE HAUT', style: _labelStyle),
              const SizedBox(height: 10),
              _sizeGrid(_topSizes, _topSize,
                  (v) => setState(() => _topSize = v)),
              const SizedBox(height: 14),

              const Text('TAILLE BAS — PANTALON', style: _labelStyle),
              const SizedBox(height: 10),
              _sizeGrid(_bottomSizes, _bottomSize,
                  (v) => setState(() => _bottomSize = v)),

              if (couple) ...[
                const SizedBox(height: 22),
                Container(height: 1, color: const Color(0xFFEEEBE6)),
                const SizedBox(height: 22),

                _partnerLabel('Partenaire 2', '2', isDark),
                const SizedBox(height: 14),

                const Text('GENRE', style: _labelStyle),
                const SizedBox(height: 8),
                _genderRow(_gender2, (v) => setState(() {
                      _gender2 = v;
                      _topSize2 = null;
                      _bottomSize2 = null;
                    })),
                const SizedBox(height: 14),

                const Text('TAILLE HAUT', style: _labelStyle),
                const SizedBox(height: 10),
                _sizeGrid(_topSizes, _topSize2,
                    (v) => setState(() => _topSize2 = v)),
                const SizedBox(height: 14),

                const Text('TAILLE BAS — PANTALON', style: _labelStyle),
                const SizedBox(height: 10),
                _sizeGrid(_bottomSizes, _bottomSize2,
                    (v) => setState(() => _bottomSize2 = v)),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () {
                          final c = CustomizationController.instance;
                          c.standardTopSize.value = _topSize!;
                          c.standardBottomSize.value = _bottomSize!;
                          c.sizeRecipientName.value = '';
                          if (couple) {
                            c.standardTopSize2.value = _topSize2!;
                            c.standardBottomSize2.value = _bottomSize2!;
                            c.sizeGender2.value = _gender2;
                          } else {
                            c.standardTopSize2.value = '';
                            c.standardBottomSize2.value = '';
                          }
                          Get.back();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OColors.primary,
                    disabledBackgroundColor: const Color(0xFFD0CCC8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Confirmer',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: Color(0xFFB0AAA2),
  );

  Widget _partnerLabel(String label, String number, bool isDark) {
    return Row(children: [
      Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
            color: OColors.primary, shape: BoxShape.circle),
        child: Center(
          child: Text(number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
        ),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
    ]);
  }

  Widget _genderRow(String current, ValueChanged<String> onChange) {
    return Row(children: [
      _genderChip('Femme', 'femme', current, onChange),
      const SizedBox(width: 10),
      _genderChip('Homme', 'homme', current, onChange),
    ]);
  }

  Widget _genderChip(String label, String value, String current,
      ValueChanged<String> onChange) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? OColors.primary.withValues(alpha: 0.08)
                : const Color(0xFFF8F6F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? OColors.primary.withValues(alpha: 0.3)
                  : const Color(0xFFEEEBE6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? OColors.primary
                    : const Color(0xFF4A4542),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sizeGrid(
      List<String> sizes, String? selected, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((s) {
        final isSelected = s == selected;
        return GestureDetector(
          onTap: () => onTap(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? OColors.primary.withValues(alpha: 0.10)
                  : const Color(0xFFF4F1EC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? OColors.primary.withValues(alpha: 0.55)
                    : const Color(0xFFE4E0DA),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? OColors.primary
                    : const Color(0xFF6B6560),
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
