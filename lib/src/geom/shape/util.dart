import 'dart:ui' show Offset;

List<Offset> splitPoints(List<double> x, List<double> y) {
  final points = <Offset>[];
  for (var i = 0; i < y.length; i++) {
    final xValue = x.length > 1 ? x[i] : x.first;
    points.add(Offset(xValue, y[i]));
  }
  return points;
}
