import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
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

  // ─── Persistence Locale ──────────────────────────────────────────────────

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

  // ─── Computed ────────────────────────────────────────────────────────────

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool contains(String productId) {
    return items.any((item) => item.productId == productId);
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  /// Ajoute un produit au panier.
  /// Les specs du produit (tissu, broderie, accessoire) sont automatiquement
  /// incluses dans [customizationDetails] et transmises au tailleur.
  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    // Construire les customizationDetails depuis les specs fixes du produit
    final details = _buildDetailsFromProduct(product);

    final index = items.indexWhere((i) => i.productId == product.id);
    if (index >= 0) {
      items[index].quantity += quantity;
      items.refresh();
    } else {
      items.add(CartItemModel(
        productId: product.id,
        title: product.title,
        price: product.price,
        image: product.thumbnail,
        quantity: quantity,
        customizationDetails: details,
      ));
    }
    _saveCart();

    // Sync remote (silencieux en cas d'erreur — le panier local est déjà sauvegardé)
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final item = index >= 0 ? items[index] : items.last;
      try {
        await _upsertRemoteItem(userId, item);
      } catch (e) {
        // L'item est déjà dans le panier local. La sync se fera au prochain login.
        OLoaders.warningSnackBar(
          title: 'Sync panier',
          message: 'Ajouté localement. Synchronisation en arrière-plan.',
        );
      }
    }
  }

  /// Construit les détails de personnalisation à partir des specs du produit.
  Map<String, dynamic> _buildDetailsFromProduct(ProductModel product) {
    final map = <String, dynamic>{
      'type': 'cart',
      'genre': product.categoryType ?? '',
    };
    if (product.fabric != null && product.fabric!.isNotEmpty) {
      map['tissu'] = product.fabric;
    }
    if (product.embroidery != null && product.embroidery!.isNotEmpty) {
      map['broderie'] = product.embroidery;
    }
    if (product.accessory != null && product.accessory!.isNotEmpty) {
      map['accessoire'] = product.accessory;
    }
    return map;
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
      try {
        if (newQuantity <= 0) {
          await _deleteRemoteItem(userId, productId);
        } else {
          await _upsertRemoteItem(userId, items[index]);
        }
      } catch (_) {
        // Silencieux — panier local à jour
      }
    }
  }

  Future<void> removeItem(String productId) async {
    items.removeWhere((i) => i.productId == productId);
    items.refresh();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _deleteRemoteItem(userId, productId);
      } catch (_) {
        // Silencieux
      }
    }
  }

  Future<void> clear() async {
    items.clear();
    _saveCart();

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _clearRemote(userId);
      } catch (_) {
        // Silencieux
      }
    }
  }

  // ─── Remote Sync ─────────────────────────────────────────────────────────

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
      // Conserver le panier local si la sync échoue
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

  /// Merge remote + local : en cas de doublon, on prend la quantité MAX
  /// (remote est source de vérité) pour éviter la duplication au re-login.
  List<CartItemModel> _mergeItems(
      List<CartItemModel> remote, List<CartItemModel> local) {
    final map = <String, CartItemModel>{
      for (final item in remote) item.productId: item,
    };

    for (final item in local) {
      if (map.containsKey(item.productId)) {
        final existing = map[item.productId]!;
        // FIX : on prend le MAX des quantités plutôt que de les sommer
        // pour éviter la duplication au re-login.
        map[item.productId] = existing.copyWith(
          quantity: existing.quantity >= item.quantity
              ? existing.quantity
              : item.quantity,
          price: existing.price > 0 ? existing.price : item.price,
          title: existing.title.isNotEmpty ? existing.title : item.title,
          image: existing.image.isNotEmpty ? existing.image : item.image,
          // Conserver les specs si le remote n'en a pas
          customizationDetails:
              existing.customizationDetails ?? item.customizationDetails,
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
