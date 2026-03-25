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

  Future<void> makePayment(double totalAmount,
      {String currency = 'XOF',
      Future<void> Function(double totalAmount)? onSuccess}) async {
    final checkoutController = CheckoutController.instance;
    try {
      checkoutController.isLoading.value = true;
      debugPrint('[STRIPE] Demarrage du processus de paiement...');

      // 1. Create Payment Intent via Supabase Edge Function
      final minorAmount = _toMinorUnits(totalAmount, currency);
      final paymentIntentData = await createPaymentIntent(
        minorAmount,
        currency,
      );

      if (paymentIntentData == null || paymentIntentData['client_secret'] == null) {
        throw 'Impossible de generer le secret de paiement.';
      }

      final String clientSecret = paymentIntentData['client_secret'];
      debugPrint('[STRIPE] Intent cree. Secret recupere.');

      // 2. Initialize Payment Sheet
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

      // 3. Display Payment Sheet
      debugPrint('[STRIPE] Affichage de l\'interface de paiement...');
      await Stripe.instance.presentPaymentSheet();

      // --- CRITICAL DELAY ---
      debugPrint('[STRIPE] Paiement valide cote client. Attente fermeture UI...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // 4. Finalize Order & Redirect
      debugPrint('[DATABASE] Tentative d\'enregistrement de la commande...');
      if (onSuccess != null) {
        await onSuccess(totalAmount);
      } else {
        await checkoutController.processOrder(totalAmount);
      }
      debugPrint('[DATABASE] Commande enregistree avec succes.');
      debugPrint('[WEBHOOK] Le webhook notify-tailors devrait etre declenche...');
    } on StripeException catch (e) {
      debugPrint(
          '[STRIPE ERROR] Code: ${e.error.code}, Message: ${e.error.localizedMessage}');
      if (e.error.code != FailureCode.Canceled) {
        OLoaders.errorSnackBar(
            title: 'Paiement echoue',
            message: e.error.localizedMessage ?? 'Erreur');
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
      try {
        final refresh = await auth.refreshSession();
        session = refresh.session;
      } catch (_) {
        session = null;
      }
    }

    if (session == null) {
      throw 'Vous devez etre connecte pour effectuer un paiement.';
    }

    // Rafraîchir si le token expire dans moins d'1 minute
    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
          .subtract(const Duration(minutes: 1));
      if (DateTime.now().isAfter(expiry)) {
        final refresh = await auth.refreshSession();
        if (refresh.session != null) {
          session = refresh.session;
        }
      }
    }

    return session!;
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      int amount, String currency) async {
    try {
      final session = await _requireValidSession();
      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
        body: {
          'amount': amount,
          'currency': currency,
        },
      );

      if (response.status >= 400) {
        throw 'Erreur de paiement (status: ${response.status}).';
      }

      final data = response.data;
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
      return data as Map<String, dynamic>?;
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
