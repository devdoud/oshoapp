import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/personalization/controllers/address_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/address_model.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
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
          addressBookController.selectedAddress, (address) {
        if (address != null) {
          setAddress(address, overwrite: false);
        }
      });
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

  Future<OrderModel?> processOrder(double totalAmount) async {
    try {
      isLoading.value = true;

      if (!validateAddress()) return null;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw 'Vous devez etre connecte pour passer une commande.';
      }

      final shippingAddress = {
        'fullName': fullNameController.text,
        'phone': phoneController.text,
        'city': cityController.text,
        'quartier': stateController.text,
        'address': addressController.text,
        'postal_code': postalCodeController.text.trim().isEmpty
            ? null
            : postalCodeController.text.trim(),
        'country': countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
      };

      final customController = CustomizationController.instance;
      final measurementController = MeasurementController.instance;
      final profileId = measurementController.selectedProfile.value?.id;

      final productId = customController.productId.value.isNotEmpty
          ? customController.productId.value
          : 'custom_product_id';

      final item = OrderItemModel(
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
      );

      final order = OrderModel(
        id: '',
        userId: userId,
        status: 'pending',
        items: [item],
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      debugPrint('?? [CHECKOUT] Sauvegarde de la commande...');
      final savedOrder = await _orderRepository.saveOrder(order, userId);

      debugPrint('[CHECKOUT] Redirection vers l\'ecran de succes...');
      Get.offAll(() => OrderSuccessScreen(order: savedOrder));
      
      return savedOrder;
    } catch (e) {
      debugPrint(
          '?? [CHECKOUT ERROR] Une erreur est survenue lors du traitement : $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<OrderModel?> processCartOrder(double totalAmount) async {
    try {
      isLoading.value = true;

      if (!validateAddress()) return null;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw 'Vous devez etre connecte pour passer une commande.';
      }

      final cartController = CartController.instance;
      if (cartController.items.isEmpty) {
        throw 'Votre panier est vide.';
      }

      final shippingAddress = {
        'fullName': fullNameController.text,
        'phone': phoneController.text,
        'city': cityController.text,
        'quartier': stateController.text,
        'address': addressController.text,
        'postal_code': postalCodeController.text.trim().isEmpty
            ? null
            : postalCodeController.text.trim(),
        'country': countryController.text.trim().isEmpty
            ? null
            : countryController.text.trim(),
      };

      final items = cartController.items
          .map((item) => OrderItemModel(
                productId: item.productId,
                quantity: item.quantity,
                price: item.price,
                customizationDetails: {
                  'type': 'cart',
                },
              ))
          .toList();

      final order = OrderModel(
        id: '',
        userId: userId,
        status: 'pending',
        items: items,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      debugPrint('[CHECKOUT] Sauvegarde de la commande panier...');
      final savedOrder = await _orderRepository.saveOrder(order, userId);

      await cartController.clear();

      debugPrint('[CHECKOUT] Redirection vers l\'ecran de succes...');
      Get.offAll(() => OrderSuccessScreen(order: savedOrder));
      
      return savedOrder;
    } catch (e) {
      debugPrint(
          '[CHECKOUT ERROR] Une erreur est survenue lors du traitement : $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
