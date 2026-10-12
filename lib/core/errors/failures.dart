import 'package:xstackapp/l10n/app_localizations.dart';

sealed class Failure {
  const Failure();

  String localizedMessage(AppLocalizations l10n);
}

class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, this.message});

  final int? statusCode;
  final String? message;

  @override
  String localizedMessage(AppLocalizations l10n) {
    if (statusCode == 409) {
      return l10n.accountAlreadyExists;
    }
    return l10n.serverErrorDefault;
  }

  @override
  String toString() => 'ServerFailure(statusCode: $statusCode, message: $message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([this.message]);

  final String? message;

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.networkErrorDefault;

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

enum AuthFailureType {
  invalidCredentials,
  sessionExpired,
}

class AuthFailure extends Failure {
  const AuthFailure([
    this.type = AuthFailureType.invalidCredentials,
    this.message,
  ]);

  const AuthFailure.invalidCredentials([this.message])
      : type = AuthFailureType.invalidCredentials;

  const AuthFailure.sessionExpired([this.message])
      : type = AuthFailureType.sessionExpired;

  final AuthFailureType type;
  final String? message;

  @override
  String localizedMessage(AppLocalizations l10n) {
    return switch (type) {
      AuthFailureType.invalidCredentials => l10n.authErrorDefault,
      AuthFailureType.sessionExpired => l10n.sessionExpired,
    };
  }

  @override
  String toString() => 'AuthFailure(type: $type, message: $message)';
}

enum ValidationType {
  emptyPhone,
  shortPhone,
  emptyPassword,
  shortPassword,
  shortUsername,
  invalidUsername,
  requiredField,
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.type, [this.message]);

  final ValidationType type;
  final String? message;

  @override
  String localizedMessage(AppLocalizations l10n) {
    return switch (type) {
      ValidationType.emptyPhone => l10n.enterPhoneValidation,
      ValidationType.shortPhone => l10n.shortPhoneValidation,
      ValidationType.emptyPassword => l10n.enterPasswordValidation,
      ValidationType.shortPassword => l10n.shortPasswordValidation,
      ValidationType.shortUsername => l10n.shortUsernameValidation,
      ValidationType.invalidUsername => l10n.invalidUsernameValidation,
      ValidationType.requiredField => l10n.requiredField,
    };
  }

  @override
  String toString() => 'ValidationFailure(type: $type, message: $message)';
}

class CacheFailure extends Failure {
  const CacheFailure([this.message]);

  final String? message;

  @override
  String localizedMessage(AppLocalizations l10n) => l10n.unexpectedError;

  @override
  String toString() => 'CacheFailure(message: $message)';
}
