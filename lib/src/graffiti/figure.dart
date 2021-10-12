import 'dart:ui';

import 'package:flutter/painting.dart';

abstract class Figure {
  /// Subclass override this method.
  void paint(Canvas canvas);
}

// Path has it's own transform method.
class PathFigure extends Figure {
  PathFigure(this.path, this.style);
  
  final Path path;

  final Paint style;

  @override
  void paint(Canvas canvas) =>
    canvas.drawPath(path, style);
}

class ShadowFigure extends Figure {
  ShadowFigure(
    this.path,
    this.color,
    this.elevation,
  );

  final Path path;

  final Color color;

  final double elevation;

  @override
  void paint(Canvas canvas) => canvas.drawShadow(
    path,
    color,
    elevation,
    true,
  );
}

class TextFigure extends Figure {
  TextFigure(this.painter, this.offset);

  final TextPainter painter;

  final Offset offset;

  @override
  void paint(Canvas canvas) =>
    painter.paint(canvas, offset);
}

class RotatedTextFigure extends TextFigure {
  RotatedTextFigure(
    TextPainter painter,
    Offset offset,
    this.rotation,
    this.axis,
  ) : super(painter, offset);

  final double rotation;

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
