class Email {
  final String value;

  Email(this.value) {
    if (!_isValid(value)) {
      throw ArgumentError('Invalid email format');
    }
  }

  bool _isValid(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  @override
  String toString() => value;
}

