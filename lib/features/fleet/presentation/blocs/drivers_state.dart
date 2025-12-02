import 'package:red_carga/features/fleet/domain/driver.dart';

enum DriversStatus { initial, loading, success, failure }

class DriversState {
  final DriversStatus status;
  final List<Driver> drivers;
  final String? message;
  final bool creating;
  final bool registeringAccount;
  final bool verifyingIdentity;
  final int? pendingAccountId;
  final String? verificationLink;
  final bool identityVerified;
  final String? creationMessage;
  final bool firebaseSigningIn;
  final bool firebaseReady;

  const DriversState({
    this.status = DriversStatus.initial,
    this.drivers = const [],
    this.message,
    this.creating = false,
    this.registeringAccount = false,
    this.verifyingIdentity = false,
    this.pendingAccountId,
    this.verificationLink,
    this.identityVerified = false,
    this.creationMessage,
    this.firebaseSigningIn = false,
    this.firebaseReady = false,
  });

  static const _kNoValue = Object();

  DriversState copyWith({
    DriversStatus? status,
    List<Driver>? drivers,
    Object? message = _kNoValue,
    bool? creating,
    bool? registeringAccount,
    bool? verifyingIdentity,
    Object? pendingAccountId = _kNoValue,
    Object? verificationLink = _kNoValue,
    bool? identityVerified,
    Object? creationMessage = _kNoValue,
    bool? firebaseSigningIn,
    bool? firebaseReady,
  }) {
    return DriversState(
      status: status ?? this.status,
      drivers: drivers ?? this.drivers,
      message: message == _kNoValue ? this.message : message as String?,
      creating: creating ?? this.creating,
      registeringAccount: registeringAccount ?? this.registeringAccount,
      verifyingIdentity: verifyingIdentity ?? this.verifyingIdentity,
      pendingAccountId: pendingAccountId == _kNoValue
          ? this.pendingAccountId
          : pendingAccountId as int?,
      verificationLink: verificationLink == _kNoValue
          ? this.verificationLink
          : verificationLink as String?,
      identityVerified: identityVerified ?? this.identityVerified,
      creationMessage: creationMessage == _kNoValue
          ? this.creationMessage
          : creationMessage as String?,
      firebaseSigningIn: firebaseSigningIn ?? this.firebaseSigningIn,
      firebaseReady: firebaseReady ?? this.firebaseReady,
    );
  }
}