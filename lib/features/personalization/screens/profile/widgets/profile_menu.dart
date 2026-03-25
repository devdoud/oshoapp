import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/sizes.dart';

class OProfileMenu extends StatelessWidget {
  const OProfileMenu({
    super.key, required this.icon, required this.title, required this.value, required this.onPressed,
  });

  final IconData icon;
  final String title, value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OSizes.spaceBtwItems / 1.5),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis,)),
            Expanded(flex: 5, child: Text(value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis,)),
            Expanded(child: Icon(icon, size: 18,))
          ],
        ),
      ),
    );
  }
}