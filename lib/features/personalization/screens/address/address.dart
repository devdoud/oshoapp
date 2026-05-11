import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/features/personalization/screens/address/widgets/single_address.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final addressController = Get.put(AddressController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            _buildHeader(isDark),

            // ── Body ──────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (addressController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: OColors.primary),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    // Select mode banner
                    if (selectMode) ...[
                      _buildSelectBanner(isDark),
                      const SizedBox(height: 16),
                    ],

                    // Empty state
                    if (addressController.addresses.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ...addressController.addresses.map((address) {
                        final isSelected = selectMode
                            ? addressController.selectedAddress.value?.id ==
                                address.id
                            : address.isDefault;

                        return OSingleAddress(
                          address: address,
                          isSelected: isSelected,
                          isDark: isDark,
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
                      }),
                  ],
                );
              }),
            ),

            // ── Bottom bar ─────────────────────────────────────────────
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFEEEBE6),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Mes adresses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Select mode banner ────────────────────────────────────────────────────────

  Widget _buildSelectBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : OColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : OColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: 16,
            color: isDark ? Colors.white54 : OColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sélectionnez l\'adresse à utiliser pour cette commande.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : const Color(0xFF4A4542),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF3F0EC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.location,
              size: 28,
              color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune adresse',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ajoutez une adresse pour faciliter\nvos prochaines commandes.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : const Color(0xFF888480),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => Get.to(() => const AddNewAddressScreen()),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.add,
                  size: 16,
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                ),
                const SizedBox(width: 7),
                Text(
                  'Nouvelle adresse',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
