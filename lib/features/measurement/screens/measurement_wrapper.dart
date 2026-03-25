import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/features/measurement/screens/body_pose.dart';
import 'package:osho/features/measurement/screens/onboarding/measurement_onboarding.dart';

class MeasurementWrapper extends StatelessWidget {
  const MeasurementWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final bool hasSeenOnboarding = storage.read('hasSeenMeasurementOnboarding') ?? false;

    if (hasSeenOnboarding) {
      return const AutoPoseCaptureView();
    } else {
      return const MeasurementOnboardingScreen();
    }
  }
}
