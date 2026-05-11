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

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _catalogRepository.getAllCategories();
      allCategories.assignAll(categories);

      final allCategory = CategoryModel(
        id: 'all',
        name: 'all_categories'.tr,
        image: '',
        isFeatured: true,
      );

      final featured = allCategories
          .where((c) => c.isFeatured && c.parentId.isEmpty)
          .toList()
        ..sort((a, b) {
          final aDate = a.createdAt;
          final bDate = b.createdAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        });

      featuredCategories.assignAll([allCategory, ...featured.take(8)]);
      ProductController.instance.fetchAllProducts();
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: 'Impossible de charger les catégories. Veuillez réessayer.');
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
