import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/features/shop/models/cart_item_model.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  final _storage = GetStorage();
  final _supabase = Supabase.instance.client;
  final items = <CartItemModel>[].obs;

  StreamSubscription<AuthState>? _authSubscription;
  bool _isSyncing = false;

  @override
  void onInit() {
    super.onInit();
    _loadCart();

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _syncWithRemote(user.id);
      }
    });

    final user = _supabase.auth.currentUser;
    if (user != null) {
      _syncWithRemote(user.id);
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void _loadCart() {
    final data = _storage.read('cart_items');
    if (data is List) {
      final loaded = data
          .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      items.assignAll(loaded);
    }
  }

  void _saveCart() {
    _storage.write('cart_items', items.map((e) => e.toJson()).toList());
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool contains(String productId) {
    return items.any((item) => item.productId == productId);
  }

  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    final index = items.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      items[index].quantity += quantity;
    } else {
      items.add(CartItemModel(
        productId: product.id,
        title: product.title,
        price: product.price,
        image: product.thumbnail,
        quantity: quantity,
      ));
    }
    items.refresh();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final item = index >= 0 ? items[index] : items.last;
      await _upsertRemoteItem(userId, item);
    }
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    if (newQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index].quantity = newQuantity;
    }
    items.refresh();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      if (newQuantity <= 0) {
        await _deleteRemoteItem(userId, productId);
      } else {
        await _upsertRemoteItem(userId, items[index]);
      }
    }
  }

  Future<void> removeItem(String productId) async {
    items.removeWhere((i) => i.productId == productId);
    items.refresh();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _deleteRemoteItem(userId, productId);
    }
  }

  Future<void> clear() async {
    items.clear();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _clearRemote(userId);
    }
  }

  Future<void> _syncWithRemote(String userId) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final remoteItems = await _fetchRemoteItems(userId);
      final merged = _mergeItems(remoteItems, items);
      items.assignAll(merged);
      _saveCart();

      if (merged.isNotEmpty) {
        await _supabase.from('cart_items').upsert(
              merged.map((e) => e.toSupabase(userId)).toList(),
              onConflict: 'user_id,product_id',
            );
      }
    } catch (_) {
      // Keep local cart if remote sync fails.
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<CartItemModel>> _fetchRemoteItems(String userId) async {
    final response = await _supabase
        .from('cart_items')
        .select()
        .eq('user_id', userId);

    if (response is List) {
      return response
          .map((e) => CartItemModel.fromSupabase(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return [];
  }

  List<CartItemModel> _mergeItems(
      List<CartItemModel> remote, List<CartItemModel> local) {
    final map = <String, CartItemModel>{
      for (final item in remote) item.productId: item,
    };

    for (final item in local) {
      if (map.containsKey(item.productId)) {
        final existing = map[item.productId]!;
        map[item.productId] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
          price: existing.price > 0 ? existing.price : item.price,
          title: existing.title.isNotEmpty ? existing.title : item.title,
          image: existing.image.isNotEmpty ? existing.image : item.image,
        );
      } else {
        map[item.productId] = item;
      }
    }

    return map.values.toList();
  }

  Future<void> _upsertRemoteItem(String userId, CartItemModel item) async {
    await _supabase.from('cart_items').upsert(
          item.toSupabase(userId),
          onConflict: 'user_id,product_id',
        );
  }

  Future<void> _deleteRemoteItem(String userId, String productId) async {
    await _supabase
        .from('cart_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<void> _clearRemote(String userId) async {
    await _supabase.from('cart_items').delete().eq('user_id', userId);
  }
}
