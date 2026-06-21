import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/tax_service.dart';
import 'package:osho/utils/validators/validation.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key, this.existing});

  /// Si non null, l'écran est en mode édition (pré-rempli).
  final AddressModel? existing;

  bool get isEditing => existing != null;

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
    final ex = widget.existing;
    if (ex != null) {
      // Mode édition — pré-remplir tous les champs
      _fullNameCtrl.text = ex.fullName;
      _phoneCtrl.text = ex.phone;
      _addressCtrl.text = ex.address;
      _cityCtrl.text = ex.city;
      _quartierCtrl.text = ex.quartier;
      _postalCtrl.text = ex.postalCode ?? '';
      _countryCtrl.text = ex.country ?? '';
      _makeDefault = ex.isDefault;
    } else {
      _makeDefault = _addrCtrl.addresses.isEmpty;
      if (Get.isRegistered<UserController>()) {
        final user = UserController.instance.user.value;
        _fullNameCtrl.text = user.fullName;
        _phoneCtrl.text = user.phone;
      }
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

    bool ok;
    if (widget.isEditing) {
      final updated = widget.existing!.copyWith(
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        quartier: _quartierCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim().isEmpty ? null : _postalCtrl.text.trim(),
        country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        isDefault: _makeDefault,
      );
      ok = await _addrCtrl.updateAddress(updated);
      if (ok && _makeDefault) await _addrCtrl.setDefaultAddress(updated, showMessage: false);
    } else {
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
      ok = await _addrCtrl.addAddress(address, setDefault: _makeDefault);
    }

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
                      _sectionLabel('contact'.tr, isDark),
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
                        label: 'phone_number'.tr,
                        icon: Iconsax.mobile,
                        isDark: isDark,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            OValidator.validateEmptyText('Téléphone', v),
                      ),

                      const SizedBox(height: 22),

                      // ── Adresse ──────────────────────────────────
                      _sectionLabel('address_section'.tr, isDark),
                      const SizedBox(height: 10),
                      _field(
                        controller: _addressCtrl,
                        label: 'precise_address'.tr,
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
                              label: 'district'.tr,
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
                            child: _countryPicker(isDark),
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
                                  'set_as_default'.tr,
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
                                      'save_address'.tr,
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
                widget.isEditing ? 'Modifier l\'adresse' : 'add_new_address'.tr,
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

  // ── Country picker ────────────────────────────────────────────────────────────

  Widget _countryPicker(bool isDark) {
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFEEEBE6);
    final selected = _countryCtrl.text.isNotEmpty;
    final iso2 = TaxService.forCountry(_countryCtrl.text).iso2;
    final flag = iso2.isNotEmpty ? TaxService.flagEmoji(iso2) : '';

    return GestureDetector(
      onTap: () => _showCountrySearch(isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            if (selected && flag.isNotEmpty)
              Text(flag, style: const TextStyle(fontSize: 18))
            else
              Icon(Iconsax.global, size: 16,
                  color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected ? _countryCtrl.text : 'country_label'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  color: selected
                      ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                      : (isDark ? Colors.white38 : const Color(0xFF888480)),
                ),
              ),
            ),
            Icon(Iconsax.arrow_down_1, size: 14,
                color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
          ],
        ),
      ),
    );
  }

  void _showCountrySearch(bool isDark) {
    final countries = TaxService.supportedCountries;
    final searchCtrl = TextEditingController();
    var filtered = countries;

    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.80,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE0DDD9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text('Choisir un pays',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                      color: textColor),
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: TextStyle(fontSize: 13, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un pays...',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                      prefixIcon: Icon(Iconsax.search_normal,
                          size: 16,
                          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (q) {
                      setModalState(() {
                        filtered = q.isEmpty
                            ? countries
                            : countries
                                .where((c) =>
                                    c.name.toLowerCase().contains(q.toLowerCase()) ||
                                    c.iso2.toLowerCase() == q.toLowerCase())
                                .toList();
                      });
                    },
                  ),
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final isSelected = _countryCtrl.text == c.name;
                    final flag = TaxService.flagEmoji(c.iso2);
                    return ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? OColors.primary.withValues(alpha: 0.10)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFF4F1EC)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      title: Text(c.name,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSelected ? OColors.primary : textColor,
                        ),
                      ),
                      subtitle: Text(c.iso2,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: OColors.primary, size: 18)
                          : null,
                      onTap: () {
                        setState(() => _countryCtrl.text = c.name);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
