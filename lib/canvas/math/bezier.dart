import 'dart:ui' show Offset;

import 'util.dart' show distance;

const epsilon = 0.0001;

Offset nearestPoint(
  List<double> xArr,
  List<double> yArr,
  double x,
  double y,
  double Function(List<double>) tCallback,  // param arry: [p1, p2, ... t]
) {
  double t;
  var interval = 0.005;
  var d = double.infinity;
  final v0 = [x, y];

  for (var i = 0; i <= 20; i++) {
    final _t = i * 0.05;
    final v1 = [tCallback([...xArr, _t]), tCallback([...yArr, _t])];

    final d1 = distance(v1[0] - v0[0], v1[1] - v0[1]);
    if (d1 < d) {
      t = _t;
      d = d1;
    }
  }
  if (t == 0) {
    return Offset(xArr[0], yArr[0]);
  }
  if (t == 1) {
    final count = xArr.length;
    return Offset(xArr[count - 1], yArr[count - 1]);
  }
  d = double.infinity;

  for (var i = 0; i < 32; i++) {
    if (interval < epsilon) {
      break;
    }

    final prev = t - interval;
    final next = t + interval;

    final v1 = [tCallback([...xArr, prev]), tCallback([...yArr, prev])];

    final d1 = distance(v1[0] - v0[0], v1[1] - v0[1]);
    if (prev >= 0 && d1 < d) {
      t = prev;
      d = d1;
    } else {
      final v2 = [tCallback([...xArr, next]), tCallback([...yArr, next])];
      final d2 = distance(v2[0] - v0[0], v2[1] - v0[1]);
      if (next <= 1 && d2 < d) {
        t = next;
        d = d2;
      } else {
        interval *= 0.5;
      }
    }
  }

  return Offset(
    tCallback([...xArr, t]),
    tCallback([...yArr, t]),
  );
}

double snapLength(List<double> xArr, List<double> yArr) {
  var totalLength = 0.0;
  final count = xArr.length;
  for (var i = 0; i < count; i++) {
    final x = xArr[i];
    final y = yArr[i];
    final nextX = xArr[(i + 1) % count];
    final nextY = yArr[(i + 1) % count];
    totalLength += distance(nextX - x, nextY - y);
  }
  return totalLength / 2;
}
