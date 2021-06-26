abstract class Annotation {
  Annotation({
    this.zIndex,
  });

  final int? zIndex;

  @override
  bool operator ==(Object other) =>
    other is Annotation &&
    zIndex == other.zIndex;
}
