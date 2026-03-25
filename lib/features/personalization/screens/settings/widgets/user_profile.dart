import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

import 'package:osho/common/widgets/images/o_circular_image.dart';
import 'package:osho/utils/constants/colors.dart';

class OUserProfile extends StatelessWidget {
  const OUserProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Column(
      children: [
        Obx(() {
          final networkImage = controller.user.value.profilePicture;
          final image = networkImage.isNotEmpty ? networkImage : OImages.profile;
          return InkWell(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: OColors.primary.withOpacity(0.1), width: 1),
              ),
              child: OCircularImage(
                image: image,
                width: 80,
                height: 80,
                isNetworkImage: networkImage.isNotEmpty,
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final user = controller.user.value;
          return Column(
            children: [
              Text(
                user.fullName.trim().isEmpty ? "Bienvenue !" : user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                user.email.isEmpty ? "connectez-vous" : user.email,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: Colors.grey[500]),
              ),
              if (user.email.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    child: const Text('Se connecter', style: TextStyle(color: OColors.primary)),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}