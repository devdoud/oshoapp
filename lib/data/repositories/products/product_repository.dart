import 'package:get/get.dart';
import 'package:osho/utils/http/http_client.dart';
import '../../../features/shop/models/product_model.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  /// Get Featured Products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await OHttpHelper.get('catalog/products'); // You might have a specific query for featured
      
      final List<dynamic> productList = response['data'] ?? response['products'] ?? response;
      
      return productList.map((product) => ProductModel.fromJson(product)).toList();
    } catch (e) {
      throw 'Something went wrong while fetching Products. Please try again.';
    }
  }

  /// Get Products by Category
  Future<List<ProductModel>> getProductsForCategory({required String categoryId}) async {
    try {
      final response = await OHttpHelper.get('catalog/products?categoryId=$categoryId');
      
      final List<dynamic> productList = response['data'] ?? response['products'] ?? response;
      
      return productList.map((product) => ProductModel.fromJson(product)).toList();
    } catch (e) {
      throw 'Something went wrong while fetching Products for this category. Please try again.';
    }
  }
}
