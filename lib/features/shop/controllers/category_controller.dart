import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/features/shop/models/category_model.dart';
import 'package:osho/data/repositories/shop/catalog_repository.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final selectedCategoryIndex = 0.obs;
  final _catalogRepository = Get.put(CatalogRepository());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  /// -- Load category data
  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _catalogRepository.getAllCategories();

      // 🔍 DEBUG: Afficher toutes les catégories récupérées
      print('🔍 DEBUG: Total categories fetched: ${categories.length}');
      for (var cat in categories) {
        print(
            '   - ID: ${cat.id}, Name: ${cat.name}, isFeatured: ${cat.isFeatured}, parentId: "${cat.parentId}"');
      }

      allCategories.assignAll(categories);

      // Create "Tout" (All) category
      final allCategory = CategoryModel(
        id: 'all',
        name: 'all_categories'.tr,
        image: '',
        isFeatured: true,
      );

      // Get featured categories and prepend "Tout"
      final featured = allCategories
          .where((category) => category.isFeatured && category.parentId.isEmpty)
          .take(8)
          .toList();

      // 🔍 DEBUG: Afficher les catégories filtrées
      print('🔍 DEBUG: Featured categories after filter: ${featured.length}');
      for (var cat in featured) {
        print('   ✅ ${cat.name}');
      }

      featuredCategories.assignAll([allCategory, ...featured]);

      print(
          '📂 Featured categories with "Tout": ${featuredCategories.map((c) => c.name).toList()}');

      // Fetch all products initially (since "Tout" is selected by default)
      ProductController.instance.fetchAllProducts();
    } catch (e) {
      print('❌ ERROR fetching categories: $e');
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;

    // If "Tout" (All) is selected (index 0), fetch all products
    if (index == 0) {
      ProductController.instance.fetchAllProducts();
    } else {
      // Trigger product fetch for specific category
      ProductController.instance
          .fetchProductsByCategory(featuredCategories[index].id);
    }
  }
}
