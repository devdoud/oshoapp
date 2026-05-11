import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/user/user_repository.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());

  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

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

  Future<void> saveUserRecord(AuthResponse? response) async {
    try {
      if (response != null && response.user != null) {
        final supabaseUser = response.user!;
        final userModel = UserModel.fromSupabaseUser(supabaseUser);
        await userRepository.updateUserDetails(userModel);
        user(userModel);
      }
    } catch (e) {
      OLoaders.warningSnackBar(
        title: 'Données non synchronisées',
        message: 'Une erreur est survenue lors de la mise à jour de votre profil.',
      );
    }
  }

  /// Ouvre la galerie ou la caméra, uploade vers Supabase Storage
  /// et met à jour avatar_url dans profiles.
  Future<void> uploadUserProfilePicture({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (picked == null) return;

      profileLoading.value = true;

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        OLoaders.warningSnackBar(
          title: 'Non connecté',
          message: 'Veuillez vous connecter pour modifier votre photo.',
        );
        return;
      }

      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final storagePath = '$userId/avatar.$ext';

      // Upload (upsert = remplace si existe déjà)
      await _supabase.storage.from('avatars').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      // URL publique avec cache-buster pour forcer le rechargement
      final rawUrl =
          _supabase.storage.from('avatars').getPublicUrl(storagePath);
      final publicUrl = '$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // Persister dans profiles
      await userRepository.updateSingleField({'avatar_url': publicUrl});

      // Mettre à jour l'état local
      user.update((val) => val?.profilePicture = publicUrl);

      OLoaders.successSnackBar(
        title: 'Photo mise à jour',
        message: 'Votre photo de profil a été modifiée avec succès.',
      );
    } catch (e) {
      OLoaders.errorSnackBar(
        title: 'Erreur upload',
        message: 'Impossible de mettre à jour la photo : $e',
      );
    } finally {
      profileLoading.value = false;
    }
  }

  /// Supprime la photo de profil (remet avatar_url à vide)
  Future<void> removeProfilePicture() async {
    try {
      profileLoading.value = true;
      await userRepository.updateSingleField({'avatar_url': ''});
      user.update((val) => val?.profilePicture = '');
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: 'Impossible de mettre à jour. Veuillez réessayer.');
    } finally {
      profileLoading.value = false;
    }
  }
}
