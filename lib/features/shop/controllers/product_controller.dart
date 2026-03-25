import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/shop/catalog_repository.dart';
import 'package:osho/features/shop/models/product_model.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final isLoading = false.obs;
  final _catalogRepository = Get.put(CatalogRepository());
  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    // Initial fetch handled by CategoryController or explicitly here
    // fetchFeaturedProducts();
    super.onInit();
  }

  void fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      final products = await _catalogRepository.getAllProducts();
      featuredProducts.assignAll(products);
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all products (for "Tout" / All category)
  void fetchAllProducts() async {
    try {
      isLoading.value = true;
      print('🛍️ Fetching all products...');
      final products = await _catalogRepository.getAllProducts();
      featuredProducts.assignAll(products);
      print('✅ Loaded ${products.length} products');
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void fetchProductsByCategory(String categoryId) async {
    try {
      isLoading.value = true;
      print('🛍️ Fetching products for category: $categoryId');
      final products =
          await _catalogRepository.getProductsByCategory(categoryId);
      featuredProducts.assignAll(products);
      print('✅ Loaded ${products.length} products for category');
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
