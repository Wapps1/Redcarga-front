enum SessionStatus {
  active,
  revoked,
  expired;

  String get value => name.toUpperCase();
}

