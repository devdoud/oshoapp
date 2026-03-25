
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/utils/constants/colors.dart';

class OSettingMenuTile extends StatelessWidget {
  const OSettingMenuTile({super.key, required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title; 
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24, color: OColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium,),
      trailing: Icon(Icons.arrow_forward_ios_outlined, size: 24, color: OColors.primary,),
      onTap: onTap,
    );
  }
}