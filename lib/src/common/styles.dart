import 'dart:ui';

/// The style of a stroke.
class StrokeStyle {
  /// Creates a stroke style
  StrokeStyle({
    this.color = const Color(0xff000000),
    this.width = 1,
  });

  /// The stroke color.
  Color color;

  /// The stroke width.
  double width;

  bool operator ==(Object other) =>
      other is StrokeStyle && color == other.color && width == other.width;

  /// Gets [Paint] object from this stroke style.
  ///
  /// If [paint] set, the result will be applied to it.
  Paint toPaint([Paint? paint]) => (paint ?? Paint())
    // This setting is a must, or the Canvas.drawPath will not render the stoke.
    ..style = PaintingStyle.stroke
    ..color = color
    ..strokeWidth = width;
}
