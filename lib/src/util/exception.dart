bool testParamRedundant(List params) {
  int nonNullCount = 0;
  for (var param in params) {
    if (param != null) {
      nonNullCount++;
    }
  }
  return nonNullCount <= 1;
}

String paramRedundantWarning(String params) =>
  'Only one in $params is needed';
