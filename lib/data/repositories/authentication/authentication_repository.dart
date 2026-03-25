import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:osho/features/authentication/screens/onboarding/onboarding.dart';
import 'package:osho/navigation_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/features/authentication/screens/signup/verify_email.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// variables
  final deviceStorage = GetStorage();
  final _supabase = Supabase.instance.client;

  /// Get Authenticated User Data
  User? get authUser => _supabase.auth.currentUser;

  /// called from main.dart on app launch
  @override
  void onReady() {
    // Remove the native splash screen
    FlutterNativeSplash.remove();

    // Redirect to the appropriate screen
    screenRedirect();
  }

  /// Function to show relevant screen
  screenRedirect() async {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    // Check if valid session exists
    if (session != null && user != null) {
      // If email is not confirmed, redirect to Verify Email Screen
      if (user.emailConfirmedAt == null) {
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      } else {
        Get.offAll(() => const NavigationMenu());
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);

      // GUEST MODE: If not first time, always go to NavigationMenu
      // If first time, show onboarding
      if (deviceStorage.read('IsFirstTime') == true) {
        Get.offAll(const OnBoardingScreen());
      } else {
        Get.offAll(() => const NavigationMenu());
      }
    }
  }

  /* -------------------------------- Supabase Authentication --------------------------------- */

  /// [Supabase] - Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      return response;
    } catch (e) {
      throw 'Login failed: $e';
    }
  }

  /// [Supabase] - Register
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required bool termsAccepted,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'phone': phone,
            'terms_accepted': termsAccepted,
          },
          emailRedirectTo: 'io.supabase.osho://login-callback');
      return response;
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  String? getToken() {
    return _supabase.auth.currentSession?.accessToken;
  }

  /// [EmailVerification]  - EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      final email = _supabase.auth.currentUser?.email;
      if (email != null) {
        await _supabase.auth.resend(type: OtpType.signup, email: email);
      }
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  /// [EmailAuthentication] - FORGET PASSWORD
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }

  /* -------------------------------- Federated identity & social sign-in --------------------------------- */
  /// [GoogleAuthentication] - SignIn with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      throw 'Google Sign In not yet configured for Supabase';
    } catch (e) {
      if (kDebugMode) {
        print('Something went wrong : $e');
      }
      return null;
    }
  }

  /* -------------------------------- ./end Federated identity & social sign-in --------------------------------- */
  /// [LogooutUser] - Valid for any authentication.
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      Get.offAll(() => const NavigationMenu()); // Go to home after logout in guest mode
    } catch (e) {
      throw 'Something went wrong. Please try again later.';
    }
  }
}
