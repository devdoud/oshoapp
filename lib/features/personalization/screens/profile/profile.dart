import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final u = UserController.instance.user.value;
    _firstNameCtrl = TextEditingController(text: u.firstName);
    _lastNameCtrl  = TextEditingController(text: u.lastName);
    _phoneCtrl     = TextEditingController(text: u.phone);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final ctrl = UserController.instance;

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
            // ── Header ────────────────────────────────────────────────
            Container(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          _navBtn(Iconsax.arrow_left_2, () => Get.back(),
                              isDark),
                          const SizedBox(width: 14),
                          Text(
                            'Mes informations',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Obx(() {
                      final photo   = ctrl.user.value.profilePicture;
                      final loading = ctrl.profileLoading.value;
                      final name    = ctrl.user.value.fullName.trim();
                      final email   = ctrl.user.value.email;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: loading
                                ? null
                                : () => _showPickerSheet(ctrl, isDark),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : OColors.primary
                                            .withValues(alpha: 0.07),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : OColors.primary
                                              .withValues(alpha: 0.15),
                                      width: 2,
                                    ),
                                  ),
                                  child: loading
                                      ? Padding(
                                          padding: const EdgeInsets.all(26),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: isDark
                                                ? Colors.white
                                                : OColors.primary,
                                          ),
                                        )
                                      : ClipOval(
                                          child: _avatarContent(
                                              photo, name, isDark),
                                        ),
                                ),
                                if (!loading)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white
                                          : OColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF1A1A1A)
                                            : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Iconsax.camera,
                                      size: 12,
                                      color: isDark
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name.isEmpty ? 'Votre nom' : name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          if (email.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF888480),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: loading
                                ? null
                                : () => _showPickerSheet(ctrl, isDark),
                            child: Text(
                              photo.isNotEmpty
                                  ? 'Modifier la photo'
                                  : 'Ajouter une photo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white60
                                    : OColors.primary.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Formulaire ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Identité'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _firstNameCtrl,
                      label: 'Nom',
                      hint: 'Votre nom',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _lastNameCtrl,
                      label: 'Prénom',
                      hint: 'Votre prénom',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 16),
                    _label('Contact'),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: TextEditingController(
                          text: UserController.instance.user.value.email),
                      label: 'E-mail',
                      hint: '',
                      readOnly: true,
                      badge: 'Non modifiable',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _field(
                      ctrl: _phoneCtrl,
                      label: 'Téléphone',
                      hint: '+33 6 00 00 00 00',
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 28),

                    GestureDetector(
                      onTap: () {/* TODO: save */},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : OColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Enregistrer les modifications',
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────

  Widget _avatarContent(String photo, String name, bool isDark) {
    if (photo.isNotEmpty) {
      return Image.network(
        photo,
        width: 84,
        height: 84,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _avatarPlaceholder(name, isDark);
        },
        errorBuilder: (_, __, ___) => _avatarPlaceholder(name, isDark),
      );
    }
    return _avatarPlaceholder(name, isDark);
  }

  Widget _avatarPlaceholder(String name, bool isDark) {
    final initials = _initials(name);
    return Container(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : OColors.primary.withValues(alpha: 0.07),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white54
                      : OColors.primary.withValues(alpha: 0.6),
                  fontFamily: 'DMSans',
                ),
              )
            : Icon(
                Iconsax.user,
                size: 34,
                color: isDark
                    ? Colors.white38
                    : OColors.primary.withValues(alpha: 0.4),
              ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ── Composants UI ────────────────────────────────────────────────────

  Widget _navBtn(IconData icon, VoidCallback onTap, bool isDark) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFF8F6F3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFEEEBE6),
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isDark ? Colors.white70 : const Color(0xFF4A4542),
          ),
        ),
      );

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Color(0xFFB0AAA2),
          fontFamily: 'Montserrat',
        ),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required bool isDark,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: readOnly
              ? isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF2EFEA)
              : isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : const Color(0xFFEEEBE6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: ctrl,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: readOnly
                    ? isDark
                        ? Colors.white38
                        : const Color(0xFFB0AAA2)
                    : isDark
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB0AAA2),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white24
                      : const Color(0xFFD0CCC8),
                ),
                contentPadding: const EdgeInsets.only(bottom: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF2EFEA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFB0AAA2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────

  void _showPickerSheet(UserController controller, bool isDark) {
    final hasPhoto = controller.user.value.profilePicture.isNotEmpty;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE8E4DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Photo de profil',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            _sheetTile(
              icon: Iconsax.gallery,
              label: 'Choisir depuis la galerie',
              isDark: isDark,
              onTap: () {
                Get.back();
                controller.uploadUserProfilePicture(
                    source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
            _sheetTile(
              icon: Iconsax.camera,
              label: 'Prendre une photo',
              isDark: isDark,
              onTap: () {
                Get.back();
                controller.uploadUserProfilePicture(
                    source: ImageSource.camera);
              },
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 8),
              _sheetTile(
                icon: Iconsax.trash,
                label: 'Supprimer la photo',
                destructive: true,
                isDark: isDark,
                onTap: () {
                  Get.back();
                  controller.removeProfilePicture();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool destructive = false,
  }) {
    final color = destructive
        ? Colors.red
        : isDark
            ? Colors.white
            : const Color(0xFF1A1A1A);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: destructive
              ? Colors.red.withValues(alpha: 0.05)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8F6F3),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: destructive
                ? Colors.red.withValues(alpha: 0.15)
                : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
