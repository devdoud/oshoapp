import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/shop/models/product_model.dart';
import '../../../features/shop/models/category_model.dart';

class CatalogRepository extends GetxController {
  static CatalogRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  /// Get Featured Products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select(
              '*, category:categories(*)') // Alias the joined table to 'category'
          .eq('is_featured', true);

      // Map Supabase response to ProductModel
      // Note: Supabase returns List<Map<String, dynamic>>
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching featured products: $e';
    }
  }

  /// Get All Products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)');

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching all products: $e';
    }
  }

  /// Get Products by Category
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)') // Fetch category details
          .eq('category_id', categoryId);

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching products: $e';
    }
  }

  /// Get All Categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching categories: $e';
    }
  }

  /// Get Customization Options (Dynamic Brain)
  /// type: 'fabric', 'cut', 'embroidery', 'accessory'
  /// gender: 'homme', 'femme', 'all'
  Future<List<Map<String, dynamic>>> getOptions(
      String type, String gender) async {
    try {
      final response = await _supabase
          .from('catalog_options')
          .select()
          .eq('type', type)
          .or('category_type.eq.all,category_type.eq.$gender') // Filter by gender OR 'all'
          .eq('is_active', true);


      final data = List<Map<String, dynamic>>.from(response);

      if (data.isEmpty) {
        print(
            "DEBUG: No options found for type='$type' and gender='$gender'. Checking if ANY exist for type='$type'...");
        // Fallback check to help debugging
        final count = await _supabase
            .from('catalog_options')
            .count(CountOption.exact)
            .eq('type', type);
        print(
            "DEBUG: Found $count items with type='$type' in total (ignoring gender/active).");

        if (count > 0) {
          print(
              "DEBUG: Data exists but filters (gender/active) might be too strict.");
        } else {
          print(
              "DEBUG: No data found for type='$type'. check database content.");
        }
      }

      return data;
    } catch (e) {
      throw 'Error fetching options: $e';
    }
  }
}
