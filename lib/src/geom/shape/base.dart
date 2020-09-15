import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';

import '../base.dart';
import 'area.dart' as _area;
import 'interval.dart' as _interval;
import 'line.dart' as _line;
import 'point.dart' as _point;
import 'polygon.dart' as _polygon;
import 'schema.dart' as _schema;

typedef Shape = List<RenderShape> Function(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Offset origin,
);

class Shapes {
  static const area = _area.area;
  static const smoothArea = _area.smoothArea;

  static const rectInterval = _interval.rectInterval;
  static const rrectInterval = _interval.rrectInterval;
  static const pyramidInterval = _interval.pyramidInterval;
  static const funnelInterval = _interval.funnelInterval;

  static const line = _line.line;
  static const smoothLine = _line.smoothLine;

  static const circlePoint = _point.circlePoint;
  static const hollowCirclePoint = _point.hollowCirclePoint;
  static const rectPoint = _point.rectPoint;
  static const hollowRectPoint = _point.hollowRectPoint;

  static const mosaicPolygon = _polygon.mosaicPolygon;

  static const candlestickSchema = _schema.candlestickSchema;
  static const boxSchema = _schema.boxSchema;
}
