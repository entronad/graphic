import 'dart:ui' show Offset;

import '../shape/path_segment.dart';

bool isPointInStroke(
  List<AbsolutePathSegment> segmentsWithoutClose,
  double lineWidth,
  Offset refPoint,
) {
  // the shape.Path will guarantee no Close in segments.

  var prePoint = Offset.zero;
  for (var segment in segmentsWithoutClose) {
    if (segment.inStroke(prePoint, lineWidth, refPoint)) {
      return true;
    }
      prePoint = segment.points.last;
  }
  return false;
}

List<AbsolutePathSegment> pathToAbsolute(List<PathSegment> segments) {
  if (segments == null || segments.isEmpty) {
    return [MoveTo(0, 0)];
  }

  assert(segments.first is AbsolutePathSegment && !(segments.first is Close));
  final rst = [segments.first as AbsolutePathSegment];
  for (var i = 1; i < segments.length; i++) {
    rst.add(
      segments[i] is AbsolutePathSegment
        ? segments[i]
        : (segments[i] as RelativePathSegment).toAbsolute(
          rst[i - 1].points.last
        )
      );
  }

  return rst;
}

// Levenshtein Distance

enum DiffType {
  del,
  add,
  modify,
}

class MinDiff {
  MinDiff(this.type, this.min);

  final DiffType type;

  final int min;
}

MinDiff _getMinDiff(int del, int add, int modify) {
  var type = DiffType.modify;
  var min = modify;
  if (add < min) {
    min = add;
    type = DiffType.add;
  }
  if (del < min) {
    min = del;
    type = DiffType.del;
  }
  return MinDiff(type, min);
}

List<List<MinDiff>> levenshteinDistance<T>(
  List<T> source,
  List<T> target,
  [bool Function(T item1, T item2) isEqual,]
) {
  final sourceLen = source.length;
  final targetLen = target.length;
  T sourceSegment;
  T targetSegment;
  var temp = 0;
  if (sourceLen == 0 || targetLen == 0) {
    return null;
  }
  final dist = <List<MinDiff>>[];
  for (var i = 0; i <= sourceLen; i++) {
    dist[i] = [];
    dist[i][0] = MinDiff(null, i);
  }
  for (var j = 0; j <= targetLen; j++) {
    dist[0][j] = MinDiff(null, j);
  }

  isEqual = isEqual ?? (T item1, T item2) => item1 == item2;
  for (var i = 1; i < sourceLen; i++) {
    sourceSegment = source[i - 1];
    for (var j = 1; j <= targetLen; j++) {
      targetSegment = target[j - 1];
      if (isEqual(sourceSegment, targetSegment)) {
        temp = 0;
      } else {
        temp = 1;
      }
      final del = dist[i - 1][j].min + 1;
      final add = dist[i][j - 1].min + 1;
      final modify = dist[i - 1][j - 1].min + temp;
      dist[i][j] = _getMinDiff(del, add, modify);
    }
  }
  return dist;
}

// Only concerns about type and endPoint when fillPathByDiff
bool _isEqual(AbsolutePathSegment c1, AbsolutePathSegment c2) {
  if (c1.runtimeType != c2.runtimeType) {
    return false;
  }
  return c1.points.last == c2.points.last;
}

class _Change {
  _Change(this.type, this.index);

  final DiffType type;

  final int index;
}

