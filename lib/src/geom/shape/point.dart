import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/circle.dart';
import 'package:graphic/src/engine/render_shape/rect.dart';

import '../base.dart';

List<RenderShape> _circlePoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  bool isHollow,
) {
  final rst = <RenderShape>[];

  for (var record in attrValueRecords) {
    var point = record.position.first;
    final size = record.size;
    final color = record.color;
    
    final paintingStyle = isHollow ? PaintingStyle.stroke : PaintingStyle.fill;
    final strokeWidth = 1.0;
    final r = isHollow ? size - strokeWidth / 2 : size;
    final renderPosition = coord.convertPoint(point);
    final x = renderPosition.dx;
    final y = renderPosition.dy;

    rst.add(CircleRenderShape(
      x: x,
      y: y,
      r: r,
      color: color,
      style: paintingStyle,
      strokeWidth: strokeWidth,
    ));
  }

  return rst;
}

List<RenderShape> _rectPoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  bool isHollow,
) {
  final rst = <RenderShape>[];

  for (var record in attrValueRecords) {
    var point = record.position.first;
    final size = record.size;
    final color = record.color;
    
    final paintingStyle = isHollow ? PaintingStyle.stroke : PaintingStyle.fill;
    final strokeWidth = 1.0;
    var width = size * 2;
    final renderPosition = coord.convertPoint(point);
    var x = renderPosition.dx - size;
    var y = renderPosition.dy - size;
    if (isHollow) {
      width = width - strokeWidth;
      x = x + strokeWidth / 2;
      y = y + strokeWidth / 2;
    }
    final height = width;
    
    rst.add(RectRenderShape(
      x: x,
      y: y,
      width: width,
      height: height,
      color: color,
      style: paintingStyle,
      strokeWidth: strokeWidth,
    ));
  }

  return rst;
}

List<RenderShape> circlePoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _circlePoint(attrValueRecords, coord, false);

List<RenderShape> hollowCirclePoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _circlePoint(attrValueRecords, coord, true);

List<RenderShape> rectPoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _rectPoint(attrValueRecords, coord, false);

List<RenderShape> hollowRectPoint(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _rectPoint(attrValueRecords, coord, true);
