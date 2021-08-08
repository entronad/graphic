import 'dart:ui';

class StrokeStyle {
  const StrokeStyle({
    this.color = const Color(0xff000000),
    this.width = 1,
  });

  final Color color;

  final double width;

  bool operator ==(Object other) =>
    other is StrokeStyle &&
    color == other.color &&
    width == other.width;
  
  Paint toPaint([Paint? paint]) =>
    (paint ?? Paint())
      ..color = color
      ..strokeWidth = width;
}
