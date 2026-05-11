import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/measurement/models/standard_size_model.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualMeasurementEntryScreen extends StatefulWidget {
  final MeasurementProfileModel? profile;
  final bool allowBack;
  final bool returnToCheckout;

  const ManualMeasurementEntryScreen({
    super.key,
    this.profile,
    this.allowBack = true,
    this.returnToCheckout = false,
  });

  @override
  State<ManualMeasurementEntryScreen> createState() => _ManualMeasurementEntryScreenState();
}

class _ManualMeasurementEntryScreenState extends State<ManualMeasurementEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mon Profil');
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _neckController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _sleeveController = TextEditingController();
  final _inseamController = TextEditingController();

  String _selectedGender = 'femme';
  String? _selectedTopSize;
  String? _selectedBottomSize;

  List<TextEditingController> get _measurementControllers => [
        _heightController,
        _weightController,
        _neckController,
        _chestController,
        _waistController,
        _hipsController,
        _shoulderController,
        _sleeveController,
        _inseamController,
      ];

  @override
  void initState() {
    super.initState();
    Get.put(MeasurementController());

    if (widget.profile != null) {
      _nameController.text = widget.profile!.profileName;
      _selectedGender = widget.profile!.gender;
      _heightController.text = widget.profile!.height?.toString() ?? '';
      _weightController.text = widget.profile!.weight?.toString() ?? '';
      _neckController.text = widget.profile!.neck?.toString() ?? '';
      _chestController.text = widget.profile!.chest?.toString() ?? '';
      _waistController.text = widget.profile!.waist?.toString() ?? '';
      _hipsController.text = widget.profile!.hips?.toString() ?? '';
      _shoulderController.text = widget.profile!.shoulder?.toString() ?? '';
      _sleeveController.text = widget.profile!.sleeve?.toString() ?? '';
      _inseamController.text = widget.profile!.inseam?.toString() ?? '';
    }

    for (final controller in [_nameController, ..._measurementControllers]) {
      controller.addListener(_handleFieldChange);
    }
  }

  @override
  void dispose() {
    for (final controller in [_nameController, ..._measurementControllers]) {
      controller.removeListener(_handleFieldChange);
    }

    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _neckController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _sleeveController.dispose();
    _inseamController.dispose();
    super.dispose();
  }

  void _handleFieldChange() {
    if (mounted) setState(() {});
  }

  void _applyTopSize(StandardSize size) {
    setState(() {
      _selectedTopSize = size.size;
      if (size.height != null) _heightController.text = size.height!.toStringAsFixed(0);
      if (size.weight != null) _weightController.text = size.weight!.toStringAsFixed(0);
      _neckController.text = size.neck.toStringAsFixed(0);
      _chestController.text = size.chest.toStringAsFixed(0);
      _shoulderController.text = size.shoulder.toStringAsFixed(0);
      _sleeveController.text = size.sleeve.toStringAsFixed(0);
    });
  }

  void _applyBottomSize(StandardSize size) {
    setState(() {
      _selectedBottomSize = size.size;
      _waistController.text = size.waist.toStringAsFixed(0);
      if (size.hips != null) _hipsController.text = size.hips!.toStringAsFixed(0);
      _inseamController.text = size.inseam.toStringAsFixed(0);
    });
  }

  String _buildSelectionLabel() {
    if (_selectedTopSize != null && _selectedBottomSize != null) {
      return 'Haut $_selectedTopSize · Bas $_selectedBottomSize appliques. Ajustez si necessaire.';
    } else if (_selectedTopSize != null) {
      return 'Haut $_selectedTopSize applique. Selectionnez aussi une taille bas.';
    } else {
      return 'Bas $_selectedBottomSize applique. Selectionnez aussi une taille haut.';
    }
  }

  void _goToHome() {
    final navController = Get.find<NavigationController>();
    navController.selectedIndex.value = 0;
  }

  int _completedFieldsCount() {
    var completed = _nameController.text.trim().isNotEmpty ? 1 : 0;
    for (final controller in _measurementControllers) {
      if (controller.text.trim().isNotEmpty) completed++;
    }
    return completed;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = MeasurementController.instance;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) {
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Veuillez vous connecter pour enregistrer vos mesures.',
      );
      return;
    }

    final isEditing = widget.profile != null;
    final hasOtherProfiles = controller.userMeasurements.any((p) => p.id != widget.profile?.id);
    final isPrimary = isEditing ? widget.profile!.isPrimary : !hasOtherProfiles;

    final profile = MeasurementProfileModel(
      id: widget.profile?.id,
      userId: userId,
      profileName: _nameController.text.trim(),
      gender: _selectedGender,
      isPrimary: isPrimary,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      neck: double.tryParse(_neckController.text),
      chest: double.tryParse(_chestController.text),
      waist: double.tryParse(_waistController.text),
      hips: double.tryParse(_hipsController.text),
      shoulder: double.tryParse(_shoulderController.text),
      sleeve: double.tryParse(_sleeveController.text),
      inseam: double.tryParse(_inseamController.text),
    );

    final saved = await controller.saveMeasurement(profile);

    if (!saved) {
      return;
    }

    if (Navigator.canPop(context)) {
      Get.back();
      if (widget.profile == null && Navigator.canPop(context)) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final completedFields = _completedFieldsCount();
    final pageColor = isDark ? const Color(0xFF0E0E11) : const Color(0xFFF6F1EB);
    final cardColor = isDark ? const Color(0xFF17171B) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF6A645C);

    return PopScope(
      canPop: widget.allowBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !widget.allowBack) _goToHome();
      },
      child: Scaffold(
        backgroundColor: pageColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: isDark
              ? SystemUiOverlayStyle.light
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Retour',
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes Mesures',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                widget.profile == null ? 'Composez votre profil sur mesure' : 'Affinez votre profil existant',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(OSizes.defaultPadding, 8, OSizes.defaultPadding, 150),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                context,
                title: 'Identite du profil',
                subtitle: 'Donnez un nom clair a ce profil et choisissez le bon gabarit.',
                cardColor: cardColor,
                child: Column(
                  children: [
                    _buildTextField(
                      context,
                      controller: _nameController,
                      label: 'Nom du profil',
                      icon: Iconsax.user,
                      hintText: 'Ex: Moi, Papa, Mariage',
                      cardColor: pageColor,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderCard(
                            context,
                            gender: 'femme',
                            icon: Iconsax.woman,
                            label: 'Femme',
                            caption: 'Coupes fluides et ajustees',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGenderCard(
                            context,
                            gender: 'homme',
                            icon: Iconsax.man,
                            label: 'Homme',
                            caption: 'Lignes nettes et structurees',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildStandardSizesCard(
                context,
                isDark: isDark,
                cardColor: cardColor,
                pageColor: pageColor,
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                context,
                title: 'Silhouette generale',
                subtitle: 'Ces informations aident a preparer une base fiable avant les mesures detaillees.',
                cardColor: cardColor,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context,
                        controller: _heightController,
                        label: 'Taille',
                        icon: Iconsax.ruler,
                        hintText: '170',
                        suffix: 'cm',
                        keyboardType: TextInputType.number,
                        cardColor: pageColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        context,
                        controller: _weightController,
                        label: 'Poids',
                        icon: Iconsax.weight,
                        hintText: '68',
                        suffix: 'kg',
                        keyboardType: TextInputType.number,
                        cardColor: pageColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionCard(
                context,
                title: 'Mensurations precises',
                subtitle: 'Prenez chaque mesure calmement avec un metre ruban souple.',
                cardColor: cardColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _neckController,
                            label: 'Tour de cou',
                            icon: Iconsax.ruler,
                            hintText: '36',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _chestController,
                            label: 'Poitrine',
                            icon: Iconsax.ruler,
                            hintText: '92',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _waistController,
                            label: 'Taille',
                            icon: Iconsax.ruler,
                            hintText: '74',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _hipsController,
                            label: 'Hanches',
                            icon: Iconsax.ruler,
                            hintText: '98',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _shoulderController,
                            label: 'Epaules',
                            icon: Iconsax.maximize_2,
                            hintText: '42',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: _sleeveController,
                            label: 'Manches',
                            icon: Iconsax.ruler,
                            hintText: '61',
                            suffix: 'cm',
                            keyboardType: TextInputType.number,
                            cardColor: pageColor,
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      context,
                      controller: _inseamController,
                      label: 'Entrejambe',
                      icon: Iconsax.ruler,
                      hintText: '78',
                      suffix: 'cm',
                      keyboardType: TextInputType.number,
                      cardColor: pageColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildTipsCard(
                context,
                cardColor: cardColor,
                mutedColor: mutedColor,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$completedFields/10 champs completes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: MeasurementController.instance.isLoading.value ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: MeasurementController.instance.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.profile == null ? 'Enregistrer mes mesures' : 'Mettre a jour mes mesures',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color cardColor,
    required Widget child,
  }) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : const Color(0xFF736D66),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    required Color cardColor,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Requis';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, size: 18, color: OColors.primary),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : OColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        suffix,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : OColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF6B645D),
          ),
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFFAAA39B),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: OColors.primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: OColors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: OColors.error, width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(
    BuildContext context, {
    required String gender,
    required IconData icon,
    required String label,
    required String caption,
    required bool isDark,
  }) {
    final isSelected = _selectedGender == gender;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => setState(() {
        _selectedGender = gender;
        _selectedTopSize = null;
        _selectedBottomSize = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [OColors.primary, OColors.primary.withOpacity(0.78)],
                )
              : null,
          color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF9F5EF)),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.14) : OColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : OColors.primary),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : OColors.primary),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white.withOpacity(0.76) : (isDark ? Colors.white60 : const Color(0xFF7A736B)),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(
    BuildContext context, {
    required Color cardColor,
    required Color mutedColor,
  }) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC66).withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.lamp_on, color: Color(0xFF9D6A00), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil de prise de mesure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Gardez le metre ruban bien a plat et laissez une aisance naturelle. Si une mesure vous semble douteuse, reprenez-la une seconde fois.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardSizesCard(
    BuildContext context, {
    required bool isDark,
    required Color cardColor,
    required Color pageColor,
  }) {
    final topSizes = StandardSizes.getTopSizesByGender(_selectedGender);
    final bottomSizes = StandardSizes.getBottomSizesByGender(_selectedGender);
    final hasSelection = _selectedTopSize != null || _selectedBottomSize != null;

    return _buildSectionCard(
      context,
      title: 'Tailles standards',
      subtitle: 'Choisissez votre taille haut et bas pour pre-remplir automatiquement vos mesures.',
      cardColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haut du corps',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF6A645C),
                ),
          ),
          const SizedBox(height: 8),
          _buildSizeChips(
            context,
            sizes: topSizes,
            selectedSize: _selectedTopSize,
            isDark: isDark,
            onSelect: _applyTopSize,
            sublabel: (s) => 'poitrine ${s.chest.toStringAsFixed(0)}cm',
          ),
          const SizedBox(height: 16),
          Text(
            'Bas du corps',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : const Color(0xFF6A645C),
                ),
          ),
          const SizedBox(height: 8),
          _buildSizeChips(
            context,
            sizes: bottomSizes,
            selectedSize: _selectedBottomSize,
            isDark: isDark,
            onSelect: _applyBottomSize,
            sublabel: (s) => 'taille ${s.waist.toStringAsFixed(0)}cm',
          ),
          if (hasSelection) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: OColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle, color: OColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _buildSelectionLabel(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: OColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSizeChips(
    BuildContext context, {
    required List<StandardSize> sizes,
    required String? selectedSize,
    required bool isDark,
    required void Function(StandardSize) onSelect,
    String? Function(StandardSize)? sublabel,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sizes.map((size) {
        final isSelected = selectedSize == size.size;
        final sub = sublabel?.call(size);
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelect(size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [OColors.primary, OColors.primary.withOpacity(0.78)],
                    )
                  : null,
              color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF9F5EF)),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  size.size,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : OColors.primary,
                      ),
                ),
                if (sub != null)
                  Text(
                    sub,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withOpacity(0.76)
                              : (isDark ? Colors.white60 : const Color(0xFF7A736B)),
                        ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
