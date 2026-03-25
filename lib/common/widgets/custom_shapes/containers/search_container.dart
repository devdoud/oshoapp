import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/device/device_utility.dart';


class OSearchContainer extends StatelessWidget {
  const OSearchContainer({
    super.key, required this.text, this.icon = Iconsax.search_normal, this.showBackground = true, this.showBorder = false, this.onTap,
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ODeviceUtils.getScreenWidth(context) * 0.75,
        padding: const EdgeInsets.all(OSizes.md),
        decoration: BoxDecoration(
          color: showBackground ? Color(0xFFF2F2F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(OSizes.cardRadiusLg),
          border: showBorder ? Border.all(color: Colors.grey) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black,),
            const SizedBox(width: OSizes.spaceBtwItems / 2,),
            Text( text, style: Theme.of(context).textTheme.bodySmall,)
          ],
        ),
      
      ),
    );
  }
}