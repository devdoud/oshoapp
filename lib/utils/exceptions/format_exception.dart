/// Custom format exception class to handle various formatting errors.
class OFormatException implements Exception {
  /// The associated error message.
  final String message;

  /// Default constructor with a generic error message
  const OFormatException([this.message = 'An unexpected format error occured. Please check your input.']);


  /// Create a format exception with a specific message
  factory OFormatException.fromMessage(String message) {
    return OFormatException(message);
  }

  /// Get the corresponding error message
  String get formattedMessage => message;

  /// Create a format exception from a specific error code.
  factory OFormatException.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const OFormatException('The email address format is invalid. Please enter a valid email.');
      case 'invalid-phone-number-format':
        return const OFormatException('The provided phone number format is invalid. Please enter a valid phone number.');
      case 'invalid-date-format':
        return OFormatException('The date format is invalid. Please enter a valid date.');
      case 'invalid-url-format':
        return OFormatException('The URL format is invalid. Please enter a valid URL.');
      case 'invalid-credit-card-format':
        return OFormatException('The credit card format is invalid. Please enter a valid credit card number.');
      case 'invalid-numeric-format':
        return OFormatException('The input should be a valid numeric format.');
      default:
        return const  OFormatException();
    }
  }
}