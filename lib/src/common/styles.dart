import 'dart:ui';

class StrokeStyle {
  StrokeStyle({
    this.color = const Color(0xff000000),
    this.width = 1,
  });

  Color color;

  double width;

  bool operator ==(Object other) =>
    other is StrokeStyle &&
    color == other.color &&
    width == other.width;
  
  Paint toPaint([Paint? paint]) =>
    (paint ?? Paint())
      ..style = PaintingStyle.stroke  // Or the canvas.drawPath will not draw the stoke
      ..color = color
      ..strokeWidth = width;
}
