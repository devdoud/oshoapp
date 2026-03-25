import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/body.dart';
import '../services/pose_service.dart';

class CameraPoseController extends ChangeNotifier {
  CameraController? cameraController;
  late PoseService _poseService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isDetecting = false;
  bool photoTaken = false;
  bool isProcessing = false;
  CameraCapture? lastCapture;
  Pose? lastPose;
  bool isClosing = false;
  bool _isDisposed = false;

  DateTime _lastDetectionTime = DateTime.now();
  
  // Progress tracking (0 to 10)
  int poseHoldCounter = 0;
  // Maximum hold count required
  final int maxPoseHold = 10;
  
  String alignmentHint = "Veuillez vous centrer dans le cadre";

  /// Returns progress as a value between 0.0 and 1.0 for UI indicators
  double get progress => (poseHoldCounter / maxPoseHold).clamp(0.0, 1.0);

  bool get isCameraReady => !_isDisposed && cameraController != null && cameraController!.value.isInitialized;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => throw Exception("Caméra frontale non trouvée."),
      );

      cameraController = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await cameraController!.initialize();
      _poseService = PoseService();

      if (!_isDisposed) {
        cameraController!.startImageStream(_processCameraImage);
      }

      print("✅ Caméra initialisée avec succès.");
      notifyListeners();
    } catch (e) {
      print("❌ Erreur lors de l'initialisation de la caméra : $e");
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDisposed || isDetecting || photoTaken) return;

    final now = DateTime.now();
    if (now.difference(_lastDetectionTime).inMilliseconds < 500) return;
    _lastDetectionTime = now;

    isDetecting = true;

    try {
      final poses = await _poseService.detectPose(image, cameraController!.description);
      if (_isDisposed) return;

      if (poses.isNotEmpty) {
        final pose = poses.first;

        if (_poseService.isFullBodyVisibleAndStraight(pose)) {
          poseHoldCounter++;
          alignmentHint = "Maintenez la pose...";
          lastPose = pose;
          
          if (poseHoldCounter >= maxPoseHold) {
            await _takePhoto();
          } else {
            notifyListeners();
          }
        } else {
          _resetProgress("❌ Posture incorrecte. Redressez-vous.");
        }
      } else {
        _resetProgress("❌ Aucun corps détecté.");
      }
    } catch (e) {
      print("⚠️ Erreur pendant la détection : $e");
    } finally {
      isDetecting = false;
    }
  }

  void _resetProgress(String hint) {
    if (poseHoldCounter > 0) {
      poseHoldCounter = 0;
      alignmentHint = hint;
      notifyListeners();
    } else if (alignmentHint != hint) {
        alignmentHint = hint;
        notifyListeners();
    }
  }

  Future<void> _takePhoto() async {
    isProcessing = true;
    notifyListeners();
    
    await cameraController!.stopImageStream();
    
    // Simulate AI Processing
    await Future.delayed(const Duration(seconds: 2));
    
    isProcessing = false;
    photoTaken = true;
    alignmentHint = "✅ Capture réussie !";
    notifyListeners(); 

    await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    
    try {
        final file = await cameraController!.takePicture();
        final val = cameraController!.value;
        
        lastCapture = CameraCapture(
          imagePath: file.path,
          sensorOrientation: cameraController!.description.sensorOrientation.toDouble(),
          aspectRatio: val.aspectRatio,
          width: val.previewSize?.width.toInt(),
          height: val.previewSize?.height.toInt(),
        );
        print("📸 Photo capturée à ${file.path}");
        notifyListeners();
    } catch(e) {
        print("Error taking picture: $e");
        // Restart stream if capture failed
        resetCapture();
    }
  }

  void resetCapture() {
    print("🔄 Réinitialisation de la capture");
    photoTaken = false;
    isProcessing = false;
    lastCapture = null;
    lastPose = null;
    poseHoldCounter = 0;
    alignmentHint = "Veuillez vous centrer dans le cadre";
    // Check if controller is initialized before restarting stream
    if (cameraController != null && cameraController!.value.isInitialized) {
        cameraController!.startImageStream(_processCameraImage);
    }
    notifyListeners();
  }

  Future<void> stopCamera() async {
    if (_isDisposed) return;
    isClosing = true;
    _isDisposed = true;
    
    // 1. Notify UI to remove CameraPreview immediately
    notifyListeners(); 

    try {
      if (cameraController != null) {
        if (cameraController!.value.isStreamingImages) {
          await cameraController!.stopImageStream();
        }
        await cameraController!.dispose();
      }
      cameraController = null;
      
      _poseService.dispose();
      _audioPlayer.dispose();
    } catch (e) {
      print("Error stopping camera: $e");
    }
  }

  @override
  void dispose() {
    // If stopCamera was already called, _isDisposed is true, so we just super.dispose
    if (!_isDisposed) {
      stopCamera(); // Ensure cleanup happens if we didn't call it manually
    }
    super.dispose();
  }
}
