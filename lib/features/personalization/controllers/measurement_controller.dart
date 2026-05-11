import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/measurements/measurement_repository.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeasurementController extends GetxController {
  static MeasurementController get instance => Get.find();

  final isLoading = false.obs;
  final hasSeenOnboarding = false.obs;
  final _measurementRepository = Get.put(MeasurementRepository());
  RxList<MeasurementProfileModel> userMeasurements =
      <MeasurementProfileModel>[].obs;
  Rx<MeasurementProfileModel?> selectedProfile =
      Rx<MeasurementProfileModel?>(null);
  // Second profile for couple orders (selected manually at checkout)
  Rx<MeasurementProfileModel?> selectedProfile2 =
      Rx<MeasurementProfileModel?>(null);

  @override
  void onInit() {
    final storage = GetStorage();
    hasSeenOnboarding.value =
        storage.read('hasSeenMeasurementOnboarding') ?? false;
    fetchUserMeasurements();
    super.onInit();
  }

  void completeOnboarding() {
    GetStorage().write('hasSeenMeasurementOnboarding', true);
    hasSeenOnboarding.value = true;
  }

  String _formatError(Object error) {
    if (error is PostgrestException) {
      final parts = <String>[error.message];
      
      // Utilisation de cast sécurisé pour éviter l'erreur sur 'Object'
      final details = error.details?.toString() ?? '';
      if (details.isNotEmpty) parts.add(details);
      
      final hint = error.hint?.toString() ?? '';
      if (hint.isNotEmpty) parts.add('Hint: $hint');
      
      final code = error.code?.toString() ?? '';
      if (code.isNotEmpty) parts.add('Code: $code');

      return parts.join('\n');
    }

    return error.toString();
  }

  Future<void> fetchUserMeasurements() async {
    try {
      isLoading.value = true;
      final measurements = await _measurementRepository.fetchUserMeasurements();
      userMeasurements.assignAll(measurements);

      final primary = measurements.firstWhereOrNull((m) => m.isPrimary);
      if (primary != null) {
        selectedProfile.value = primary;
      }
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: _formatError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveMeasurement(MeasurementProfileModel profile) async {
    try {
      isLoading.value = true;
      await _measurementRepository.saveMeasurementProfile(profile);
      OLoaders.successSnackBar(
        title: 'Succes',
        message: 'Profil de mesures enregistre.',
      );
      await fetchUserMeasurements();
      return true;
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: _formatError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPrimary(String id) async {
    try {
      isLoading.value = true;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await _measurementRepository.setPrimaryProfile(id, userId);
      await fetchUserMeasurements();
      OLoaders.successSnackBar(title: 'Succes', message: 'Profil principal mis a jour.');
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: _formatError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMeasurement(String id) async {
    try {
      isLoading.value = true;
      await _measurementRepository.deleteProfile(id);
      OLoaders.successSnackBar(
        title: 'Succes',
        message: 'Profil supprime.',
      );
      await fetchUserMeasurements();
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: _formatError(e));
    } finally {
      isLoading.value = false;
    }
  }
}
