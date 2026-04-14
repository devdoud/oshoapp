import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/shop/controllers/checkout_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StripeController extends GetxController {
  static StripeController get instance => Get.find();

  final cardNameController = TextEditingController();

  Future<void> makePayment(
    double totalAmount, {
    String currency = 'XOF',
    required bool isCart,
  }) async {
    final checkoutController = CheckoutController.instance;

    try {
      checkoutController.isLoading.value = true;
      debugPrint('[STRIPE] Demarrage du processus de paiement...');

      final checkoutPayload = await checkoutController.buildCheckoutPayload(
        totalAmount: totalAmount,
        isCart: isCart,
      );

      final minorAmount = _toMinorUnits(totalAmount, currency);
      final paymentIntentData = await createPaymentIntent(
        minorAmount,
        currency,
        checkoutPayload,
      );

      if (paymentIntentData == null ||
          paymentIntentData['client_secret'] == null ||
          paymentIntentData['id'] == null) {
        throw 'Impossible de generer le secret de paiement.';
      }

      final clientSecret = paymentIntentData['client_secret'] as String;
      final paymentIntentId = paymentIntentData['id'] as String;
      debugPrint('[STRIPE] Intent cree. Secret recupere.');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'OSHO Shop',
          style: ThemeMode.light,
          billingDetails: BillingDetails(
            email: Supabase.instance.client.auth.currentUser?.email,
          ),
        ),
      );

      debugPrint('[STRIPE] Affichage de l\'interface de paiement...');
      await Stripe.instance.presentPaymentSheet();

      debugPrint('[STRIPE] Paiement valide cote client. Confirmation serveur...');
      await Future.delayed(const Duration(milliseconds: 800));

      await checkoutController.confirmStripeOrder(
        paymentIntentId: paymentIntentId,
        isCart: isCart,
      );
    } on StripeException catch (e) {
      debugPrint(
        '[STRIPE ERROR] Code: ${e.error.code}, Message: ${e.error.localizedMessage}',
      );
      if (e.error.code != FailureCode.Canceled) {
        OLoaders.errorSnackBar(
          title: 'Paiement echoue',
          message: e.error.localizedMessage ?? 'Erreur Stripe',
        );
      }
    } catch (e) {
      debugPrint('[GENERAL ERROR] Une erreur est survenue: $e');
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      checkoutController.isLoading.value = false;
      debugPrint('[STRIPE] Fin du processus.');
    }
  }

  Future<Session> _requireValidSession() async {
    final auth = Supabase.instance.client.auth;
    Session? session = auth.currentSession;

    if (session == null) {
      throw 'Vous devez etre connecte pour effectuer un paiement.';
    }

    try {
      final refresh = await auth.refreshSession();
      if (refresh.session != null) {
        session = refresh.session;
      }
    } catch (_) {
      final expiresAt = session?.expiresAt;
      if (expiresAt != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
            .subtract(const Duration(minutes: 1));
        if (DateTime.now().isAfter(expiry)) {
          rethrow;
        }
      }
    }

    return session!;
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
    int amount,
    String currency,
    Map<String, dynamic> orderPayload,
  ) async {
    try {
      final session = await _requireValidSession();
      debugPrint(
        '[STRIPE] Session OK user=${Supabase.instance.client.auth.currentUser?.id} expiresAt=${session.expiresAt}',
      );

      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
          'order_payload': orderPayload,
        },
      );

      if (response.status >= 400) {
        final data = response.data;
        final message = data is Map
            ? data['error']
            : data is String
                ? data
                : 'Erreur de paiement.';
        throw message.toString();
      }

      final data = response.data;
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      }

      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      debugPrint('[PAYMENT INTENT ERROR] $e');
      rethrow;
    }
  }

  int _toMinorUnits(double amount, String currency) {
    final zeroDecimalCurrencies = {'xof'};
    if (zeroDecimalCurrencies.contains(currency.toLowerCase())) {
      return amount.round();
    }
    return (amount * 100).round();
  }
}
