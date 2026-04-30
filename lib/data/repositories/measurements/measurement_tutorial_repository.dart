import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:osho/features/measurement/models/measurement_tutorial_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeasurementTutorialRepository extends GetxController {
  static MeasurementTutorialRepository get instance => Get.find();

  static const String bucketName = 'measurement-tutorials';

  final _supabase = Supabase.instance.client;

  Future<List<MeasurementTutorialModel>> fetchTutorials() async {
    try {
      final response = await _supabase
          .from('measurement_tutorials')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final rows = List<Map<String, dynamic>>.from(response);
      return rows.map(_mapTutorial).toList();
    } catch (e) {
      debugPrint('[MEASUREMENT_TUTORIAL_REPOSITORY][FETCH] $e');
      rethrow;
    }
  }

  MeasurementTutorialModel _mapTutorial(Map<String, dynamic> row) {
    final storage = _supabase.storage.from(bucketName);

    String buildUrl(dynamic rawPath) {
      final path = rawPath?.toString().trim() ?? '';
      if (path.isEmpty) return '';
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return path;
      }
      return storage.getPublicUrl(path);
    }

    final videoPath = row['video_path']?.toString() ?? '';
    final thumbnailPath = row['thumbnail_path']?.toString() ?? '';

    return MeasurementTutorialModel(
      id: row['id']?.toString() ?? '',
      slug: row['slug']?.toString() ?? '',
      title: row['title']?.toString() ?? 'Tutoriel',
      description: row['description']?.toString() ?? '',
      videoPath: videoPath,
      videoUrl: buildUrl(videoPath),
      thumbnailPath: thumbnailPath,
      thumbnailUrl: buildUrl(thumbnailPath),
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      isActive: row['is_active'] == true,
    );
  }
}
