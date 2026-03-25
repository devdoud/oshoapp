import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/utils/constants/api_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

/// ----- Entry point of the flutter app --------
Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// -- Load Environment Variables
  await dotenv.load(fileName: ".env");

  /// -- GetX Local Storage
  await GetStorage.init();

  // Initialize Date Formatting for Internationalization
  await initializeDateFormatting('fr_FR', null);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Stripe
  Stripe.publishableKey = dotenv.get('STRIPE_PUBLISHABLE_KEY');
  await Stripe.instance.applySettings();

  // Initialize Supabase FIRST (before AuthenticationRepository)
  await Supabase.initialize(
    url: APIConstants.supabaseUrl,
    anonKey: APIConstants.supabaseAnonKey,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then(
    (FirebaseApp value) => Get.put(AuthenticationRepository()),
  );

  runApp(const App());
}
