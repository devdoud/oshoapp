import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';

class PoseService {
  late final PoseDetector _poseDetector;

  PoseService() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );
  }

  void dispose() {
    _poseDetector.close();
  }

  Future<List<Pose>> detectPose(CameraImage image, CameraDescription cameraDescription) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final imageRotation = InputImageRotationValue.fromRawValue(cameraDescription.sensorOrientation)
        ?? InputImageRotation.rotation0deg;
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw)
        ?? InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
    return await _poseDetector.processImage(inputImage);
  }

  bool isFullBodyVisibleAndStraight(Pose pose) {
    final requiredLandmarks = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    for (var type in requiredLandmarks) {
      final landmark = pose.landmarks[type];
      if (landmark == null || landmark.likelihood < 0.5) return false;
    }

    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
    final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle]!;
    final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle]!;
    final nose = pose.landmarks[PoseLandmarkType.nose]!;

    // Check alignment (horizontal shoulders and hips)
    final shouldersAligned = (leftShoulder.y - rightShoulder.y).abs() < 50;
    final hipsAligned = (leftHip.y - rightHip.y).abs() < 50;

    // Check full height visibility (simple check ensuring feet are significantly below nose)
    final heightVisible = (nose.y - ((leftAnkle.y + rightAnkle.y) / 2)).abs() > 300;

    // Ensure user is standing relatively straight (ankles roughly below shoulders)
    // This is a basic check, can be tuned.
    final standingStraight = 
      (leftShoulder.x - leftAnkle.x).abs() < 100 && 
      (rightShoulder.x - rightAnkle.x).abs() < 100;

    return shouldersAligned && hipsAligned && heightVisible && standingStraight;
  }
}
