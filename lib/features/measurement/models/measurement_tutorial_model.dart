class MeasurementTutorialModel {
  final String id;
  final String slug;
  final String title;
  final String description;
  final String videoPath;
  final String videoUrl;
  final String thumbnailPath;
  final String thumbnailUrl;
  final int sortOrder;
  final bool isActive;

  const MeasurementTutorialModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.videoPath,
    required this.videoUrl,
    required this.thumbnailPath,
    required this.thumbnailUrl,
    required this.sortOrder,
    required this.isActive,
  });
}
