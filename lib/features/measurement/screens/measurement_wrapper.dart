import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/features/measurement/screens/measurement_profile_display.dart';
import 'package:osho/features/measurement/screens/measurement_tutorial.dart';
import 'package:osho/features/measurement/screens/onboarding/measurement_onboarding.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';

class MeasurementWrapper extends StatelessWidget {
  const MeasurementWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MeasurementController());

    return Obx(() {
      if (!controller.hasSeenOnboarding.value) {
        return const MeasurementOnboardingScreen();
      }

      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (controller.userMeasurements.isNotEmpty) {
        return const MeasurementProfileDisplayScreen();
      } else {
        return const MeasurementTutorialScreen();
      }
    });
  }
}
