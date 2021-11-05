/// The base class of modifiers.
abstract class Modifier<T> {
  /// Modifies a value.
  void modify(T value);
}
