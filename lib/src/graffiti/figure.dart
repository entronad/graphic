import 'package:flutter/painting.dart';

/// The base class of figures.
///
/// A figure keeps information to paint a shape or text. The chart generates figures
/// from rendering methods in evaluation, they are the material for rendering engine
/// to paint the chart.
///
/// In custom rendering methods, user's task is to return figures needed.
abstract class Figure {
  /// Paints this figure.
  ///
  /// This method should only be override by subclass.
  void paint(Canvas canvas);
}

/// The fiure to paint a path.
class PathFigure extends Figure {
  /// Creates a path figure.
  PathFigure(this.path, this.style);

  /// The path to paint.
  final Path path;

  /// The style for painting.
  final Paint style;

  @override
  void paint(Canvas canvas) => canvas.drawPath(path, style);
}

/// The figure to paint the shadow of a path.
class ShadowFigure extends Figure {
  /// Creates a shadow figure.
  ShadowFigure(
    this.path,
    this.color,
    this.elevation,
  );

  /// The shadow path.
  final Path path;

  /// The shadow color.
  final Color color;

  /// The shadow elevation.
  final double elevation;

  @override
  void paint(Canvas canvas) => canvas.drawShadow(
        path,
        color,
        elevation,
        true,
      );
}

/// The figure to paint text.
///
/// See also:
///
/// - [RotatedTextFigure], to paint a rotated text.
class TextFigure extends Figure {
  /// Creates a text figure.
  TextFigure(this.painter, this.offset);

  /// The text painter.
  final TextPainter painter;

  /// The offset for [TextPainter.paint].
  final Offset offset;

  @override
  void paint(Canvas canvas) => painter.paint(canvas, offset);
}

/// The figure to paint a rotated text.
class RotatedTextFigure extends TextFigure {
  /// Creates a rotated text figure.
  RotatedTextFigure(
    TextPainter painter,
    Offset offset,
    this.rotation,
    this.axis,
  ) : super(painter, offset);

  /// The test rotation.
  final double rotation;

  /// The axis for rotation.
  final Offset axis;

  @override
  void paint(Canvas canvas) {
    canvas.save();

    canvas.translate(axis.dx, axis.dy);
    canvas.rotate(rotation);
    canvas.translate(-axis.dx, -axis.dy);

    super.paint(canvas);

    canvas.restore();
  }
}
