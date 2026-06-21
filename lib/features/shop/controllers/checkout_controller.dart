import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/checkout/success_screen.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';
import 'package:osho/utils/helpers/tax_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final orderNoteController = TextEditingController();
  // Région : état US (ex: 'CA') ou province Canada (ex: 'QC')
  final regionController = TextEditingController();

  final isLoading = false.obs;
  final _orderRepository = Get.put(OrderRepository());
  Worker? _addressWorker;

  LogisticsRate get currentLogisticsRate => customLogisticsRate;

  LogisticsRate get customLogisticsRate =>
      OLogisticsCalculator.rateForCountry(countryController.text);

  LogisticsRate get cartLogisticsRate => OLogisticsCalculator.rateForCountry(
        countryController.text,
        itemCount: _cartItemCount,
      );

  int get _cartItemCount => CartController.instance.items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );

  double get shippingFee => customLogisticsRate.fee;

  // ── Taxes ─────────────────────────────────────────────────────────────────

  /// Tax configuration derived from the current country field.
  TaxConfig get currentTaxConfig {
    final country = countryController.text;
    final region = regionController.text.trim();
    return region.isNotEmpty
        ? TaxService.forRegion(country, region)
        : TaxService.forCountry(country);
  }

  /// Tax amount applied on the custom order product price (excl. shipping).
  double get taxAmount {
    final config = currentTaxConfig;
    if (!config.applies) return 0;
    return config.compute(CustomizationController.instance.basePrice.value);
  }

  /// Tax amount applied on the cart subtotal (excl. shipping).
  double get cartTaxAmount {
    final config = currentTaxConfig;
    if (!config.applies) return 0;
    return config.compute(CartController.instance.subtotal);
  }

  // ── Totals ────────────────────────────────────────────────────────────────

  double get customTotalAmount =>
      CustomizationController.instance.basePrice.value +
      customLogisticsRate.fee +
      taxAmount;

  double get cartTotalAmount =>
      CartController.instance.subtotal +
      cartLogisticsRate.fee +
      cartTaxAmount;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<UserController>()) {
      final user = UserController.instance.user.value;
      fullNameController.text = user.fullName;
      phoneController.text = user.phone;
    }

    if (Get.isRegistered<AddressController>()) {
      final addressBookController = Get.find<AddressController>();
      final selected = addressBookController.selectedAddress.value;
      if (selected != null) {
        setAddress(selected, overwrite: false);
      }

      _addressWorker = ever<AddressModel?>(
        addressBookController.selectedAddress,
        (address) {
          if (address != null) {
            setAddress(address, overwrite: false);
          }
        },
      );
    }
  }

  @override
  void onClose() {
    _addressWorker?.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    orderNoteController.dispose();
    regionController.dispose();
    super.onClose();
  }

  void setAddress(AddressModel address, {bool overwrite = true}) {
    if (overwrite || fullNameController.text.trim().isEmpty) {
      fullNameController.text = address.fullName;
    }
    if (overwrite || phoneController.text.trim().isEmpty) {
      phoneController.text = address.phone;
    }
    if (overwrite || cityController.text.trim().isEmpty) {
      cityController.text = address.city;
    }
    if (overwrite || stateController.text.trim().isEmpty) {
      stateController.text = address.quartier;
    }
    if (overwrite || addressController.text.trim().isEmpty) {
      addressController.text = address.address;
    }
    if (address.postalCode != null &&
        (overwrite || postalCodeController.text.trim().isEmpty)) {
      postalCodeController.text = address.postalCode!;
    }
    if (address.country != null &&
        (overwrite || countryController.text.trim().isEmpty)) {
      countryController.text = address.country!;
      // Réinitialiser la région quand le pays change
      if (overwrite) regionController.clear();
    }
  }

  bool validateAddress() {
    if (fullNameController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Nom manquant', message: 'Veuillez saisir votre nom complet.');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Telephone manquant',
          message: 'Veuillez saisir votre numero de telephone.');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Ville manquante', message: 'Veuillez saisir votre ville.');
      return false;
    }
    if (stateController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Quartier manquant',
          message: 'Veuillez saisir votre quartier.');
      return false;
    }
    if (addressController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Adresse manquante',
          message: 'Veuillez saisir votre adresse precise.');
      return false;
    }
    if (countryController.text.trim().isEmpty) {
      OLoaders.warningSnackBar(
          title: 'Pays manquant',
          message: 'Veuillez saisir le pays pour calculer la logistique.');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _buildShippingAddress(
      {required LogisticsRate logisticsRate}) {
    final country = countryController.text.trim();
    final taxConfig = TaxService.forCountry(country);
    return {
      'fullName': fullNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'city': cityController.text.trim(),
      'quartier': stateController.text.trim(),
      'address': addressController.text.trim(),
      'postal_code': postalCodeController.text.trim().isEmpty
          ? null
          : postalCodeController.text.trim(),
      'country': country.isEmpty ? null : country,
      'country_iso2': taxConfig.iso2.isNotEmpty ? taxConfig.iso2 : null,
      'region': regionController.text.trim().isEmpty
          ? null
          : regionController.text.trim().toUpperCase(),
      'logistics_zone': logisticsRate.zone,
      'logistics_fee': logisticsRate.fee,
      'logistics_weight': logisticsRate.weightLabel,
      'logistics_source': logisticsRate.sourceLabel,
      'delivery_estimate': logisticsRate.estimate,
    };
  }

  OrderItemModel _buildCustomOrderItem() {
    final customController = CustomizationController.instance;
    final measurementController = MeasurementController.instance;
    final isCouple = customController.categoryType.value
        .toLowerCase()
        .contains('couple');
    final profileId = measurementController.selectedProfile.value?.id;
    final profileId2 =
        isCouple ? measurementController.selectedProfile2.value?.id : null;

    final productId = customController.productId.value.isNotEmpty
        ? customController.productId.value
        : 'custom_product_id';

    return OrderItemModel(
      productId: productId,
      quantity: 1,
      price: customController.basePrice.value,
      measurementProfileId: profileId,
      customizationDetails: {
        'tissu': customController.fabricName,
        'tissu_image': customController.fabricImageUrl,
        'etape2': customController.getStep2Name(),
        'etape2_image': customController.getStep2ImageUrl(),
        'etape3': customController.getStep3Name(),
        'etape3_image': customController.getStep3ImageUrl(),
        'category': customController.categoryType.value,
        if (isCouple && profileId2 != null)
          'measurement_profile_id_2': profileId2,
        if (isCouple)
          'measurement_snapshot_2':
              measurementController.selectedProfile2.value?.toJson(),
      },
      measurementSnapshot:
          measurementController.selectedProfile.value?.toJson(),
    );
  }

  List<OrderItemModel> _buildCartOrderItems() {
    final measurementController = MeasurementController.instance;
    final profileId = measurementController.selectedProfile.value?.id;
    final profileSnapshot = measurementController.selectedProfile.value?.toJson();
    final profileId2 = measurementController.selectedProfile2.value?.id;
    final profileSnapshot2 = measurementController.selectedProfile2.value?.toJson();

    return CartController.instance.items.map((item) {
      final isCouple = item.customizationDetails?['is_couple'] as bool? ??
          (item.customizationDetails?['genre'] as String? ?? '')
              .toLowerCase()
              .contains('couple');
      final details = Map<String, dynamic>.from(
          item.customizationDetails ?? {'type': 'cart'});
      if (isCouple && profileId2 != null) {
        details['measurement_profile_id_2'] = profileId2;
        details['measurement_snapshot_2'] = profileSnapshot2;
      }
      return OrderItemModel(
        productId: item.productId,
        quantity: item.quantity,
        price: item.price,
        measurementProfileId: profileId,
        measurementSnapshot: profileSnapshot,
        customizationDetails: details,
      );
    }).toList();
  }

  Map<String, dynamic> _toCheckoutItemPayload(OrderItemModel item) {
    return {
      'product_id': item.productId,
      'quantity': item.quantity,
      'price': item.price,
      'measurement_profile_id': item.measurementProfileId,
      'customization_details': item.customizationDetails,
      'measurement_snapshot': item.measurementSnapshot,
    };
  }

  Future<Map<String, dynamic>> buildCheckoutPayload({
    required double totalAmount,
    required bool isCart,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw 'Session expiree. Veuillez vous reconnecter.';
    }

    if (!validateAddress()) {
      throw 'Adresse de livraison invalide.';
    }

    final items = isCart ? _buildCartOrderItems() : [_buildCustomOrderItem()];
    if (items.isEmpty) {
      throw 'Aucun article a payer.';
    }

    // Use the actual logistics fee — NOT derived from totalAmount,
    // which now includes taxes and would produce a wrong shipping value.
    final logisticsRate = isCart ? cartLogisticsRate : customLogisticsRate;
    final shippingFee = logisticsRate.fee;

    final note = orderNoteController.text.trim();
    return {
      'shipping_address': _buildShippingAddress(logisticsRate: logisticsRate),
      'shipping_fee': shippingFee,
      'payment_method': 'card',
      'source': isCart ? 'cart' : 'custom',
      'items': items.map(_toCheckoutItemPayload).toList(),
      if (note.isNotEmpty) 'customer_note': note,
    };
  }

  Future<OrderModel?> confirmStripeOrder({
    required String paymentIntentId,
    required bool isCart,
  }) async {
    try {
      isLoading.value = true;
      final response = await Supabase.instance.client.functions.invoke(
        'confirm-paid-order',
        body: {
          'payment_intent_id': paymentIntentId,
        },
      );

      if (response.status >= 400) {
        final data = response.data;
        final error = data is Map
            ? data['error']
            : data is String
                ? data
                : 'Confirmation du paiement impossible.';
        throw error.toString();
      }

      final rawData = response.data;
      final data = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : Map<String, dynamic>.from(rawData as Map);
      final orderJson = Map<String, dynamic>.from(data['order'] as Map);
      final savedOrder = OrderModel.fromJson(orderJson);

      if (isCart) {
        await CartController.instance.clear();
      }

      Get.offAll(() => OrderSuccessScreen(order: savedOrder));
      return savedOrder;
    } on FunctionException catch (e) {
      // supabase_flutter 2.x throws FunctionException for HTTP >= 400
      debugPrint('[CONFIRM ORDER FUNCTION ERROR] Status: ${e.status}, Details: ${e.details}');
      final details = e.details;
      final msg = details is Map
          ? details['error']?.toString()
          : details?.toString();
      throw msg ?? 'Erreur de confirmation (${e.status}). Veuillez réessayer.';
    } catch (e) {
      debugPrint('[CHECKOUT] Confirmation Stripe echouee: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderModel?> processOrder(double totalAmount) async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw 'Session expiree. Veuillez vous reconnecter.';
      }

      if (!validateAddress()) return null;

      final order = OrderModel(
        id: '',
        userId: userId,
        status: 'pending',
        items: [_buildCustomOrderItem()],
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: 'mobile',
        shippingAddress:
            _buildShippingAddress(logisticsRate: customLogisticsRate),
      );

      final savedOrder = await _orderRepository.saveOrder(order, userId,
          paymentStatus: 'pending');
      Get.offAll(() => OrderSuccessScreen(order: savedOrder));
      return savedOrder;
    } catch (e) {
      debugPrint('[CHECKOUT ERROR] processOrder: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderModel?> processCartOrder(double totalAmount) async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw 'Session expiree. Veuillez vous reconnecter.';
      }

      if (!validateAddress()) return null;

      final cartController = CartController.instance;
      if (cartController.items.isEmpty) {
        throw 'Votre panier est vide.';
      }

      final order = OrderModel(
        id: '',
        userId: userId,
        status: 'pending',
        items: _buildCartOrderItems(),
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: 'mobile',
        shippingAddress:
            _buildShippingAddress(logisticsRate: cartLogisticsRate),
      );

      final savedOrder = await _orderRepository.saveOrder(order, userId,
          paymentStatus: 'pending');
      await cartController.clear();
      Get.offAll(() => OrderSuccessScreen(order: savedOrder));
      return savedOrder;
    } catch (e) {
      debugPrint('[CHECKOUT ERROR] processCartOrder: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
