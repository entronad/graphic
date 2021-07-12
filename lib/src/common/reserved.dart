abstract class Reserved {
  static const id = '_:id';
}

bool noReserved(List<String> identifiers) {
  final reservedTest = RegExp(r'^_:');
  for (var identifier in identifiers) {
    if (reservedTest.hasMatch(identifier)) {
      return false;
    }
  }
  return true;
}
