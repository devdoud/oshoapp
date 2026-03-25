import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/body.dart';

class UploadService {
  final String endpoint;

  UploadService({required this.endpoint});

  Future<http.Response> uploadCapture(CameraCapture capture) async {
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', capture.imagePath));

    request.fields.addAll({
      if (capture.focalLength != null) 'focalLength': capture.focalLength.toString(),
      if (capture.aperture != null) 'aperture': capture.aperture.toString(),
      if (capture.sensorOrientation != null) 'sensorOrientation': capture.sensorOrientation.toString(),
      if (capture.aspectRatio != null) 'aspectRatio': capture.aspectRatio.toString(),
      if (capture.exposureOffset != null) 'exposureOffset': capture.exposureOffset.toString(),
      if (capture.zoomLevel != null) 'zoomLevel': capture.zoomLevel.toString(),
      if (capture.width != null) 'width': capture.width.toString(),
      if (capture.height != null) 'height': capture.height.toString(),
    });

    final response = await request.send();
    return http.Response.fromStream(response);
  }
}
