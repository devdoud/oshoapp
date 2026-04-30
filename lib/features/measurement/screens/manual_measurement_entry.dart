import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/measurement/screens/measurement_tutorial.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
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

  int _completedFieldsCount() {
    var completed = _nameController.text.trim().isNotEmpty ? 1 : 0;
    for (final controller in _measurementControllers) {
      if (controller.text.trim().isNotEmpty) completed++;
    }
    return completed;
  }

  double _completionProgress() => _completedFieldsCount() / 10;

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

    final profile = MeasurementProfileModel(
      id: widget.profile?.id,
      userId: userId,
      profileName: _nameController.text.trim(),
      gender: _selectedGender,
      isPrimary: true,
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
    final progress = _completionProgress();
    final pageColor = isDark ? const Color(0xFF0E0E11) : const Color(0xFFF6F1EB);
    final cardColor = isDark ? const Color(0xFF17171B) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF6A645C);

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.allowBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Get.back(),
              )
            : null,
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
              ),
            ),
            child: IconButton(
              onPressed: () => Get.to(
                () => MeasurementTutorialScreen(
                  allowBack: widget.allowBack,
                  returnToCheckout: widget.returnToCheckout,
                ),
              ),
              icon: const Icon(Iconsax.video_circle, color: OColors.primary),
              tooltip: 'Voir le tutoriel',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(OSizes.defaultPadding, 8, OSizes.defaultPadding, 150),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(
                context,
                isDark: isDark,
                cardColor: cardColor,
                completedFields: completedFields,
                progress: progress,
              ),
              const SizedBox(height: 20),
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
                subtitle: 'Prenez chaque mesure calmement. Le tutoriel video reste accessible en haut.',
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
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required bool isDark,
    required Color cardColor,
    required int completedFields,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? const [Color(0xFF2D2D35), Color(0xFF111114)] : const [Color(0xFF25221D), Color(0xFF111111)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Iconsax.ruler, color: Colors.white),
              ),
              const Spacer(),
              _buildCapsule(
                label: widget.profile == null ? 'Nouveau profil' : 'Edition',
                icon: Iconsax.flash_1,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Un profil net pour des tenues qui tombent juste.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Renseignez chaque valeur une fois. Le tailleur partira ensuite sur une base propre et exploitable.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.78),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white.withOpacity(0.72),
                            ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFCC66)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedFields/10',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: OColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'renseignes',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: OColors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.video_play, color: Color(0xFFFFCC66), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Besoin d aide ? Ouvrez le tutoriel video depuis l icone en haut a droite.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFCC66), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
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
      onTap: () => setState(() => _selectedGender = gender),
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
}
