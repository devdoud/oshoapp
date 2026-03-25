class CameraCapture {
  final String imagePath;
  final double? focalLength;
  final double? sensorOrientation;
  final double? aperture;
  final double? exposureOffset;
  final double? minExposureOffset;
  final double? maxExposureOffset;
  final double? zoomLevel;
  final double? minZoomLevel;
  final double? maxZoomLevel;
  final double? aspectRatio;
  final int? width;
  final int? height;

  CameraCapture({
    required this.imagePath,
    this.focalLength,
    this.sensorOrientation,
    this.aperture,
    this.exposureOffset,
    this.minExposureOffset,
    this.maxExposureOffset,
    this.zoomLevel,
    this.minZoomLevel,
    this.maxZoomLevel,
    this.aspectRatio,
    this.width,
    this.height,
  });
}
