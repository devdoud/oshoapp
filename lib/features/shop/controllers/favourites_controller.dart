import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';

class FavouritesController extends GetxController {
  static FavouritesController get instance => Get.find();

  /// Variables
  final favorites = <String, bool>{}.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    initFavorites();
  }

  // Initialize favorites from local storage
  void initFavorites() {
    final json = _storage.read('favorites');
    if (json != null) {
      final storedFavorites = Map<String, bool>.from(json);
      favorites.assignAll(storedFavorites);
    }
  }

  bool isFavourite(String productId) {
    return favorites[productId] ?? false;
  }

  void toggleFavoriteProduct(String productId) {
    if (!favorites.containsKey(productId)) {
      favorites[productId] = true;
    } else {
      favorites[productId] = !favorites[productId]!;
    }
    saveFavoritesToStorage();
    favorites.refresh();
  }

  void saveFavoritesToStorage() {
    _storage.write('favorites', favorites);
  }

  /// Computed getter to get actual Product objects that are favorited
  List<ProductModel> get favoriteProducts {
    // We need to look up the full product details from the ProductController
    // This assumes ProductController has all products or at least the featured ones
    final productController = ProductController.instance;
    return productController.featuredProducts
        .where((product) => isFavourite(product.id))
        .toList();
  }
}
