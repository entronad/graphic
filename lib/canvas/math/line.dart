import 'util.dart' show distance;

double pointToLine(
  double x1,
  double y1,
  double x2,
  double y2,
  double x,
  double y,
) {
  final dx = x1 - x2;
  final dy = y1 - y2;
  if (dx == 0 && dy == 0) {
    return distance(x - x1, y - y1);
  }
  return (dy * x - dx * y + x2 * y1 - y2 * x1).abs() / distance(dx, dy);
}

double length(double x1, double y1, double x2, double y2) =>
  distance(x1 - x2, y1 - y2);
