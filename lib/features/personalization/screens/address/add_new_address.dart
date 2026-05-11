import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/validators/validation.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _quartierCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  final _addrCtrl = Get.put(AddressController());
  bool _makeDefault = false;

  @override
  void initState() {
    super.initState();
    _makeDefault = _addrCtrl.addresses.isEmpty;
    if (Get.isRegistered<UserController>()) {
      final user = UserController.instance.user.value;
      _fullNameCtrl.text = user.fullName;
      _phoneCtrl.text = user.phone;
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _quartierCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = AddressModel(
      userId: '',
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      quartier: _quartierCtrl.text.trim(),
      postalCode: _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
      isDefault: _makeDefault,
    );

    final ok = await _addrCtrl.addAddress(address, setDefault: _makeDefault);
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(isDark),

            // ── Form ────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Contact ──────────────────────────────────
                      _sectionLabel('CONTACT', isDark),
                      const SizedBox(height: 10),
                      _field(
                        controller: _fullNameCtrl,
                        label: 'Nom complet',
                        icon: Iconsax.user,
                        isDark: isDark,
                        validator: (v) =>
                            OValidator.validateEmptyText('Nom complet', v),
                      ),
                      const SizedBox(height: 10),
                      _field(
                        controller: _phoneCtrl,
                        label: 'Téléphone',
                        icon: Iconsax.mobile,
                        isDark: isDark,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            OValidator.validateEmptyText('Téléphone', v),
                      ),

                      const SizedBox(height: 22),

                      // ── Adresse ──────────────────────────────────
                      _sectionLabel('ADRESSE', isDark),
                      const SizedBox(height: 10),
                      _field(
                        controller: _addressCtrl,
                        label: 'Adresse précise',
                        icon: Iconsax.location,
                        isDark: isDark,
                        validator: (v) =>
                            OValidator.validateEmptyText('Adresse', v),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller: _cityCtrl,
                              label: 'Ville',
                              icon: Iconsax.building,
                              isDark: isDark,
                              validator: (v) =>
                                  OValidator.validateEmptyText('Ville', v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              controller: _quartierCtrl,
                              label: 'Quartier',
                              icon: Iconsax.map,
                              isDark: isDark,
                              validator: (v) =>
                                  OValidator.validateEmptyText('Quartier', v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller: _postalCtrl,
                              label: 'Code postal',
                              icon: Iconsax.code,
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              controller: _countryCtrl,
                              label: 'Pays',
                              icon: Iconsax.global,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── Default toggle ────────────────────────────
                      GestureDetector(
                        onTap: () => setState(() => _makeDefault = !_makeDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : const Color(0xFFEEEBE6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.star,
                                size: 16,
                                color: _makeDefault
                                    ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A))
                                    : (isDark
                                        ? Colors.white38
                                        : const Color(0xFFB0AAA2)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Définir comme adresse principale',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 42,
                                height: 24,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: _makeDefault
                                      ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A))
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : const Color(0xFFE0DDD9)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 200),
                                  alignment: _makeDefault
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: _makeDefault
                                          ? (isDark
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.white)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Save button ───────────────────────────────
                      Obx(() {
                        final loading = _addrCtrl.isLoading.value;
                        return GestureDetector(
                          onTap: loading ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: loading
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.5)
                                      : const Color(0xFF1A1A1A)
                                          .withValues(alpha: 0.5))
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: loading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: isDark
                                            ? const Color(0xFF1A1A1A)
                                            : Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Enregistrer',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFF1A1A1A)
                                            : Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFEEEBE6),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Nouvelle adresse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
        ),
      ),
    );
  }

  // ── Field ─────────────────────────────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEEEBE6);
    final focusBorder = isDark
        ? Colors.white.withValues(alpha: 0.30)
        : const Color(0xFF1A1A1A);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white38 : const Color(0xFF888480),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 16,
              color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
