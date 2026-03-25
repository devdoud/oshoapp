import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OSingleAddress extends StatelessWidget {
  const OSingleAddress({
    super.key,
    required this.address,
    required this.isSelected,
    this.onTap,
  });

  final AddressModel address;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: OSizes.spaceBtwItems),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? OColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected ? OColors.primary : Colors.transparent,
              width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    address.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  const Icon(Iconsax.tick_circle5,
                      color: OColors.primary, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.location, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.formattedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.call, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  address.phone,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: OColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Par defaut',
                      style: TextStyle(
                          color: OColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
