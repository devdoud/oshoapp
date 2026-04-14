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

  final isLoading = false.obs;
  final _orderRepository = Get.put(OrderRepository());
  Worker? _addressWorker;

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
    return true;
  }

  Map<String, dynamic> _buildShippingAddress() {
    return {
      'fullName': fullNameController.text.trim(),
      'phone': phoneController.text.trim(),
      'city': cityController.text.trim(),
      'quartier': stateController.text.trim(),
      'address': addressController.text.trim(),
      'postal_code': postalCodeController.text.trim().isEmpty
          ? null
          : postalCodeController.text.trim(),
      'country': countryController.text.trim().isEmpty
          ? null
          : countryController.text.trim(),
    };
  }

  OrderItemModel _buildCustomOrderItem() {
    final customController = CustomizationController.instance;
    final measurementController = MeasurementController.instance;
    final profileId = measurementController.selectedProfile.value?.id;

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
        'etape2': customController.getStep2Name(),
        'etape3': customController.getStep3Name(),
        'category': customController.categoryType.value,
      },
      measurementSnapshot:
          measurementController.selectedProfile.value?.toJson(),
    );
  }

  List<OrderItemModel> _buildCartOrderItems() {
    return CartController.instance.items
        .map((item) => OrderItemModel(
              productId: item.productId,
              quantity: item.quantity,
              price: item.price,
              customizationDetails: const {
                'type': 'cart',
              },
            ))
        .toList();
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

    final itemTotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final shippingFee = (totalAmount - itemTotal).clamp(0, double.infinity);

    return {
      'shipping_address': _buildShippingAddress(),
      'shipping_fee': shippingFee,
      'payment_method': 'card',
      'source': isCart ? 'cart' : 'custom',
      'items': items.map(_toCheckoutItemPayload).toList(),
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
        shippingAddress: _buildShippingAddress(),
      );

      final savedOrder =
          await _orderRepository.saveOrder(order, userId, paymentStatus: 'pending');
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
        shippingAddress: _buildShippingAddress(),
      );

      final savedOrder =
          await _orderRepository.saveOrder(order, userId, paymentStatus: 'pending');
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

