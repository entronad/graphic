import 'dart:ui' show Offset, Radius;
import 'dart:math' show sin, pi;
import 'dart:ui';

import 'package:graphic/canvas/element.dart';

import 'path_segment.dart';
import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;

List<AbsolutePathSegment> _circle(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy),
    ArcToPoint(p.translate(r, 0), radius: Radius.circular(r)),
    ArcToPoint(p.translate(-r, 0), radius: Radius.circular(r)),
  ];

List<AbsolutePathSegment> _square(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy - r),
    LineTo(p.dx + r, p.dy - r),
    LineTo(p.dx + r, p.dy + r),
    LineTo(p.dx - r, p.dy + r),
    Close(),
  ];

List<AbsolutePathSegment> _diamond(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy),
    LineTo(p.dx, p.dy - r),
    LineTo(p.dx + r, p.dy),
    LineTo(p.dx, p.dy + r),
    Close(),
  ];

List<AbsolutePathSegment> _triangle(Offset p, double r) {
  final diffY = r * sin((1 / 3) * pi);
  return [
    MoveTo(p.dx - r, p.dy + diffY),
    LineTo(p.dx, p.dy - diffY),
    LineTo(p.dx + r, p.dy + diffY),
    Close(),
  ];
}

List<AbsolutePathSegment> _triangleDown(Offset p, double r) {
  final diffY = r * sin((1 / 3) * pi);
  return [
    MoveTo(p.dx - r, p.dy - diffY),
    LineTo(p.dx + r, p.dy - diffY),
    LineTo(p.dx, p.dy + diffY),
    Close(),
  ];
}

typedef Symbol = List<AbsolutePathSegment> Function(Offset p, double r);

abstract class Symbols {
  static const Symbol circle = _circle;
  static const Symbol square = _square;
  static const Symbol diamond = _diamond;
  static const Symbol triangle = _triangle;
  static const Symbol triangleDown = _triangleDown;
}

class Marker extends Shape {
  Marker(Cfg cfg) : super(cfg);

  @override
  bool get isOnlyHitBBox => true;

  List<AbsolutePathSegment> _getPath() {
    final attrs = this.attrs;
    final x = attrs.x;
    final y = attrs.y;
    final r = attrs.r;
    final symbol = attrs.symbol;
    
    return symbol(Offset(x, y), r);
  }

  @override
  void createPath(Path path) {
    final segments = _getPath();
    for (var segment in segments) {
      segment.applyTo(path);
    }
  }

  @override
  Element clone() => Marker(cfg.clone());
}
  