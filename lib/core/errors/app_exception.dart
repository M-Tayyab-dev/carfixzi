/// Application Exception Classes
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message, {super.code, super.details});
}

class EmailNotVerifiedException extends AuthException {
  EmailNotVerifiedException()
      : super('Your email address is not verified. Please verify via the link sent to your inbox.',
            code: 'email-not-verified');
}

class RoleUnauthorizedException extends AppException {
  RoleUnauthorizedException(String role)
      : super('Access denied. You do not have permissions for the $role portal.',
            code: 'unauthorized-role');
}

class ApiException extends AppException {
  final int? statusCode;
  ApiException(super.message, {this.statusCode, super.code, super.details});
}

class InventoryException extends AppException {
  InventoryException(super.message, {super.code});
}

class BookingException extends AppException {
  BookingException(super.message, {super.code});
}

