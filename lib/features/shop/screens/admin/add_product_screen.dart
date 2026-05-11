import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/shop/controllers/product_admin_controller.dart';
import 'package:osho/features/shop/models/product_tag_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductAdminController());
    final isDark = OHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111111) : const Color(0xFFF4F4F4),
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? Colors.white : OColors.primary),
          ),
        ),
        title: Text(
          'Nouveau produit',
          style: TextStyle(
            color: isDark ? Colors.white : OColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: OColors.primary));
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Infos principales
              _sectionHeader(Iconsax.tag, 'Informations générales', isDark),
              const SizedBox(height: 14),
              _card(isDark, child: Column(children: [
                _field('Titre du produit', Iconsax.text,
                    controller.titleController, isDark,
                    isFirst: true),
                _divider(isDark),
                _field('Prix (FCFA)', Iconsax.money,
                    controller.priceController, isDark,
                    keyboardType: TextInputType.number),
                _divider(isDark),
                _field('URL Thumbnail', Iconsax.image,
                    controller.thumbnailController, isDark),
                _divider(isDark),
                _field('Description', Iconsax.document,
                    controller.descriptionController, isDark,
                    maxLines: 3, isLast: true),
              ])),
              const SizedBox(height: 24),

              // ── Catégorie
              _sectionHeader(Iconsax.category, 'Catégorie', isDark),
              const SizedBox(height: 14),
              _card(isDark, child: _categoryDropdown(context, controller, isDark)),
              const SizedBox(height: 24),

              // ── Tags
              _sectionHeader(Iconsax.tag_2, 'Tags', isDark),
              const SizedBox(height: 6),
              Text(
                'Sélectionnez les tags applicables à ce produit.',
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[500]),
              ),
              const SizedBox(height: 14),
              _card(isDark, child: _tagSelector(controller, isDark)),
              const SizedBox(height: 24),

              // ── Spécifications
              _sectionHeader(Iconsax.setting_2, 'Spécifications', isDark),
              const SizedBox(height: 14),
              _card(isDark, child: Column(children: [
                _field('Tissu / Matière', Iconsax.shapes,
                    controller.fabricController, isDark,
                    isFirst: true),
                _divider(isDark),
                _field('Broderie / Style', Iconsax.magicpen,
                    controller.embroideryController, isDark),
                _divider(isDark),
                _field('Accessoire / Finition', Iconsax.add_circle,
                    controller.accessoryController, isDark),
                _divider(isDark),
                _field('Délai confection (jours)', Iconsax.clock,
                    controller.estimatedDaysController, isDark,
                    keyboardType: TextInputType.number,
                    isLast: true),
              ])),
              const SizedBox(height: 24),

              // ── Options
              _sectionHeader(Iconsax.toggle_off_circle, 'Options', isDark),
              const SizedBox(height: 14),
              _card(isDark, child: Column(children: [
                _toggle('Produit mis en avant', controller.isFeatured, isDark),
                _divider(isDark),
                _toggle('Produit traditionnel', controller.isTraditional, isDark,
                    isLast: true),
              ])),
              const SizedBox(height: 36),

              // ── Bouton Enregistrer
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            OColors.primary.withValues(alpha: 0.4),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Enregistrer le produit',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2)),
                    ),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ─── Section header ───────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: OColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : OColors.primary,
              letterSpacing: -0.2,
            )),
      ],
    );
  }

  // ─── Card wrapper ─────────────────────────────────────────────────────────

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  // ─── Form field ───────────────────────────────────────────────────────────

  Widget _field(
    String hint,
    IconData icon,
    TextEditingController ctrl,
    bool isDark, {
    bool isFirst = false,
    bool isLast = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    BorderRadius radius = BorderRadius.zero;
    if (isFirst && isLast) {
      radius = BorderRadius.circular(20);
    } else if (isFirst) {
      radius = const BorderRadius.vertical(top: Radius.circular(20));
    } else if (isLast) {
      radius = const BorderRadius.vertical(bottom: Radius.circular(20));
    }

    return ClipRRect(
      borderRadius: radius,
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : OColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.normal),
          prefixIcon: maxLines == 1
              ? Icon(icon,
                  color: isDark ? Colors.white38 : Colors.grey[400], size: 18)
              : null,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 14 : 16,
              horizontal: maxLines > 1 ? 16 : 0),
        ),
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEEEEEE),
      indent: 54,
    );
  }

  // ─── Category dropdown ────────────────────────────────────────────────────

  Widget _categoryDropdown(BuildContext context,
      ProductAdminController controller, bool isDark) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: controller.selectedCategory.value?.id,
            dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.category,
                  color: isDark ? Colors.white38 : Colors.grey[400], size: 18),
              hintText: 'Choisir une catégorie',
              hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey[400],
                  fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    const BorderSide(color: OColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
            items: controller.categories.map((cat) {
              return DropdownMenuItem(
                value: cat.id,
                child: Text(cat.name,
                    style: TextStyle(
                        color: isDark ? Colors.white : OColors.primary,
                        fontSize: 14)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              controller.selectedCategory.value = controller.categories
                  .firstWhere((c) => c.id == value);
            },
          ),
        ));
  }

  // ─── Tag chip selector ────────────────────────────────────────────────────

  Widget _tagSelector(ProductAdminController controller, bool isDark) {
    return Obx(() {
      if (controller.availableTags.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Aucun tag disponible.',
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[500],
                  fontSize: 13)),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.availableTags
              .map((tag) => _buildTagChip(tag, controller, isDark))
              .toList(),
        ),
      );
    });
  }

  Widget _buildTagChip(
      ProductTagModel tag, ProductAdminController controller, bool isDark) {
    return Obx(() {
      final isSelected = controller.selectedTags.contains(tag.name);
      return GestureDetector(
        onTap: () => controller.toggleTag(tag.name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? OColors.primary
                : (isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF3F3F3)),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: isSelected
                  ? OColors.primary
                  : (isDark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFE0E0E0)),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 5),
              ],
              Text(
                tag.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Toggle switch ────────────────────────────────────────────────────────

  Widget _toggle(String label, RxBool value, bool isDark,
      {bool isLast = false}) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : OColors.primary)),
              Switch(
                value: value.value,
                onChanged: (v) => value.value = v,
                activeThumbColor: OColors.primary,
                activeTrackColor: OColors.primary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ));
  }
}
