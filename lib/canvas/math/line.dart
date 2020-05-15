import 'package:vector_math/vector_math_64.dart' show Vector2;
import 'util.dart' show distance;

double pointToLine(
  double x1,
  double y1,
  double x2,
  double y2,
  double x,
  double y,
) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  if (dx == 0 && dy == 0) {
    return distance(x - x1, y - y1);
  }
  final u = Vector2(-dy, dx);
  u.normalize();
  final a = Vector2(x - x1, y - y1);
  return a.dot(u).abs();
}

double length(double x1, double y1, double x2, double y2) =>
  distance(x1 - x2, y1 - y2);
