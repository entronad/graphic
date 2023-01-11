import 'dart:math';
import 'package:flutter/painting.dart';

import 'package:graphic/src/util/math.dart';

import 'mark.dart';

void _drawSector({
  required Path path,
  required Offset center,
  required double startRadius,
  required double endRadius,
  required double startAngle,
  required double endAngle,
  BorderRadius? borderRadius,
}) {
  final sweepAngle = endAngle - startAngle;
  final radialInterval = endRadius - startRadius;
  
  if (sweepAngle.equalTo(0) || radialInterval.equalTo(0)) {
    return;
  }

  final sweepAngleAbs = sweepAngle.abs();

  // The canvas can not fill a ring, so it is devided to two semi rings.
  if (sweepAngleAbs.equalTo(pi * 2)) {
    _drawSector(path: path, center: center, startRadius: startRadius, endRadius: endRadius, startAngle: 0, endAngle: pi);
    _drawSector(path: path, center: center, startRadius: startRadius, endRadius: endRadius, startAngle: pi, endAngle: pi * 2);
    return;
  }

  if (borderRadius == null || borderRadius == BorderRadius.zero) {
    path.moveTo(
        cos(startAngle) * endRadius + center.dx, sin(startAngle) * endRadius + center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: endRadius),
      startAngle,
      sweepAngle,
      false,
    );
    path.lineTo(cos(endAngle) * startRadius + center.dx, sin(endAngle) * startRadius + center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: startRadius),
      endAngle,
      -sweepAngle,
      false,
    );
    path.close();
  } else {
    double arcStart;
    double arcEnd;
    double arcSweep;

    // Makes sure the corners correct when radiuses or angles are reversed.

    final cornerCircularSign = sweepAngle / sweepAngleAbs;
    final cornerRadialSign = radialInterval / radialInterval.abs();

    // Calculates the top angles.

    arcStart = startAngle + cornerCircularSign * (borderRadius.topLeft.x / endRadius);
    arcEnd = endAngle - cornerCircularSign * (borderRadius.topRight.x / endRadius);
    arcSweep = arcEnd - arcStart;

    // The top left corner.

    path.moveTo(
      cos(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dx,
      sin(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dy,
    );
    path.quadraticBezierTo(
      cos(startAngle) * endRadius + center.dx,
      sin(startAngle) * endRadius + center.dy,
      cos(arcStart) * endRadius + center.dx,
      sin(arcStart) * endRadius + center.dy,
    );

    // The top arc.

    path.arcTo(
      Rect.fromCircle(center: center, radius: endRadius),
      arcStart,
      arcSweep,
      false,
    );

    // The top right corner.

    path.quadraticBezierTo(
      cos(endAngle) * endRadius + center.dx,
      sin(endAngle) * endRadius + center.dy,
      cos(endAngle) * (endRadius - cornerRadialSign * borderRadius.topRight.y) + center.dx,
      sin(endAngle) * (endRadius - cornerRadialSign * borderRadius.topRight.y) + center.dy,
    );
    path.lineTo(
      cos(endAngle) * (startRadius + cornerRadialSign * borderRadius.bottomRight.y) + center.dx,
      sin(endAngle) * (startRadius + cornerRadialSign * borderRadius.bottomRight.y) + center.dy,
    );

    // Calculates the bottom angles.

    arcStart = startAngle + cornerCircularSign * (borderRadius.bottomLeft.x / startRadius);
    arcEnd = endAngle - cornerCircularSign * (borderRadius.bottomRight.x / startRadius);
    arcSweep = arcEnd - arcStart;

    // The bottom right corner.

    path.quadraticBezierTo(
      cos(endAngle) * startRadius + center.dx,
      sin(endAngle) * startRadius + center.dy,
      cos(arcEnd) * startRadius + center.dx,
      sin(arcEnd) * startRadius + center.dy,
    );

    // The bottom arc.

    path.arcTo(
      Rect.fromCircle(center: center, radius: startRadius),
      arcEnd,
      -arcSweep,
      false,
    );

    // The bottom left corner.
    path.quadraticBezierTo(
      cos(startAngle) * startRadius + center.dx,
      sin(startAngle) * startRadius + center.dy,
      cos(startAngle) * (startRadius + cornerRadialSign * borderRadius.bottomLeft.y) + center.dx,
      sin(startAngle) * (startRadius + cornerRadialSign * borderRadius.bottomLeft.y) + center.dy,
    );

    path.close();
  }
}

class SectorMark extends Primitive {
  SectorMark({
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.startAngle,
    required this.endAngle,
    this.borderRadius,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Offset center;

  final double startRadius;

  final double endRadius;

  final double startAngle;

  final double endAngle;

  final BorderRadius? borderRadius;
  
  @override
  void createPath(Path path) =>
    _drawSector(path: path, center: center, startRadius: startRadius, endRadius: endRadius, startAngle: startAngle, endAngle: endAngle, borderRadius: borderRadius);
}
