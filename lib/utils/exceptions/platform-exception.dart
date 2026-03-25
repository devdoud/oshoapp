/// Exception class for handling various platform-related errors.
class OPlatformException implements Exception {
  /// The error message associated with the exception.
  final String code;

  /// Constructor that takes an error message
  OPlatformException(this.code);

  /// Get the corresponding error message
  String get message {
    switch (code) {
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid login credentials. Please double-check your information.';
      case 'too-many-requests':
        return 'too many requests. Please try again later.';
      case 'invalid-argument':
        return 'Invalid argument provided to the authentification method';
      case 'invalid-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-phone-number':
        return 'The phone number provided is invalid. Please enter a valid phone number.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support for assistance.';
      case 'session-cookies-expired':
        return 'Session cookies have expired. Please log in again.';
      case 'uid-already-exists':
        return 'The user ID already exists. Please use a different ID.';
      case 'sign_in_failled':
        return 'Sign-in failed. Please try again later.';
      case 'network-request-failed':
        return 'Network request failed. Please check your internet connection and try again.';
      case 'internal-error':
        return 'An internal error occurred. Please try again later.';
      case 'invalid-verification-code':
        return 'The verification code provided is invalid. Please check the code and try again.';
      case 'invalid-verification-id':
        return 'The verification ID provided is invalid. Please request a new verification code.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      default:
        return 'An unexpected platform error occurred. Please try again later.';
    }
  }
}