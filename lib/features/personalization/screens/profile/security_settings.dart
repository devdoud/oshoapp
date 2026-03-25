import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const OAppBar(
        showBackArrow: true, 
        title: Text("Sécurité", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OSizes.defaultPadding),
        child: Column(
          children: [
            // Change Password
            _buildSecurityTile(
              context,
              icon: Iconsax.lock,
              title: "Changer le mot de passe",
              subtitle: "Mettre à jour votre mot de passe pour plus de sécurité",
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            // 2FA
            _buildSecurityTile(
              context,
              icon: Iconsax.scan_barcode,
              title: "Authentification à deux facteurs",
              subtitle: "Ajouter une couche de sécurité supplémentaire",
              onTap: () {},
              isToggle: true,
            ),
            const SizedBox(height: 16),

            // Devices
            _buildSecurityTile(
              context,
              icon: Iconsax.mobile,
              title: "Appareils connectés",
              subtitle: "Gérer les appareils connectés à votre compte",
              onTap: () {},
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.red),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Supprimer mon compte",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: Colors.red, size: 18),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isToggle = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: OColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: OColors.primary, size: 24),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 13)
          ),
        ),
        trailing: isToggle 
          ? Switch(value: false, onChanged: (val){}, activeColor: OColors.primary)
          : Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey[300]),
      ),
    );
  }
}
