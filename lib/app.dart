import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/bindings/general_bindings.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/localization/app_translations.dart';
import 'package:osho/utils/theme/theme.dart';

/// --- Use these Class to setup themes, initial Bindings, any animations and much more
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: OshoTheme.lightTheme,
      darkTheme: OshoTheme.darkTheme,
      initialBinding: GeneralBindings(),
      translations: AppTranslations(), // Add translations
      locale: Get.deviceLocale, // Get device locale
      fallbackLocale: const Locale('en', 'US'), // Fallback to English
      /// Show Loader or Circular Progress Indicator meanwhile Authentication Repository is deciding to show relevant screen
      // home: OnBoardingScreen(),
      // home: AutoPoseCaptureView(),
      home: const Scaffold(backgroundColor: OColors.primary, body: OLoader(color: Colors.white),),
    );
  }
}