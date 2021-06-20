abstract class Shape {
  /// Force subclasses to implement equality.
  /// It will be used in operator ==.
  /// Usually they must be the same subtype and have equal fields.
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) =>
    this.equalTo(other);
}
