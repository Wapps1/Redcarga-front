class Password {
  final String value;

  Password(this.value) {
    if (value.length < 8) {
      throw ArgumentError('Password must be at least 8 characters');
    }
  }

  @override
  String toString() => value;
}

