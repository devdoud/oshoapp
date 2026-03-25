import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osho/data/repositories/shop/catalog_repository.dart';
import 'package:osho/common/widgets/loaders/loader.dart';

class CustomizationController extends GetxController {
  static CustomizationController get instance => Get.find();

  final _catalogRepository = Get.put(CatalogRepository());
  final _imagePicker = ImagePicker();
  final isLoading = false.obs;

  // --- Dynamic Options ---
  final RxList<Map<String, dynamic>> step1Options =
      <Map<String, dynamic>>[].obs; // Fabrics
  final RxList<Map<String, dynamic>> step2Options =
      <Map<String, dynamic>>[].obs; // Cuts/Models
  final RxList<Map<String, dynamic>> step3Options =
      <Map<String, dynamic>>[].obs; // Accessories

  // --- Global ---
  final categoryType = 'femme'.obs; // 'homme' or 'femme'
  final productId = ''.obs;
  final productName = 'Modèle personnalisé'.obs;
  final productImage = ''.obs;
  final basePrice = 0.0.obs;

  // --- Uploaded Custom Images (one per step) ---
  final Rxn<File> customImageStep1 = Rxn<File>(); // Fabric custom image
  final Rxn<File> customImageStep2 = Rxn<File>(); // Cut/Broderie custom image
  final Rxn<File> customImageStep3 = Rxn<File>(); // Accessory custom image

  // --- Step 1: Fabric ---
  final inputMode = 0.obs; // 0 = Catalog, 1 = My Fabric
  final selectedCategory = 'Tous'.obs; // Fabric Category Filter
  final selectedVariantIndex = (-1).obs; // Index in the filtered list
  final selectedFabricOption =
      Rxn<Map<String, dynamic>>(); // The actual selected fabric object

  // --- Step 2: Cut / Broderie ---
  final selectedStep2Option = 0.obs; // index or 999

  // --- Step 3: Accessories / Finishes ---
  final selectedStep3Option = 0.obs; // index or 999

  // --- Helper Methods to get display names ---
  String get fabricName {
    if (inputMode.value == 1) return "Mon propre tissu";
    if (selectedFabricOption.value != null) {
      return getName(selectedFabricOption.value!);
    }
    return "Non sélectionné";
  }

  /// Opens a bottom sheet for camera/gallery selection then picks an image for a given step.
  /// [step] can be 1 (fabric), 2 (broderie/coupe), 3 (accessoire)
  Future<void> pickCustomImage(int step) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (picked == null) return;

      final file = File(picked.path);
      switch (step) {
        case 1:
          customImageStep1.value = file;
          selectedVariantIndex.value = 999; // Mark as custom
          selectedFabricOption.value = null;
          break;
        case 2:
          customImageStep2.value = file;
          selectedStep2Option.value = 999;
          break;
        case 3:
          customImageStep3.value = file;
          selectedStep3Option.value = 999;
          break;
      }

      OLoaders.successSnackBar(
        title: 'Photo ajoutée',
        message: 'Votre photo a été enregistrée avec succès !',
      );
    } catch (e) {
      OLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de charger la photo. Réessayez.',
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choisir une photo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text("Prendre une photo"),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text("Choisir depuis la galerie"),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();

    // Do NOT fetch options immediately because ProductDetail or CustomGenderStep
    // is about to inject the real gender right after Controller creation.
    // We listen to gender changes instead.
    ever(categoryType, (_) => fetchOptions());
  }

  void fetchOptions() async {
    try {
      isLoading.value = true;
      final gender = categoryType.value.toLowerCase(); // 'homme' or 'femme'

      // Fetch Step 1 (Fabrics), Step 2 (Models), Step 3 (Accessories) concurrently
      // Mapping:
      // fabric -> Step 1
      // model (cut/embroidery) -> Step 2
      // accessoire (accessory) -> Step 3
      final step2Type = (gender == 'homme') ? 'embroidery' : 'cut';

      final results = await Future.wait([
        _catalogRepository.getOptions('fabric', gender),
        _catalogRepository.getOptions(step2Type, gender),
        _catalogRepository.getOptions('accessory', gender),
      ]);

      step1Options.assignAll(results[0]);
      step2Options.assignAll(results[1]);
      step3Options.assignAll(results[2]);

      // Reset selections when options change
      selectedVariantIndex.value = -1;
      selectedFabricOption.value = null;
      selectedStep2Option.value = 0;
      selectedStep3Option.value = 0;
    } catch (e) {
      OLoaders.errorSnackBar(
          title: 'Erreur',
          message: 'Impossible de charger les options de personnalisation.');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to parse localized name from JSONB
  String getName(Map<String, dynamic> option) {
    try {
      final nameData = option['name'];
      if (nameData is Map) {
        // Check for various locale keys or fallback
        final locale = Get.locale?.languageCode ?? 'fr';
        return nameData[locale] ??
            nameData['fr'] ??
            nameData['en'] ??
            nameData.values.first ??
            '';
      }
      return nameData?.toString() ?? '';
    } catch (e) {
      return '';
    }
  }

  // Helper to parse image URL from potential JSON string
  String getOptionImage(Map<String, dynamic> option) {
    try {
      // Check 'image' first, then 'image_url' (common in Supabase or some API setups)
      var img = option['image'] ?? option['image_url'];

      if (img is String && img.trim().startsWith('{')) {
        // Handle JSON string
        final RegExp urlRegex = RegExp(r'"url"\s*:\s*"([^"]+)"');
        final match = urlRegex.firstMatch(img);
        if (match != null) {
          return match.group(1) ?? '';
        }
      }
      if (img is Map) {
        return img['url']?.toString() ?? '';
      }
      if (img is String && img.startsWith('http')) {
        return img;
      }
      return img?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String getStep2Name() {
    if (selectedStep2Option.value == 999) return "Style personnalisé";
    if (selectedStep2Option.value >= 0 &&
        selectedStep2Option.value < step2Options.length) {
      return getName(step2Options[selectedStep2Option.value]);
    }
    return "Standard";
  }

  String getStep3Name() {
    if (selectedStep3Option.value == 999) return "Détail personnalisé";
    if (selectedStep3Option.value >= 0 &&
        selectedStep3Option.value < step3Options.length) {
      return getName(step3Options[selectedStep3Option.value]);
    }
    return "Aucun";
  }

  // Data copied from the UI screens to avoid mismatch (or we could move all data here)
  // Hardcoded lists removed in favor of step2Options and step3Options fetching from Supabase
}
