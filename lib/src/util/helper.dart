import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/shape.dart';
import 'package:graphic/src/engine/shape/sector.dart';
import 'package:graphic/src/engine/shape/rect.dart';
import 'package:graphic/src/coord/base.dart';


Shape getClip(Coord coord) {
  final start = coord.cfg.start;
  final end = coord.cfg.end;
  final width = end.dx - start.dx;
  final height = (end.dy - start.dy).abs();
  final margin = 10.0;
  Shape clip;
  if (coord.cfg.isPolar) {
    final circleRadius = coord.cfg.circleRadius;
    final center = coord.cfg.center;
    final startAngle = coord.cfg.startAngle;
    final endAngle = coord.cfg.endAngle;
    clip = Sector(Cfg(
      attrs: Attrs(
        x: center.dx,
        y: center.dy,
        r: circleRadius,
        r0: 0,
        startAngle: startAngle,
        endAngle: endAngle,
      ),
    ));
  } else {
    clip = Rect(Cfg(
      attrs: Attrs(
        x: start.dx,
        y: end.dy - margin,
        width: width,
        height: height + 2 * margin,
      ),
    ));
  }
  clip.cfg.isClip = true;
  return clip;
}
