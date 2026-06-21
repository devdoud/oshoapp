import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/features/personalization/screens/address/add_new_address.dart';
import 'package:osho/utils/constants/colors.dart';

class OSingleAddress extends StatelessWidget {
  const OSingleAddress({
    super.key,
    required this.address,
    required this.isSelected,
    required this.isDark,
    this.onTap,
    this.showActions = false,
  });

  final AddressModel address;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onTap;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isSelected
        ? (isDark ? Colors.white.withValues(alpha: 0.60) : const Color(0xFF1A1A1A))
        : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFEEEBE6));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFF1A1A1A).withValues(alpha: 0.04))
              : cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icône ───────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 1),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFF1A1A1A).withValues(alpha: 0.07))
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF3F0EC)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Iconsax.location,
                    size: 16,
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                        : (isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Infos ────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        address.formattedAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : const Color(0xFF888480),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Iconsax.call, size: 12,
                              color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                          const SizedBox(width: 5),
                          Text(
                            address.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : const Color(0xFF888480),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFF1A1A1A).withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Principale',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF4A4542),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Actions (modifier / supprimer) ───────────────────────
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      icon: Iconsax.edit,
                      label: 'Modifier',
                      isDark: isDark,
                      onTap: () => Get.to(
                        () => AddNewAddressScreen(existing: address),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _deleteBtn(context, isDark),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF4F1EC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: OColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: OColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteBtn(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
        ),
        child: Icon(
          Iconsax.trash,
          size: 15,
          color: Colors.red.withValues(alpha: 0.70),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Supprimer cette adresse',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer l\'adresse de "${address.fullName}" ?',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : const Color(0xFF888480),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Annuler',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF888480),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (address.id != null) {
                AddressController.instance.deleteAddress(address.id!);
              }
            },
            child: const Text('Supprimer',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
