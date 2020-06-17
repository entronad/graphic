import 'dart:ui';

import 'base.dart';

class PositionAttr extends Attr<double> {
  PositionAttr(AttrCfg<double> cfg) : super(cfg);

  @override
  AttrCfg<double> get defaultCfg => super.defaultCfg
    ..names = ['x', 'y']
    ..type = AttrType.position;

  @override
  List mapping(List params) {
    if (params?.length != null && params.length < 2) {
      return [];
    }
    var x = params[0];
    var y = params[1];
    final scales = cfg.scales;
    final coord = cfg.coord;
    final scaleX = scales[0];
    final scaleY = scales[1];
    var rstX;
    var rstY;
    Offset obj;
    if (y is List && x is List) {
      rstX = [];
      rstY = [];
      for (var i = 0, j = 0, xLen = x.length, yLen = y.length; i < xLen && j < yLen; i++, j++) {
        obj = coord.convertPoint(Offset(
          scaleX.scale(x[i]),
          scaleY.scale(y[j]),
        ));
        rstX.add(obj.dx);
        rstY.add(obj.dy);
      }
    } else if (y is List) {
      x = scaleX.scale(x);
      rstY = [];
      y.forEach((yVal) {
        yVal = scaleY.scale(yVal);
        obj = coord.convertPoint(Offset(
          x,
          yVal,
        ));
        if (rstX != null && rstX != obj.dx) {
          if (!(rstX is List)) {
            rstX = [rstX];
          }
          rstX.add(obj.dx);
        } else {
          rstX = obj.dx;
        }
        rstY.add(obj.dy);
      });
    } else if (x is List) {
      y = scaleY.scale(y);
      rstX = [];
      x.forEach((xVal) {
        xVal = scaleX.scale(xVal);
        obj = coord.convertPoint(Offset(
          xVal,
          y,
        ));
        if (rstY != null && rstY != obj.dy) {
          if (!(rstY is List)) {
            rstY = [rstY];
          }
          rstY.add(obj.dy);
        } else {
          rstY = obj.dy;
        }
        rstX.add(obj.dx);
      });
    } else {
      x = scaleX.scale(x);
      y = scaleY.scale(y);
      final point = coord.convertPoint(Offset(
        x,
        y,
      ));
      rstX = point.dx;
      rstY = point.dy;
    }
    return [rstX, rstY];
  }

  @override
  double lerp(double a, double b, double t) =>
    (b - a) * t + a;
}
