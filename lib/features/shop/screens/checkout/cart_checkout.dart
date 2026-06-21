import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:osho/features/shop/screens/checkout/payment.dart';
import 'package:osho/features/shop/screens/checkout/widgets/logistics_rates_card.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';
import 'package:osho/utils/helpers/tax_service.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  late final AddressController _addrCtrl;
  late final CheckoutController _checkCtrl;
  late final MeasurementController _measCtrl;

  // Mode saisie manuelle (visible uniquement si aucune adresse sauvegardée)
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    _addrCtrl = Get.put(AddressController());
    _checkCtrl = Get.put(CheckoutController());
    _measCtrl = Get.put(MeasurementController());
    _checkCtrl.countryController.addListener(_rebuild);
  }

  @override
  void dispose() {
    _checkCtrl.countryController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F3F0);
    final cartCtrl = CartController.instance;
    final logistics = _checkCtrl.cartLogisticsRate;
    final shipping = logistics.fee;
    final taxConfig = _checkCtrl.currentTaxConfig;
    final taxAmount = _checkCtrl.cartTaxAmount;
    final total = cartCtrl.subtotal + shipping + taxAmount;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Adresse ──────────────────────────────────
                    _label('shipping_address'.tr, isDark),
                    const SizedBox(height: 10),
                    Obx(() => _buildAddressBlock(isDark)),
                    // Picker état/province toujours visible dès que pays = US ou CA
                    if (_needsRegion) ...[
                      const SizedBox(height: 8),
                      _buildRegionCard(isDark),
                    ],
                    const SizedBox(height: 6),
                    if (_showLogistics) ...[
                      const SizedBox(height: 4),
                      LogisticsRatesCard(currentRate: logistics),
                    ],

                    const SizedBox(height: 24),

                    // ── 2. Profil de mesure ─────────────────────────
                    _label('measure_profile'.tr, isDark),
                    const SizedBox(height: 10),
                    Obx(() => _buildMeasurementBlock(context, isDark)),

                    const SizedBox(height: 24),

                    // ── 3. Note de commande ──────────────────────────
                    _label('tailor_note_label'.tr, isDark),
                    const SizedBox(height: 10),
                    _buildNoteField(isDark),

                    const SizedBox(height: 24),

                    // ── 4. Récapitulatif ─────────────────────────────
                    _label('recap_title'.tr, isDark),
                    const SizedBox(height: 10),
                    _buildSummaryCard(
                        cartCtrl, logistics, shipping, taxConfig, taxAmount, total, isDark),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomBar(total, isDark),
          ],
        ),
      ),
    );
  }

  bool get _showLogistics {
    final country = _checkCtrl.countryController.text.trim();
    return country.isNotEmpty;
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F3F0),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 20, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFEEEBE6),
                    ),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text('delivery'.tr,
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              // Nombre d'articles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() => Text(
                  'order_items_count'.trParams(
                      {'count': '${CartController.instance.items.length}'}),
                  style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: OColors.primary,
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _label(String text, bool isDark) {
    return Text(text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
      ),
    );
  }

  // ── Bloc adresse ───────────────────────────────────────────────────────────

  Widget _buildAddressBlock(bool isDark) {
    if (_addrCtrl.isLoading.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: OLoader(),
        ),
      );
    }

    final selected = _addrCtrl.selectedAddress.value;

    // Adresse sauvegardée disponible ET non en mode saisie manuelle
    if (selected != null && !_manualMode) {
      return _buildSavedAddressCard(selected, isDark);
    }

    // Mode saisie manuelle
    return _buildManualForm(isDark, hasSaved: selected != null);
  }

  Widget _buildSavedAddressCard(dynamic address, bool isDark) {
    final flag = TaxService.flagEmoji(
        TaxService.forCountry(address.country ?? '').iso2);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: OColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: OColors.primary.withValues(alpha: 0.06),
            blurRadius: 16, offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.location, color: OColors.primary, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.fullName,
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(address.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton changer
              GestureDetector(
                onTap: () => Get.to(() => const UserAddressScreen(selectMode: true))
                    ?.then((_) {
                  final upd = _addrCtrl.selectedAddress.value;
                  if (upd != null) _checkCtrl.setAddress(upd, overwrite: true);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('change_btn'.tr,
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF4A4542),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFF0EDE8),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (flag.isNotEmpty) ...[
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  [
                    address.address,
                    address.quartier,
                    address.city,
                    if (address.country != null) address.country!,
                  ].where((s) => s.trim().isNotEmpty).join(', '),
                  style: TextStyle(
                    fontSize: 13, height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF4A4542),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _manualMode = true),
            child: Text('enter_other_address'.tr,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                decoration: TextDecoration.underline,
                decorationColor: isDark
                    ? Colors.white38
                    : const Color(0xFFB0AAA2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualForm(bool isDark, {required bool hasSaved}) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF0EDE8);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          if (hasSaved)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Text('manual_entry_label'.tr,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white54 : const Color(0xFF888480),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _manualMode = false),
                    child: Text('back_to_my_addresses'.tr,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: OColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _formRow(Iconsax.user, 'full_name'.tr,
              _checkCtrl.fullNameController, isDark, top: true),
          Container(height: 1, color: divColor, margin: const EdgeInsets.only(left: 50)),
          _formRow(Iconsax.call, 'phone_number'.tr,
              _checkCtrl.phoneController, isDark,
              keyboard: TextInputType.phone),
          Container(height: 1, color: divColor, margin: const EdgeInsets.only(left: 50)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _formRow(
                    Iconsax.building, 'city'.tr,
                    _checkCtrl.cityController, isDark, noborder: true)),
                Container(width: 1, color: divColor),
                Expanded(child: _formRow(
                    Iconsax.map, 'district'.tr,
                    _checkCtrl.stateController, isDark, noborder: true)),
              ],
            ),
          ),
          Container(height: 1, color: divColor, margin: const EdgeInsets.only(left: 50)),
          _formRow(Iconsax.home, 'precise_address'.tr,
              _checkCtrl.addressController, isDark),
          Container(height: 1, color: divColor, margin: const EdgeInsets.only(left: 50)),
          _countryRow(isDark),
        ],
      ),
    );
  }

  Widget _formRow(
    IconData icon,
    String hint,
    TextEditingController ctrl,
    bool isDark, {
    bool top = false,
    bool bottom = false,
    bool noborder = false,
    TextInputType? keyboard,
  }) {
    BorderRadius radius = BorderRadius.zero;
    if (!noborder) {
      if (top) radius = const BorderRadius.vertical(top: Radius.circular(18));
      if (bottom) radius = const BorderRadius.vertical(bottom: Radius.circular(18));
    }
    return ClipRRect(
      borderRadius: radius,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white24 : const Color(0xFFCCC8C4),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(icon, size: 16,
                color: isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          border: InputBorder.none,
          filled: true,
          fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        ),
      ),
    );
  }

  Widget _countryRow(bool isDark) {
    final country = _checkCtrl.countryController.text;
    final iso2 = TaxService.forCountry(country).iso2;
    final flag = iso2.isNotEmpty ? TaxService.flagEmoji(iso2) : '';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: GestureDetector(
        onTap: () => _showCountryPicker(isDark),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: country.isNotEmpty && flag.isNotEmpty
                    ? Text(flag, style: const TextStyle(fontSize: 18))
                    : Icon(Iconsax.global, size: 16,
                        color: isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
              ),
              Expanded(
                child: Text(
                  country.isNotEmpty ? country : 'country_label'.tr,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: country.isNotEmpty
                        ? (isDark ? Colors.white : const Color(0xFF1A1A1A))
                        : (isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
                  ),
                ),
              ),
              Icon(Iconsax.arrow_down_1, size: 13,
                  color: isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
            ],
          ),
        ),
      ),
    );
  }

  bool get _needsRegion {
    final iso2 = TaxService.forCountry(_checkCtrl.countryController.text).iso2;
    return iso2 == 'US' || iso2 == 'CA';
  }

  // Carte indépendante (hors formulaire) pour l'état/province
  Widget _buildRegionCard(bool isDark) {
    final iso2 = TaxService.forCountry(_checkCtrl.countryController.text).iso2;
    final regions = TaxService.regionsFor(iso2) ?? [];
    final selected = _checkCtrl.regionController.text.trim().toUpperCase();
    final isUS = iso2 == 'US';

    String display = '';
    double? selectedRate;
    String selectedLabel = '';
    if (selected.isNotEmpty) {
      try {
        display = regions.firstWhere((r) => r.code == selected).name;
        final cfg = TaxService.forRegion(
            _checkCtrl.countryController.text, selected);
        selectedRate = cfg.rate;
        selectedLabel = cfg.label;
      } catch (_) {
        display = selected;
      }
    }

    return GestureDetector(
      onTap: () => _showRegionPicker(isDark, iso2, regions),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected.isEmpty
                ? Colors.orange.withValues(alpha: 0.40)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFEEEBE6)),
            width: selected.isEmpty ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Iconsax.map, size: 15,
                color: selected.isEmpty
                    ? Colors.orange
                    : (isDark ? Colors.white38 : const Color(0xFFB0AAA2))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.isEmpty
                        ? (isUS ? 'select_state'.tr : 'select_province'.tr)
                        : display,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected.isEmpty ? FontWeight.w400 : FontWeight.w600,
                      color: selected.isEmpty
                          ? Colors.orange
                          : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    ),
                  ),
                  if (selectedRate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      selectedRate == 0
                          ? 'no_tax_in_state'.tr
                          : '$selectedLabel · ${(selectedRate * 100).toStringAsFixed(selectedRate * 100 % 1 == 0 ? 0 : 2)} %',
                      style: TextStyle(
                        fontSize: 11,
                        color: selectedRate == 0
                            ? const Color(0xFF34C759)
                            : OColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(selected,
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: OColors.primary,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Icon(Iconsax.arrow_down_1, size: 13,
                color: isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
          ],
        ),
      ),
    );
  }

  void _showRegionPicker(
    bool isDark,
    String iso2,
    List<({String code, String name})> regions,
  ) {
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final title = iso2 == 'US' ? 'state_label'.tr : 'province_label'.tr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.65,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
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
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Text('choose_region_fmt'.trParams({'title': title}),
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: regions.length,
                itemBuilder: (_, i) {
                  final r = regions[i];
                  final isSelected =
                      _checkCtrl.regionController.text.toUpperCase() == r.code;
                  // Récupérer le taux pour cet état/province
                  final taxCfg = TaxService.forRegion(
                    _checkCtrl.countryController.text, r.code);

                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    title: Text(r.name,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: isSelected
                            ? OColors.primary
                            : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (taxCfg.applies)
                          Text(taxCfg.ratePercent,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                            ),
                          )
                        else
                          Text('0 %',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white24 : const Color(0xFFCCC8C4),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: OColors.primary, size: 18),
                      ],
                    ),
                    onTap: () {
                      _checkCtrl.regionController.text = r.code;
                      _rebuild();
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(bool isDark) {
    final countries = TaxService.supportedCountries;
    final searchCtrl = TextEditingController();
    var filtered = countries;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Container(
          height: MediaQuery.of(ctx).size.height * 0.80,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
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
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: Text('choose_country'.tr,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F1EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: TextStyle(fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                    decoration: InputDecoration(
                      hintText: 'Rechercher…',
                      hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                      prefixIcon: Icon(Iconsax.search_normal, size: 15,
                          color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: (q) => set(() {
                      filtered = q.isEmpty
                          ? countries
                          : countries
                              .where((c) =>
                                  c.name.toLowerCase().contains(q.toLowerCase()) ||
                                  c.iso2.toLowerCase() == q.toLowerCase())
                              .toList();
                    }),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final isSelected = _checkCtrl.countryController.text == c.name;
                    final flag = TaxService.flagEmoji(c.iso2);
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      dense: true,
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
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      title: Text(c.name,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isSelected
                              ? OColors.primary
                              : (isDark ? Colors.white : const Color(0xFF1A1A1A)),
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
                        _checkCtrl.countryController.text = c.name;
                        _checkCtrl.regionController.clear();
                        _rebuild();
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

  // ── Note de commande ───────────────────────────────────────────────────────

  Widget _buildNoteField(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Icon(Iconsax.message_edit, size: 14,
                    color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'note_field_hint_label'.tr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                    ),
                  ),
                ),
                // Compteur de caractères
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _checkCtrl.orderNoteController,
                  builder: (_, value, __) {
                    final len = value.text.length;
                    final isNearLimit = len > 400;
                    return Text(
                      '$len / 500',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: isNearLimit
                            ? Colors.orange
                            : (isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Textarea
          TextField(
            controller: _checkCtrl.orderNoteController,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: 'note_field_example'.tr,
              hintStyle: TextStyle(
                fontSize: 13, height: 1.55,
                color: isDark ? Colors.white24 : const Color(0xFFCCC8C4),
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: cardBg,
              contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bloc mesures ───────────────────────────────────────────────────────────

  Widget _buildMeasurementBlock(BuildContext context, bool isDark) {
    if (_measCtrl.isLoading.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: OColors.primary, strokeWidth: 2),
        ),
      );
    }

    final profiles = _measCtrl.userMeasurements;

    if (profiles.isEmpty) {
      return _buildNoMeasurement(isDark);
    }

    return Column(
      children: profiles.map((p) {
        final isSelected = _measCtrl.selectedProfile.value?.id == p.id ||
            (_measCtrl.selectedProfile.value?.id == null &&
                _measCtrl.selectedProfile.value?.profileName == p.profileName);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _measureTile(p, isSelected, isDark),
        );
      }).toList(),
    );
  }

  Widget _measureTile(
      MeasurementProfileModel p, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => _measCtrl.selectedProfile.value = p,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? OColors.primary.withValues(alpha: 0.07)
              : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? OColors.primary.withValues(alpha: 0.35)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFEEEBE6)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isSelected
                  ? OColors.primary.withValues(alpha: 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF0EDE8)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              p.gender == 'homme' ? Iconsax.man : Iconsax.woman,
              size: 17,
              color: isSelected
                  ? OColors.primary
                  : (isDark ? Colors.white38 : const Color(0xFF888480)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p.profileName,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                if (p.isPrimary) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('primary_profile'.tr,
                      style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: OColors.primary,
                      ),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(_measSummary(p),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                ),
              ),
            ]),
          ),
          if (isSelected)
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                  color: OColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
        ]),
      ),
    );
  }

  String _measSummary(MeasurementProfileModel p) {
    final parts = <String>[];
    if (p.chest != null) parts.add('P: ${p.chest!.toStringAsFixed(0)}cm');
    if (p.waist != null) parts.add('T: ${p.waist!.toStringAsFixed(0)}cm');
    if (p.hips != null) parts.add('H: ${p.hips!.toStringAsFixed(0)}cm');
    return parts.isEmpty
        ? (p.gender == 'homme' ? 'male_label'.tr : 'female_label'.tr)
        : parts.join(' · ');
  }

  Widget _buildNoMeasurement(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.ruler, color: OColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'no_measurement_text'.tr,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.to(() => const ManualMeasurementEntryScreen())
                ?.then((_) => _measCtrl.fetchUserMeasurements()),
            icon: const Icon(Iconsax.ruler, size: 15, color: OColors.primary),
            label: Text('create_my_profile'.tr,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: OColors.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: OColors.primary.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Récapitulatif ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(
    CartController cartCtrl,
    LogisticsRate logistics,
    double shipping,
    TaxConfig taxConfig,
    double taxAmount,
    double total,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final divColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF0EDE8);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(
        children: [
          // Articles
          ...List.generate(cartCtrl.items.length, (i) {
            final item = cartCtrl.items[i];
            final isLast = i == cartCtrl.items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.image.isNotEmpty
                          ? Image.network(item.image,
                              width: 48, height: 48, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imgPlaceholder(isDark))
                          : _imgPlaceholder(isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Qté ${item.quantity}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFB0AAA2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      OLogisticsCalculator.formatFeeLocalized(
                          item.price * item.quantity),
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ]),
                ),
                if (!isLast)
                  Container(height: 1, color: divColor,
                      margin: const EdgeInsets.symmetric(horizontal: 14)),
              ],
            );
          }),

          // Séparateur avant totaux
          Container(height: 1, color: divColor),

          // Lignes de calcul
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(children: [
              _row('subtotal'.tr,
                  OLogisticsCalculator.formatFeeLocalized(cartCtrl.subtotal),
                  isDark),
              const SizedBox(height: 8),
              _row(
                  'shipping_zone_fmt'.trParams({
                    'zone': logistics.zone,
                    'estimate': logistics.estimate,
                  }),
                  OLogisticsCalculator.formatFeeLocalized(shipping), isDark),
              if (taxConfig.applies) ...[
                const SizedBox(height: 8),
                _row(
                    'taxes_fmt'.trParams({'label': taxConfig.fullLabel}),
                    OLogisticsCalculator.formatFeeLocalized(taxAmount), isDark,
                    accent: true),
              ],
            ]),
          ),

          // Total
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF8F6F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('total'.tr,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    OLogisticsCalculator.formatFeeLocalized(total),
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: OColors.primary, letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder(bool isDark) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF4F1EC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Iconsax.shopping_bag, size: 20,
          color: isDark ? Colors.white24 : const Color(0xFFCCC8C4)),
    );
  }

  Widget _row(String label, String value, bool isDark,
      {bool accent = false, bool subdued = false}) {
    final labelColor = subdued
        ? (isDark ? Colors.white24 : const Color(0xFFCCC8C4))
        : (isDark ? Colors.white54 : const Color(0xFF888480));
    final valueColor = accent
        ? const Color(0xFFE67E22)
        : subdued
            ? (isDark ? Colors.white24 : const Color(0xFFCCC8C4))
            : (isDark ? Colors.white : const Color(0xFF1A1A1A));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
            style: TextStyle(fontSize: 12, color: labelColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(double total, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFEEEBE6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Montant
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('total'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  OLogisticsCalculator.formatFeeLocalized(total),
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Bouton
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_checkCtrl.validateAddress()) return;
                  if (_measCtrl.selectedProfile.value == null) {
                    OLoaders.warningSnackBar(
                      title: 'missing_measurements_title'.tr,
                      message: 'select_measurement_profile_msg'.tr,
                    );
                    return;
                  }
                  Get.to(() => PaymentScreen(
                      isCart: true, totalAmount: total));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: OColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('pay_btn'.tr,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.white),
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
}
