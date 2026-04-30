import 'package:get/get.dart';
import 'package:osho/data/repositories/measurements/measurement_tutorial_repository.dart';
import 'package:osho/features/measurement/models/measurement_tutorial_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeasurementTutorialController extends GetxController {
  static MeasurementTutorialController get instance => Get.find();

  final _repository = Get.put(MeasurementTutorialRepository());

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final tutorials = <MeasurementTutorialModel>[].obs;

  @override
  void onInit() {
    fetchTutorials();
    super.onInit();
  }

  String _formatError(Object error) {
    if (error is PostgrestException) {
      final details = error.details?.toString().trim() ?? '';
      final hint = error.hint?.toString().trim() ?? '';
      final code = error.code?.toString().trim() ?? '';

      final parts = <String>[
        error.message,
        if (details.isNotEmpty) details,
        if (hint.isNotEmpty) 'Hint: $hint',
        if (code.isNotEmpty) 'Code: $code',
      ];

      return parts.join('\n');
    }

    return error.toString();
  }

  Future<void> fetchTutorials() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final items = await _repository.fetchTutorials();
      tutorials.assignAll(items);
    } catch (e) {
      errorMessage.value = _formatError(e);
      tutorials.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
