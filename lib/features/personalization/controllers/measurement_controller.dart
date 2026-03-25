import 'package:get/get.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/measurements/measurement_repository.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';

class MeasurementController extends GetxController {
  static MeasurementController get instance => Get.find();

  final isLoading = false.obs;
  final _measurementRepository = Get.put(MeasurementRepository());
  RxList<MeasurementProfileModel> userMeasurements =
      <MeasurementProfileModel>[].obs;
  Rx<MeasurementProfileModel?> selectedProfile =
      Rx<MeasurementProfileModel?>(null);

  @override
  void onInit() {
    fetchUserMeasurements();
    super.onInit();
  }

  /// Fetch User Measurements
  Future<void> fetchUserMeasurements() async {
    try {
      isLoading.value = true;
      final measurements = await _measurementRepository.fetchUserMeasurements();
      userMeasurements.assignAll(measurements);

      // Select primary if available
      final primary = measurements.firstWhereOrNull((m) => m.isPrimary);
      if (primary != null) {
        selectedProfile.value = primary;
      }
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Save Measurement Profile
  Future<void> saveMeasurement(MeasurementProfileModel profile) async {
    try {
      isLoading.value = true;
      await _measurementRepository.saveMeasurementProfile(profile);
      OLoaders.successSnackBar(
          title: 'Succès', message: 'Profil de mesures enregistré.');
      fetchUserMeasurements(); // Refresh list
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete Measurement Profile
  Future<void> deleteMeasurement(String id) async {
    try {
      isLoading.value = true;
      await _measurementRepository.deleteProfile(id);
      OLoaders.successSnackBar(title: 'Succès', message: 'Profil supprimé.');
      fetchUserMeasurements();
    } catch (e) {
      OLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
