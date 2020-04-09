import 'dart:ui' show Offset, Radius;
import 'dart:math' show sin, pi;
import 'dart:ui';

import 'package:graphic/canvas/element.dart';

import 'path_command.dart';
import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;

List<AbsolutePathCommand> _circle(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy),
    ArcToPoint(p.translate(r, 0), radius: Radius.circular(r)),
    ArcToPoint(p.translate(-r, 0), radius: Radius.circular(r)),
  ];

List<AbsolutePathCommand> _square(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy - r),
    LineTo(p.dx + r, p.dy - r),
    LineTo(p.dx + r, p.dy + r),
    LineTo(p.dx - r, p.dy + r),
    Close(),
  ];

List<AbsolutePathCommand> _diamond(Offset p, double r) =>
  [
    MoveTo(p.dx - r, p.dy),
    LineTo(p.dx, p.dy - r),
    LineTo(p.dx + r, p.dy),
    LineTo(p.dx, p.dy + r),
    Close(),
  ];

List<AbsolutePathCommand> _triangle(Offset p, double r) {
  final diffY = r * sin((1 / 3) * pi);
  return [
    MoveTo(p.dx - r, p.dy + diffY),
    LineTo(p.dx, p.dy - diffY),
    LineTo(p.dx + r, p.dy + diffY),
    Close(),
  ];
}

List<AbsolutePathCommand> _triangleDown(Offset p, double r) {
  final diffY = r * sin((1 / 3) * pi);
  return [
    MoveTo(p.dx - r, p.dy - diffY),
    LineTo(p.dx + r, p.dy - diffY),
    LineTo(p.dx, p.dy + diffY),
    Close(),
  ];
}

enum SymbolType {
  circle,
  square,
  diamond,
  triangle,
  triangleDown,
}

typedef SymbolCreator = List<AbsolutePathCommand> Function(Offset p, double r);

const Symbols = <SymbolType, SymbolCreator>{
  SymbolType.circle: _circle,
  SymbolType.square: _square,
  SymbolType.diamond: _diamond,
  SymbolType.triangle: _triangle,
  SymbolType.triangleDown: _triangleDown,
};

class Marker extends Shape {
  Marker(Cfg cfg) : super(cfg);

  static Map<SymbolType, SymbolCreator> symbols = Symbols;

  @override
  bool get isOnlyHitBBox => true;

  List<AbsolutePathCommand> _getPath() {
    final attrs = this.attrs;
    final x = attrs.x;
    final y = attrs.y;
    final r = attrs.r;
    final symbolType = attrs.symbolType ?? SymbolType.circle;
    final method = Marker.symbols[symbolType];
    
    return method(Offset(x, y), r);
  }

  @override
  void createPath(Path path) {
    final pathCommands = _getPath();
    for (var pathCommand in pathCommands) {
      pathCommand.applyTo(path);
    }
  }

  @override
  Element clone() => Marker(cfg.clone());
}
  