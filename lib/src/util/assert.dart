bool isSingle(List params, {allowNone = false}) {
  int count = 0;
  for (var param in params) {
    if (param != null) {
      count++;
    }
  }
  return allowNone ? count <= 1 : count == 1;
}