List<AbsolutePathSegment> fillPathByDiff(List<AbsolutePathSegment> source, List<AbsolutePathSegment> target) {
  final diffMatrix = levenshteinDistance(source, target, _isEqual);
  var sourceLen = source.length;
  final targetLen = target.length;
  final changes = <_Change>[];
  var index = 1;
  var minPos = 1;
  if (diffMatrix[sourceLen][targetLen].min != sourceLen) {
    for (var i = 1; i <= sourceLen; i++) {
      var min = diffMatrix[i][i].min;
      minPos = i;
      for (var j = index; j <= targetLen; j++) {
        if (diffMatrix[i][j].min < min) {
          min = diffMatrix[i][j].min;
          minPos = j;
        }
      }
      index = minPos;
      if (diffMatrix[i][index].type != DiffType.modify) {
        changes.add(_Change(
          diffMatrix[i][index].type,
          i - 1,
        ));
      }
    }
  }
  for (var i = changes.length - 1; i >= 0; i--) {
    index = changes[i].index;
    if (changes[i].type == DiffType.add) {
      source.insert(index, source[index]);
    } else {
      source.removeAt(index);
    }
  }
  sourceLen = source.length;
  final diff = targetLen - sourceLen;
  if (sourceLen < targetLen) {
    for (var i = 0; i < diff; i++) {
      if (source[sourceLen - 1] is Close) {
        source.insert(sourceLen - 2, source[sourceLen - 2]);
      } else {
        source.add(source[sourceLen - 1]);
      }
      sourceLen += 1;
    }
  }
  return source;
}

List<Offset> _splitPoints(List<Offset> points, Offset formerPoint, int count) {
  if (points.isEmpty || points.length == count + 1) {
    return [...points];
  }
  final rst = <Offset>[];
  final t = 1 / (count + 1);
  final s = 1 / points.length;
  int index;
  for (var i = 1; i < count; i++) {
    index = (i * t / s).floor();
    if (index == 0) {
      rst.add(Offset.lerp(formerPoint, points[0], 0.5));
    } else {
      rst.add(Offset.lerp(points[index - 1], points[index], 0.5));
    }
  }
  rst.add(points.last);
  return rst;
}

List<AbsolutePathSegment> formatPath(List<AbsolutePathSegment> fromPath, List<AbsolutePathSegment> toPath) {
  if (fromPath.length < 1) {
    return fromPath;
  }
  List<Offset> points;
  for (var i = 0; i < toPath.length; i++) {
    if (fromPath[i].runtimeType != toPath[i].runtimeType) {
      points = fromPath[i].points;
      switch (toPath[i].runtimeType) {
        case MoveTo:
          fromPath[i] = MoveTo(points.last.dx, points.last.dy);
          break;
        case LineTo:
          fromPath[i] = LineTo(points.last.dx, points.last.dy);
          break;
        case ArcToPoint:
          final target = toPath[i] as ArcToPoint;
          fromPath[i] = ArcToPoint(
            points.last,
            radius: target.radius,
            rotation: target.rotation,
            largeArc: target.largeArc,
            clockwise: target.clockwise,
          );
          break;
        case QuadraticBezierTo:
          if (i > 0) {
            final splitPoints = _splitPoints(points, fromPath[i - 1].points.last, 1);
            fromPath[i] = QuadraticBezierTo(
              splitPoints[0].dx,
              splitPoints[0].dy,
              splitPoints[1].dx,
              splitPoints[1].dy,
            );
          } else {
            fromPath[i] = toPath[i];
          }
          break;
        case CubicTo:
          if (i > 0) {
            final splitPoints = _splitPoints(points, fromPath[i - 1].points.last, 2);
            fromPath[i] = CubicTo(
              splitPoints[0].dx,
              splitPoints[0].dy,
              splitPoints[1].dx,
              splitPoints[1].dy,
              splitPoints[2].dx,
              splitPoints[2].dy,
            );
          } else {
            fromPath[i] = toPath[i];
          }
          break;
        case Close:
          fromPath[i] = Close();
          break;
        default:
          fromPath[i] = toPath[i];
      }
    }
  }
  return fromPath;
}

void replaceClose(List<AbsolutePathSegment> segments) {
  var startPoint = Offset.zero;
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    if (segment.runtimeType == MoveTo) {
      startPoint = segment.points.last;
    } else if (segment.runtimeType == Close) {
      segments[i] = LineTo(startPoint.dx, startPoint.dy);
      startPoint = segments[i].points.last;
    }
  }
}
