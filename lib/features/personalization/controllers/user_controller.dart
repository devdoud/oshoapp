import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/user/user_repository.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  /// Récupérer les données de l'utilisateur
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final userRecord = await userRepository.fetchUserDetails();
      user(userRecord);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Sauvegarder ou mettre à jour le profil après authentification
  Future<void> saveUserRecord(AuthResponse? response) async {
    try {
      if (response != null && response.user != null) {
        final supabaseUser = response.user!;

        // Créer le modèle à partir des données Supabase
        final userModel = UserModel.fromSupabaseUser(supabaseUser);

        // Mettre à jour dans la table profiles (Public)
        await userRepository.updateUserDetails(userModel);

        // Mettre à jour l'état local
        user(userModel);
      }
    } catch (e) {
      OLoaders.warningSnackBar(
          title: 'Données non synchronisées',
          message: 'Une erreur est survenue lors de la mise à jour de votre profil.');
    }
  }

  /// Upload de la photo de profil (Placeholder)
  Future<void> uploadUserProfilePicture() async {
    try {
      OLoaders.successSnackBar(
          title: 'Bientôt disponible',
          message: 'Cette fonctionnalité sera disponible prochainement.');
    } catch (e) {
      OLoaders.errorSnackBar(
          title: 'Erreur', message: 'Impossible de mettre à jour la photo : $e');
    }
  }
}
