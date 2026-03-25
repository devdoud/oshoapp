import 'dart:async';
import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/common/widgets/success_screen/success_screen.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get to => Get.find<VerifyEmailController>();

  /// Send email whenever Verify Screen appears & set timer for auto redirect.
  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  /// Send Email verifiction link
  sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();
      OLoaders.successSnackBar(
          title: 'Email sent',
          message: 'Please check your inbox and verify your email.');
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Timer to automatically redirect on Email verifiction
  setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        // getUser() force la récupération des dernières données depuis le serveur Supabase
        final response = await Supabase.instance.client.auth.getUser();
        final user = response.user;

        if (user?.emailConfirmedAt != null) {
          timer.cancel();
          Get.off(() => SuccessScreen(
              image: OImages.successfullyRegisterAnimation,
              title: OText.yourAcountCreattedTitle,
              subTitle: OText.yourAcountCreattedSubTitle,
              onPressed: () =>
                  AuthenticationRepository.instance.screenRedirect()));
        }
      } catch (e) {
        // On ignore les erreurs silencieuses pendant le polling
      }
    });
  }

  /// Manually check if Email verified
  checkEmailverificationStatus() async {
    try {
      final response = await Supabase.instance.client.auth.getUser();
      final currentUser = response.user;

      if (currentUser != null && currentUser.emailConfirmedAt != null) {
        Get.off(() => SuccessScreen(
            image: 'assets/logos/succes_animation.json',
            title: OText.yourAcountCreattedTitle,
            subTitle: OText.yourAcountCreattedSubTitle,
            onPressed: () =>
                AuthenticationRepository.instance.screenRedirect()));
      } else {
        OLoaders.warningSnackBar(
            title: 'Non vérifié',
            message: 'Veuillez confirmer votre e-mail pour continuer.');
      }
    } catch (e) {
      OLoaders.errorSnackBar(
          title: 'Erreur', message: 'Impossible de vérifier le statut.');
    }
  }
}
