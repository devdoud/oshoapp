import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/common/widgets/images/o_circular_image.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const OAppBar(showBackArrow: true, title: Text('Mes Informations'), actions: []),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Column(
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                  ],
                ),
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage : OImages.profile;
                      return Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          OCircularImage(
                            image: image, 
                            width: 80, 
                            height: 80, 
                            isNetworkImage: networkImage.isNotEmpty
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: OColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Iconsax.edit, size: 16, color: Colors.white),
                          )
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    Obx(() => Text(
                      controller.user.value.fullName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    )),
                    Text(
                        controller.user.value.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => controller.uploadUserProfilePicture(), 
                      child: const Text('Changer la photo', style: TextStyle(color: OColors.primary, fontWeight: FontWeight.bold, fontSize: 13))
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Details Form
              const SizedBox(height: 8),
              _buildProfileField(controller, "Nom", "FirstName", Iconsax.user),
              const SizedBox(height: 16),
              _buildProfileField(controller, "Prénom", "LastName", Iconsax.user),
              const SizedBox(height: 16),
              _buildProfileField(controller, "E-mail", "Email", Iconsax.sms, isReadOnly: true),
              const SizedBox(height: 16),
              _buildProfileField(controller, "Téléphone", "PhoneNumber", Iconsax.call),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {}, // Save functionality
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: OColors.primary.withOpacity(0.4),
                  ),
                  child: const Text("Enregistrer les modifications"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(UserController controller, String label, String field, IconData icon, {bool isReadOnly = false}) {
     // Usually would connect to text controllers in the real implementation
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        initialValue: _getValue(controller, field),
        readOnly: isReadOnly,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey[400], size: 20),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  String _getValue(UserController controller, String field) {
    if (field == 'FirstName') return controller.user.value.firstName;
    if (field == 'LastName') return controller.user.value.lastName;
    if (field == 'Email') return controller.user.value.email;
    if (field == 'PhoneNumber') return controller.user.value.phone;
    return '';
  }
}