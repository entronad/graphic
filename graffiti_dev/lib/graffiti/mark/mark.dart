import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' as painting;

import 'package:path_drawing/path_drawing.dart';
import 'package:graphic/src/util/assert.dart';

import '../util/gradient.dart';

abstract class MarkStyle {}

abstract class Mark<S extends MarkStyle> {
  Mark({
    required this.style,

    this.rotation,
    this.rotationAxis,
  }) : assert(rotation == null || rotationAxis != null);

  void paint(Canvas canvas) {
    if (rotation == null) {
      draw(canvas);
    } else {
      canvas.save();

      canvas.translate(rotationAxis!.dx, rotationAxis!.dy);
      canvas.rotate(rotation!);
      canvas.translate(-rotationAxis!.dx, -rotationAxis!.dy);

      draw(canvas);

      canvas.restore();
    }
  }

  @protected
  void draw(Canvas canvas);

  final S style;

  final double? rotation;

  final Offset? rotationAxis;
}

List<double>? _lerpDash(List<double>? a, List<double>? b, double t) {
  if (a == null || b == null || a.length != b.length) {
    return b;
  }
  final rst = <double>[];
  for (var i = 0; i < b.length; i++) {
    rst.add(lerpDouble(a[i], b[i], t)!);
  }
  return rst;
}

class ShapeStyle extends MarkStyle {
  ShapeStyle({
    this.fillColor,
    this.fillGradient,
    this.strokeColor,
    this.strokeGradient,
    this.gradientBounds,
    this.strokeWidth,
    this.strokeCap,
    this.strokeJoin,
    this.strokeMiterLimit,
    this.elevation,
    Color? shadowColor,
    this.dash,
    this.dashOffset,
  }) : assert(isSingle([fillColor, fillGradient], allowNone: true)),
       assert(isSingle([strokeColor, strokeGradient], allowNone: true)),
       assert(strokeColor != null || strokeGradient != null || (strokeWidth == null || strokeCap == null || strokeJoin == null || strokeMiterLimit == null)),
       assert(elevation == null || shadowColor == null),
       assert(dash == null || dashOffset == null),
       shadowColor = elevation == null
        ? null
        : fillGradient != null
          ? getShadowColor(fillGradient)
          : fillColor ?? (strokeGradient != null ? getShadowColor(strokeGradient) : (strokeColor ?? const Color(0xFF000000)));

  final Color? fillColor;

  final painting.Gradient? fillGradient;

  final Color? strokeColor;

  final painting.Gradient? strokeGradient;

  final Rect? gradientBounds;

  final double? strokeWidth;

  final StrokeCap? strokeCap;

  final StrokeJoin? strokeJoin;

  final double? strokeMiterLimit;
  
  final double? elevation;

  final Color? shadowColor;

  final List<double>? dash;

  final DashOffset? dashOffset;

  static ShapeStyle lerp(ShapeStyle a, ShapeStyle b, double t) => ShapeStyle(
    fillColor: Color.lerp(a.fillColor, b.fillColor, t),
    fillGradient: painting.Gradient.lerp(a.fillGradient, b.fillGradient, t),
    strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t),
    strokeGradient: painting.Gradient.lerp(a.strokeGradient, b.strokeGradient, t),
    gradientBounds: Rect.lerp(a.gradientBounds, b.gradientBounds, t),
    strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t),
    strokeCap: b.strokeCap,
    strokeJoin: b.strokeJoin,
    strokeMiterLimit: lerpDouble(a.strokeMiterLimit, b.strokeMiterLimit, t),
    elevation: lerpDouble(a.elevation, b.elevation, t),
    shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
    dash: _lerpDash(a.dash, b.dash, t),
    dashOffset: b.dashOffset,
  );
}

abstract class ShapeMark extends Mark<ShapeStyle> {
  ShapeMark({
    required ShapeStyle style,

    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  ) {
    drawPath(_path);

    if (style.fillColor != null || style.fillGradient != null) {
      _fillPaint = Paint();
      if (style.fillGradient != null) {
        _fillPaint!.shader = toUiGradient(style.fillGradient!, style.gradientBounds ?? _path.getBounds());
      } else {
        _fillPaint!.color = style.fillColor!;
      }
    }

    if (style.strokeColor != null || style.strokeGradient != null) {
      _strokePaint = Paint();
      if (style.strokeGradient != null) {
        _strokePaint!.shader = toUiGradient(style.strokeGradient!, style.gradientBounds ?? _path.getBounds());
      } else {
        _strokePaint!.color = style.strokeColor!;
      }
      _strokePaint!.style = PaintingStyle.stroke;
      if (style.strokeWidth != null) {
        _strokePaint!.strokeWidth = style.strokeWidth!;
      }
      if (style.strokeCap != null) {
        _strokePaint!.strokeCap = style.strokeCap!;
      }
      if (style.strokeJoin != null) {
        _strokePaint!.strokeJoin = style.strokeJoin!;
      }
      if (style.strokeMiterLimit != null) {
        _strokePaint!.strokeMiterLimit = style.strokeMiterLimit!;
      }
    }

    if (style.dash != null) {
      _dathPath = dashPath(_path, dashArray: CircularIntervalList(style.dash!), dashOffset: style.dashOffset);
    }
  }

  final _path = Path();

  Paint? _fillPaint;

  Paint? _strokePaint;

  Path? _dathPath;

  void drawPath(Path path);

  @override
  void draw(Canvas canvas) {
    if (style.elevation != null) {
      canvas.drawShadow(_path, style.shadowColor!, style.elevation!, true);
    }

    if (_fillPaint != null) {
      canvas.drawPath(_path, _fillPaint!);
    }

    if (_strokePaint != null) {
      canvas.drawPath(_dathPath ?? _path, _strokePaint!);
    }
  }
}

class BoxStyle extends MarkStyle {
  BoxStyle({
    this.offset,
    this.rotation,
    this.align,
  }) : super();

  /// The offset of the box from the anchor.
  final Offset? offset;

  /// The rotation of the box.
  ///
  /// The rotation axis is the anchor point with [offset].
  final double? rotation;

  /// How the box align to the anchor point.
  final painting.Alignment? align;
}

/// Calculates the real painting offset point for [BoxMark].
///
/// The [axis] is the anchor point with the [BoxMark]'s offset.
Offset getPaintPoint(
  Offset axis,
  double width,
  double height,
  painting.Alignment align,
) =>
    Offset(
      axis.dx - (width / 2) + ((width / 2) * align.x),
      axis.dy - (height / 2) + ((height / 2) * align.y),
    );

abstract class BoxMark<S extends BoxStyle> extends Mark<S> {
  BoxMark({
    required this.anchor,
    required this.defaultAlign,

    required S style,
  }) : super(
    style: style,
    rotation: style.rotation,
    rotationAxis: style.offset == null ? anchor : anchor + style.offset!,
  );

  final Offset anchor;

  painting.Alignment defaultAlign;

  @protected
  late final Offset paintPoint;
}
