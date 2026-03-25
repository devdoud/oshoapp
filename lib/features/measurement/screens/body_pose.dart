
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:osho/features/measurement/controllers/body_controller.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:osho/common/widgets/loaders/loader.dart';

class AutoPoseCaptureView extends StatelessWidget {
  const AutoPoseCaptureView({super.key});
  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      create: (_) => CameraPoseController()..initializeCamera(),
      child: Consumer<CameraPoseController>(
        builder: (context, ctrl, _) {
          if (!ctrl.isCameraReady) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: OLoader(color: Colors.white)
            );
          }
          
          final camera = ctrl.cameraController!;
          final size = MediaQuery.of(context).size;
          final screenRatio = size.height / size.width;
          final previewSize = camera.value.previewSize;
          final previewRatio = previewSize!.height / previewSize!.width ;
          
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;
              await ctrl.stopCamera();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.loose,
              children: [


                // 1) Camera Preview Layer
                Center(
                  child: OverflowBox(
                    maxHeight: screenRatio > previewRatio ? size.height : size.width / previewSize.width * previewSize.height ,
                    maxWidth: screenRatio > previewRatio ? size.height / previewSize.height * previewSize.width : size.width,
                    child: CameraPreview(camera),
                  ),
                ),

                // 2) Guide Overlay (Ghost Image)
                if (!ctrl.photoTaken)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.35,
                        child: Image.asset('assets/images/measurement/pose_guide.png', fit: BoxFit.contain, alignment: Alignment.center),
                      ),
                    ),
                  ),

                // 3) Top Gradient for Visibility
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    ),
                  ),
                ),

                // 4) Visual Progress & Status Toast
                if (!ctrl.photoTaken)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status Toast
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (ctrl.progress > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                        value: ctrl.progress,
                                        color: Colors.greenAccent,
                                        backgroundColor: Colors.white24,
                                        strokeWidth: 3,
                                      )
                                    ),
                                  ),
                                Text(
                                  ctrl.alignmentHint,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                // 5) Result / Action Layer
                if (ctrl.photoTaken && ctrl.lastCapture != null)
                  Container(
                    color: Colors.black87,
                    child: SafeArea(
                      child: Column(
                        children: [
                          const Spacer(),
                          // Preview Card
                          // Preview Card with Measurements
                          Container(
                             height: size.height * 0.6,
                             margin: const EdgeInsets.symmetric(horizontal: 20),
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(24),
                               boxShadow: [
                                 BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))
                               ]
                             ),
                             clipBehavior: Clip.hardEdge,
                             child: LayoutBuilder(
                               builder: (context, constraints) {
                                 return Stack(
                                   fit: StackFit.expand,
                                   children: [
                                     Image.file(
                                       File(ctrl.lastCapture!.imagePath),
                                       fit: BoxFit.cover,
                                     ),
                                     if (ctrl.lastPose != null)
                                       CustomPaint(
                                         painter: _PosePainter(
                                           pose: ctrl.lastPose!,
                                           imageSize: Size(
                                             ctrl.lastCapture!.width!.toDouble(),
                                             ctrl.lastCapture!.height!.toDouble(),
                                           ),
                                           widgetSize: constraints.biggest,
                                         ),
                                       ),
                                   ],
                                 );
                               }
                             ),
                          ),
                          const Spacer(),
                          
                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      await _showSaveMeasurementSheet(context, ctrl);
                                    },
                                    child: const Text("Enregistrer mes mesures", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                       foregroundColor: Colors.white70,
                                    ),
                                    onPressed: () => ctrl.resetCapture(),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text("Reprendre la photo", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Close Button (Top Right)
                if (!ctrl.photoTaken)
                  Positioned(
                    top: 50, right: 16,
                    child: GestureDetector(
                      onTap: () async {
                        await ctrl.stopCamera();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                  ),

                
                // Processing Overlay
                if (ctrl.isProcessing)
                    Positioned.fill(
                        child: Container(
                            color: Colors.black54,
                            child: Center(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const OLoader(color: Colors.white, size: 60),
                                        const SizedBox(height: 16),
                                        const Text("Traitement IA en cours...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none))
                                    ],
                                )
                            ),
                        )
                    ),
              ],
            ),
            )
          );
        },
      ),
    );
  }
  Future<void> _showSaveMeasurementSheet(BuildContext context, CameraPoseController ctrl) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // Close preview sheet if any and prompt login
      Get.defaultDialog(
        title: 'Connexion requise',
        middleText: 'Connectez-vous pour enregistrer vos mesures.',
        textConfirm: 'Se connecter',
        textCancel: 'Plus tard',
        onConfirm: () {
          Get.back();
          Get.to(() => const LoginScreen());
        },
      );
      return;
    }

    final nameController = TextEditingController(text: 'Mesures IA');
    String selectedGender = 'femme';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Enregistrer ce scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du profil',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Genre',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Femme'),
                        selected: selectedGender == 'femme',
                        onSelected: (_) => setState(() => selectedGender = 'femme'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Homme'),
                        selected: selectedGender == 'homme',
                        onSelected: (_) => setState(() => selectedGender = 'homme'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final profileName = nameController.text.trim().isEmpty
                            ? 'Mesures IA'
                            : nameController.text.trim();
                        final measurementController = Get.put(MeasurementController());
                        final isPrimary = measurementController.userMeasurements.isEmpty;
                        final profile = MeasurementProfileModel(
                          userId: user.id,
                          profileName: profileName,
                          gender: selectedGender,
                          isPrimary: isPrimary,
                        );
                        await measurementController.saveMeasurement(profile);
                        if (context.mounted) Navigator.of(context).pop();

                        // Return to checkout if needed
                        if (Get.arguments is Map && Get.arguments['returnToCheckout'] == true) {
                          Get.back(result: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Enregistrer', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}

class _PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final Size widgetSize;

  _PosePainter({
    required this.pose,
    required this.imageSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.fill;

    // Calculate scaling factors
    // The image is displayed with BoxFit.cover
    // We need to determine the actual scale and offset of the image within the widget
    
    // Assume source image (preview) is typically vertical (height > width)
    // Widget area is also vertical.
    
    // Standard BoxFit.cover logic:
    double scaleX = widgetSize.width / imageSize.height; // Note: Image from camera stream is rotated 90deg usually, so width/height specific handling needed?
    // Actually, ML Kit coordinates are based on the image buffer.
    // If we are in portrait mode, the image buffer (from getImagesStream) is usually landscape (e.g. 1280x720) but rotated.
    // However, `CameraCapture` stores width/height from `previewSize`.
    // Let's rely on relative coordinates if possible or standard scaling.
    
    // Let's assume strict scaling for now and refine if rotation is an issue.
    // Actually, `CameraPreview` handles rotation. But our `Image.file` might be different.
    // If the image is saved vertically (portrait), then dimensions are WxH (e.g. 720x1280).
    
    final double scaleX_ = size.width / imageSize.width;
    final double scaleY_ = size.height / imageSize.height;
    // For BoxFit.cover, we take the MAX of the scales.
    // But wait, imageSize in controller is from `camera.value.previewSize` which is often "Landscape" (width > height) for Android/iOS internal buffers, but displayed Portrait.
    // This is tricky without running.
    // Let's assume the controller's `imagePath` file is a standard JPEG.
    // Usually `cameraController.takePicture()` saves it in the orientation it was taken (Portrait).
    
    // Simplification: Just map logic 0..1 to widget size if we normalized. 
    // Since we don't have normalized coords, we use the raw values relative to imageSize.
    
    // Let's assume the stored width/height are correct for the captured file.
    
    double scale = 1.0;
    double offsetX = 0.0;
    double offsetY = 0.0;
    
    double screenRatio = size.width / size.height;
    double imageRatio = imageSize.width / imageSize.height;
    
    if (screenRatio > imageRatio) {
      // Screen is wider than image => Fit Width, crop Height? No, Cover means fill.
      scale = size.width / imageSize.width;
      offsetY = (size.height - imageSize.height * scale) / 2;
    } else {
      // Screen is taller than image => Fit Height, crop Width?
      scale = size.height / imageSize.height;
      offsetX = (size.width - imageSize.width * scale) / 2;
    }

    Offset transform(PoseLandmark landmark) {
      // We assume the landmark coordinates match the stored imageSize
      return Offset(
        landmark.x * scale + offsetX,
        landmark.y * scale + offsetY,
      );
    }
    
    // Draw Connections
    void drawLine(PoseLandmarkType start, PoseLandmarkType end) {
      final s = pose.landmarks[start];
      final e = pose.landmarks[end];
      if (s != null && e != null) {
        canvas.drawLine(transform(s), transform(e), paint);
      }
    }

    // Draw Skeleton
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Draw Joints
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(transform(landmark), 4, jointPaint);
    }
    
    // Draw Measurements Texts
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawLabel(String text, Offset center) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }
    
    // Example Measurements
    final lShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    if (lShoulder != null && rShoulder != null) {
       Offset mid = (transform(lShoulder) + transform(rShoulder)) / 2;
       drawLabel("Épaules", mid - const Offset(0, 20));
    }

    final lHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rHip = pose.landmarks[PoseLandmarkType.rightHip];
    if (lHip != null && rHip != null) {
       Offset mid = (transform(lHip) + transform(rHip)) / 2;
       drawLabel("Hanches", mid - const Offset(0, 20));
    }

    // Height Estimation (Line from nose to feet center)
    final nose = pose.landmarks[PoseLandmarkType.nose];
    final lAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
    final rAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
    
    if (nose != null && lAnkle != null && rAnkle != null) {
      double feetY = (lAnkle.y + rAnkle.y) / 2;
      // Draw a vertical line side of body
      // Offset p1 = transform(nose);
      // Offset p2 = Offset(p1.dx, transform(lAnkle).dy); // Project down
      // canvas.drawLine(p1, p2, paint..color = Colors.greenAccent);
      // drawLabel("Hauteur", Offset(p1.dx + 20, (p1.dy + p2.dy)/2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
