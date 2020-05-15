import 'dart:ui' show Offset, PaintingStyle;
import 'dart:ui' as ui show Path;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import 'path_segment.dart';
import '../util/path.dart' show pathToAbsolute, isPointInStroke, replaceClose;

class Path extends Shape {
  Path(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..style = PaintingStyle.stroke;

  @override
  void initAttrs(Attrs attrs) {
    _setPathArr(attrs.segments);
  }

  @override
  void onAttrChange(String name, Object value, Object originValue) {
    super.onAttrChange(name, value, originValue);
    if (name == 'pathCommads') {
      _setPathArr(value);
    }
  }

  void _setPathArr(List<PathSegment> segments) {
    attrs.segments = pathToAbsolute(segments);
    replaceClose(attrs.segments as List<AbsolutePathSegment>);
    cfg.tChache = null;
    cfg.totalLength = null;
  }

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final segments = attrs.segments as List<AbsolutePathSegment>;
    if (style == PaintingStyle.stroke) {
      return isPointInStroke(segments, lineWidth, refPoint);
    }
    final path = ui.Path();
    for (var segment in segments) {
      segment.applyTo(path);
    }
    return path.contains(refPoint);
  }

  @override
  void createPath(ui.Path path) {
    final segments = attrs.segments as List<AbsolutePathSegment>;
    for (var segment in segments) {
      segment.applyTo(path);
    }
  }

  @override
  double get totalLength {
    final totalLength = cfg.totalLength;
    if (totalLength == null) {
      return totalLength;
    }
    _setTCache();
    return cfg.totalLength;
  }

  @override
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
    final segments = attrs.segments as List<AbsolutePathSegment>;
    if (index == 0) {
      return segments[0].getPoint(Offset.zero, subT);
    }
    return segments[index].getPoint(segments[index - 1].points.last, subT);
  }

  void _setTCache() {
    final segments = attrs.segments as List<AbsolutePathSegment>;

    var totalLength = 0.0;
    final lengths = <double>[];
    var prePoint = Offset.zero;
    for (var segment in segments) {
      final length = segment.getLength(prePoint);
      totalLength += length;
      lengths.add(length);
      prePoint = segment.points.last;
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
