import 'package:get/get.dart';
import 'package:osho/utils/http/http_client.dart';
import '../../../features/shop/models/category_model.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      print('🔍 Fetching categories from API...');
      final response = await OHttpHelper.get('catalog/categories');

      print('📦 API Response: $response');

      // Assume the API returns a list of categories directly or under a 'data' key
      final List<dynamic> catList =
          response['data'] ?? response['categories'] ?? response;

      print('✅ Found ${catList.length} categories');

      final categories =
          catList.map((category) => CategoryModel.fromJson(category)).toList();

      print('📋 Parsed categories: ${categories.map((c) => c.name).toList()}');

      return categories;
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw 'Something went wrong while fetching Categories. Please try again.';
    }
  }
}
