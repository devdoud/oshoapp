import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/shop/catalog_repository.dart';
import 'package:osho/features/shop/models/category_model.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/features/shop/models/product_tag_model.dart';

class ProductAdminController extends GetxController {
  static ProductAdminController get instance => Get.find();

  // ─── Form state ───────────────────────────────────────────────────────────
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final thumbnailController = TextEditingController();
  final fabricController = TextEditingController();
  final embroideryController = TextEditingController();
  final accessoryController = TextEditingController();
  final estimatedDaysController = TextEditingController();

  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final isFeatured = false.obs;
  final isTraditional = false.obs;

  // ─── Tags ─────────────────────────────────────────────────────────────────
  final RxList<ProductTagModel> availableTags = <ProductTagModel>[].obs;
  final RxSet<String> selectedTags = <String>{}.obs;

  // ─── Categories ───────────────────────────────────────────────────────────
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // ─── Status ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    thumbnailController.dispose();
    fabricController.dispose();
    embroideryController.dispose();
    accessoryController.dispose();
    estimatedDaysController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      final repo = CatalogRepository.instance;
      final results = await Future.wait([
        repo.fetchPredefinedTags(),
        repo.getAllCategories(),
      ]);
      availableTags.assignAll(results[0] as List<ProductTagModel>);
      categories.assignAll(results[1] as List<CategoryModel>);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleTag(String tagName) {
    if (selectedTags.contains(tagName)) {
      selectedTags.remove(tagName);
    } else {
      selectedTags.add(tagName);
    }
  }

  void resetForm() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();
    thumbnailController.clear();
    fabricController.clear();
    embroideryController.clear();
    accessoryController.clear();
    estimatedDaysController.clear();
    selectedCategory.value = null;
    isFeatured.value = false;
    isTraditional.value = false;
    selectedTags.clear();
  }

  Future<void> saveProduct() async {
    final title = titleController.text.trim();
    final priceText = priceController.text.trim();

    if (title.isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Champ requis', message: 'Le titre du produit est obligatoire.');
      return;
    }
    if (priceText.isEmpty || double.tryParse(priceText) == null) {
      OLoaders.warningSnackBar(
          title: 'Prix invalide', message: 'Veuillez entrer un prix valide.');
      return;
    }

    isSaving.value = true;
    try {
      final product = ProductModel(
        id: '',
        sku: _generateSku(title),
        title: title,
        price: double.parse(priceText),
        thumbnail: thumbnailController.text.trim(),
        description: descriptionController.text.trim(),
        categoryId: selectedCategory.value?.id,
        categoryName: selectedCategory.value?.name,
        isFeatured: isFeatured.value,
        isTraditional: isTraditional.value,
        fabric: fabricController.text.trim().isEmpty ? null : fabricController.text.trim(),
        embroidery: embroideryController.text.trim().isEmpty ? null : embroideryController.text.trim(),
        accessory: accessoryController.text.trim().isEmpty ? null : accessoryController.text.trim(),
        estimatedDays: int.tryParse(estimatedDaysController.text.trim()),
        tags: selectedTags.toList(),
      );

      await CatalogRepository.instance.createProduct(product);
      OLoaders.successSnackBar(
          title: 'Produit créé', message: '"$title" a été ajouté au catalogue.');
      resetForm();
    } catch (e) {
      OLoaders.errorSnackBar(
          title: 'Erreur', message: 'Impossible de créer le produit. $e');
    } finally {
      isSaving.value = false;
    }
  }

  String _generateSku(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch % 10000;
    return '$slug-$suffix';
  }
}
