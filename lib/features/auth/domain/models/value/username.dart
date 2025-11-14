class Username {
  final String value;

  Username(this.value) {
    if (value.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
  }

  @override
  String toString() => value;
}


