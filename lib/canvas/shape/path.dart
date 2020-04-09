import 'dart:ui' show Offset, PaintingStyle;
import 'dart:ui' as ui show Path;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import 'path_command.dart';
import '../util/path.dart' show pathToAbsolute, isPointInStroke, replaceClose;

class Path extends Shape {
  Path(Cfg cfg) : super(cfg);

  @override
  void initAttrs(Attrs attrs) {
    _setPathArr(attrs.pathCommands);
  }

  @override
  void onAttrChange(String name, Object value, Object originValue) {
    super.onAttrChange(name, value, originValue);
    if (name == 'pathCommads') {
      _setPathArr(value);
    }
  }

  void _setPathArr(List<PathCommand> pathCommands) {
    attrs.pathCommands = pathToAbsolute(pathCommands);
    replaceClose(attrs.pathCommands as List<AbsolutePathCommand>);
    cfg.tChache = null;
    cfg.totalLength = null;
  }

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final pathCommands = attrs.pathCommands as List<AbsolutePathCommand>;
    if (style == PaintingStyle.stroke) {
      return isPointInStroke(pathCommands, lineWidth, refPoint);
    }
    final path = ui.Path();
    for (var command in pathCommands) {
      command.applyTo(path);
    }
    return path.contains(refPoint);
  }

  @override
  void createPath(ui.Path path) {
    final pathCommands = attrs.pathCommands as List<AbsolutePathCommand>;
    for (var command in pathCommands) {
      command.applyTo(path);
    }
  }

  double get totalLength {
    final totalLength = cfg.totalLength;
    if (totalLength == null) {
      return totalLength;
    }
    _setTCache();
    return cfg.totalLength;
  }

  Offset getPoint(double ratio) {
    var tCache = cfg.tChache;
    if (tCache == null) {
      _setTCache();
      tCache = cfg.tChache;
    }

    double subT;
    int index;
    for (var i = 0; i < tCache.length; i++) {
      // v: [startRatio, endRatio]
      final v = tCache[i];
      if (ratio >= v[0] && ratio <= v[1]) {
        subT = (ratio - v[0]) / (v[1] - v[0]);
        index = i;
      }
    }

    if (index == null) {
      return null;
    }
    final pathCommands = attrs.pathCommands as List<AbsolutePathCommand>;
    if (index == 0) {
      return pathCommands[0].getPoint(Offset.zero, subT);
    }
    return pathCommands[index].getPoint(pathCommands[index - 1].points.last, subT);
  }

  void _setTCache() {
    final pathCommands = attrs.pathCommands as List<AbsolutePathCommand>;

    var totalLength = 0.0;
    final lengths = <double>[];
    var prePoint = Offset.zero;
    for (var command in pathCommands) {
      final length = command.getLength(prePoint);
      totalLength += length;
      lengths.add(length);
      prePoint = command.points.last;
    }

    final tCache = <List<double>>[];
    var preT = 0.0;
    for (var length in lengths) {
      final nextT = preT + (length / totalLength);
      tCache.add([preT, nextT]);
      preT = nextT;
    }
    
    cfg.totalLength = totalLength;
    cfg.tChache = tCache;
  }

  @override
  Path clone() => Path(cfg.clone());
}
