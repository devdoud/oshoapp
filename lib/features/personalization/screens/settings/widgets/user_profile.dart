import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/utils/constants/colors.dart';

class OUserProfile extends StatelessWidget {
  const OUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Obx(() {
      final user         = controller.user.value;
      final networkImage = user.profilePicture;
      final name         = user.fullName.trim();

      return Column(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: OColors.primary.withValues(alpha: 0.07),
                border: Border.all(
                  color: OColors.primary.withValues(alpha: 0.18),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: networkImage.isNotEmpty
                    ? Image.network(
                        networkImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(name, 80),
                      )
                    : _placeholder(name, 80),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? 'Bienvenue !' : name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email.isEmpty ? 'Connectez-vous' : user.email,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          if (user.email.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => Get.to(() => const LoginScreen()),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(color: OColors.primary),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _placeholder(String name, double size) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? ''
        : parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();

    return Container(
      width: size,
      height: size,
      color: OColors.primary.withValues(alpha: 0.07),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700,
                  color: OColors.primary.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                Iconsax.user,
                size: size * 0.42,
                color: OColors.primary.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}
