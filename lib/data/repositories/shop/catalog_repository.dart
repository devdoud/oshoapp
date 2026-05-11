import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/shop/models/product_model.dart';
import '../../../features/shop/models/product_tag_model.dart';
import '../../../features/shop/models/category_model.dart';

class CatalogRepository extends GetxController {
  static CatalogRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  // Trie du plus récent au plus ancien — gère les created_at null (mis à la fin)
  List<ProductModel> _sortByNewest(List<ProductModel> products) {
    products.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return products;
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)')
          .eq('is_featured', true);
      final data = List<Map<String, dynamic>>.from(response);
      return _sortByNewest(
          data.map((json) => ProductModel.fromJson(json)).toList());
    } catch (e) {
      throw 'Error fetching featured products: $e';
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)');
      final data = List<Map<String, dynamic>>.from(response);
      return _sortByNewest(
          data.map((json) => ProductModel.fromJson(json)).toList());
    } catch (e) {
      throw 'Error fetching all products: $e';
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)')
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return ProductModel.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      return null;
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, category:categories(*)')
          .eq('category_id', categoryId);
      final data = List<Map<String, dynamic>>.from(response);
      return _sortByNewest(
          data.map((json) => ProductModel.fromJson(json)).toList());
    } catch (e) {
      throw 'Error fetching products: $e';
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching categories: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getOptions(
      String type, String gender) async {
    try {
      final response = await _supabase
          .from('catalog_options')
          .select()
          .eq('type', type)
          .or('category_type.eq.all,category_type.eq.$gender')
          .eq('is_active', true);

      final data = List<Map<String, dynamic>>.from(response);

      if (data.isEmpty) {
        debugPrint('[CATALOG] No options for type=$type gender=$gender');
      }

      return data;
    } catch (e) {
      throw 'Error fetching options: $e';
    }
  }

  /// Fetch predefined tags from Supabase.
  /// Falls back to [ProductTagModel.defaults] on error.
  Future<List<ProductTagModel>> fetchPredefinedTags() async {
    try {
      final response = await _supabase
          .from('product_tags')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => ProductTagModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[CATALOG] fetchPredefinedTags error: $e — using defaults');
      return ProductTagModel.defaults;
    }
  }

  /// Insert a new product into Supabase.
  /// Returns the new product's id.
  Future<String> createProduct(ProductModel product) async {
    try {
      final payload = {
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
        'description': product.description,
        'category_id': product.categoryId,
        'images': product.images ?? [],
        'is_featured': product.isFeatured,
        'fabric': product.fabric,
        'embroidery': product.embroidery,
        'accessory': product.accessory,
        'difficulty': product.difficulty,
        'estimated_days': product.estimatedDays,
        'is_traditional': product.isTraditional ?? false,
        'traditional_origin': product.traditionalOrigin,
        'tags': product.tags,
        'sku': product.sku,
        'fabric_options': product.fabricOptions,
        'embroidery_options': product.embroideryOptions,
        'finish_options': product.finishOptions,
        'perfect_for': product.perfectFor,
        'price_usd': product.priceUsd,
      };

      final response = await _supabase
          .from('products')
          .insert(payload)
          .select('id')
          .single();

      return response['id']?.toString() ?? '';
    } catch (e) {
      throw 'Error creating product: $e';
    }
  }

  /// Update an existing product.
  Future<void> updateProduct(ProductModel product) async {
    try {
      final payload = {
        'title': product.title,
        'price': product.price,
        'thumbnail': product.thumbnail,
        'description': product.description,
        'category_id': product.categoryId,
        'images': product.images ?? [],
        'is_featured': product.isFeatured,
        'fabric': product.fabric,
        'embroidery': product.embroidery,
        'accessory': product.accessory,
        'difficulty': product.difficulty,
        'estimated_days': product.estimatedDays,
        'is_traditional': product.isTraditional ?? false,
        'traditional_origin': product.traditionalOrigin,
        'tags': product.tags,
        'sku': product.sku,
        'fabric_options': product.fabricOptions,
        'embroidery_options': product.embroideryOptions,
        'finish_options': product.finishOptions,
        'perfect_for': product.perfectFor,
        'price_usd': product.priceUsd,
      };

      await _supabase
          .from('products')
          .update(payload)
          .eq('id', product.id);
    } catch (e) {
      throw 'Error updating product: $e';
    }
  }
}
