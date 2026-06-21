import 'dart:async';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/common/widgets/success_screen/success_screen.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get to => Get.find<VerifyEmailController>();

  // Email passé depuis l'écran d'inscription (nécessaire car la session
  // n'existe pas encore avant confirmation — currentUser serait null)
  String? userEmail;

  /// Send email whenever Verify Screen appears & set timer for auto redirect.
  @override
  void onInit() {
    super.onInit();
    _sendOnOpen();
    _startPolling();
  }

  void _sendOnOpen() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification(email: userEmail);
      OLoaders.successSnackBar(
        title: 'email_sent_title'.tr,
        message: 'email_sent_msg'.tr,
      );
    } catch (_) {
      // L'email initial est déjà envoyé par signUp() — on ignore l'échec du renvoi
    }
  }

  void _startPolling() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        // Après que l'utilisateur clique le lien, Supabase crée une session ;
        // refreshSession() permet de détecter ce changement côté client.
        await Supabase.instance.client.auth.refreshSession();
        final user = Supabase.instance.client.auth.currentUser;
        if (user?.emailConfirmedAt != null) {
          timer.cancel();
          _navigateToSuccess();
        }
      } catch (_) {}
    });
  }

  void _navigateToSuccess() {
    Get.off(() => SuccessScreen(
      image: OImages.successfullyRegisterAnimation,
      title: 'account_created_title'.tr,
      subTitle: 'verify_email_sub'.tr,
      onPressed: () => AuthenticationRepository.instance.screenRedirect(),
    ));
  }

  /// Bouton "Renvoyer l'email"
  void sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification(email: userEmail);
      OLoaders.successSnackBar(
        title: 'email_resent_title'.tr,
        message: 'email_resent_msg'.tr,
      );
    } catch (e) {
      OLoaders.errorSnackBar(
        title: 'error_title'.tr,
        message: 'email_send_failed'.tr,
      );
    }
  }

  /// Bouton "Continuer" — vérification manuelle
  void checkEmailverificationStatus() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.emailConfirmedAt != null) {
        _navigateToSuccess();
      } else {
        OLoaders.warningSnackBar(
          title: 'not_confirmed_title'.tr,
          message: 'not_confirmed_msg'.tr,
        );
      }
    } catch (e) {
      OLoaders.warningSnackBar(
        title: 'not_confirmed_title'.tr,
        message: 'not_confirmed_msg'.tr,
      );
    }
  }
}
