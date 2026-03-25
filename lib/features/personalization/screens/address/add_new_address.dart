import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/validators/validation.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _quartierController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  final AddressController addressController = Get.put(AddressController());
  bool _makeDefault = false;

  @override
  void initState() {
    super.initState();
    _makeDefault = addressController.addresses.isEmpty;

    if (Get.isRegistered<UserController>()) {
      final user = UserController.instance.user.value;
      _fullNameController.text = user.fullName;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _quartierController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = AddressModel(
      userId: '',
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      quartier: _quartierController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      isDefault: _makeDefault,
    );

    final success = await addressController.addAddress(address, setDefault: _makeDefault);
    if (success && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OAppBar(
        showBackArrow: true,
        title: Text("Ajouter une adresse",
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(OSizes.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: 'Nom complet'),
                  validator: (value) =>
                      OValidator.validateEmptyText('Nom complet', value),
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.mobile),
                      labelText: 'Telephone'),
                  validator: (value) =>
                      OValidator.validateEmptyText('Telephone', value),
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.location),
                      labelText: 'Adresse'),
                  validator: (value) =>
                      OValidator.validateEmptyText('Adresse', value),
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.building),
                            labelText: 'Ville'),
                        validator: (value) =>
                            OValidator.validateEmptyText('Ville', value),
                      ),
                    ),
                    const SizedBox(width: OSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: _quartierController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.location),
                            labelText: 'Quartier'),
                        validator: (value) =>
                            OValidator.validateEmptyText('Quartier', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.code),
                            labelText: 'Code postal'),
                      ),
                    ),
                    const SizedBox(width: OSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Iconsax.global),
                            labelText: 'Pays'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OSizes.spaceBtwSections),
                SwitchListTile.adaptive(
                  value: _makeDefault,
                  onChanged: (value) {
                    setState(() => _makeDefault = value);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Definir comme adresse principale'),
                  activeColor: OColors.primary,
                ),
                const SizedBox(height: OSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    final isLoading = addressController.isLoading.value;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OColors.primary,
                        foregroundColor: OColors.textprimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 18),
                        textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: OColors.textprimary),
                      ),
                      child: Text('Enregistrer',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.apply(color: Colors.white)),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


