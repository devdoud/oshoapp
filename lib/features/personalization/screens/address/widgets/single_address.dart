import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/models/address_model.dart';

class OSingleAddress extends StatelessWidget {
  const OSingleAddress({
    super.key,
    required this.address,
    required this.isSelected,
    required this.isDark,
    this.onTap,
  });

  final AddressModel address;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onTap;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: icon ──────────────────────────────────────
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
                    : (isDark
                        ? Colors.white38
                        : const Color(0xFFB0AAA2)),
              ),
            ),

            const SizedBox(width: 12),

            // ── Center: info ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + selected tick
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
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

                  // Address line
                  Text(
                    address.formattedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white54
                          : const Color(0xFF888480),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Phone + default badge
                  Row(
                    children: [
                      Icon(
                        Iconsax.call,
                        size: 12,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFFB0AAA2),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        address.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF888480),
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
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4A4542),
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
      ),
    );
  }
}
