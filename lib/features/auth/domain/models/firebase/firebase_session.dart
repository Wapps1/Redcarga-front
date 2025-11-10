class FirebaseSession {
  final String idToken;
  final String uid;
  final String email;
  final int expiresAt; // timestamp en milisegundos

  FirebaseSession({
    required this.idToken,
    required this.uid,
    required this.email,
    required this.expiresAt,
  });
}

