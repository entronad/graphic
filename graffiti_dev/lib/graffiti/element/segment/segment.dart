import 'dart:ui';

import 'cubic.dart';
import 'move.dart';
import 'close.dart';

abstract class SegmentTags {
  static const topLeft = 'topLeft';
  static const top = 'top';
  static const topRight = 'topRight';
  static const right = 'right';
  static const bottomRight = 'bottomRight';
  static const bottom = 'bottom';
  static const bottomLeft = 'bottomLeft';
  static const left = 'left';
}

abstract class Segment {
  Segment({
    this.tag,
  });

  final String? tag;

  void drawPath(Path path);

  Segment lerpFrom(covariant Segment from, double t);

  // toCubic algrithom is from https://github.com/thednp/svg-path-commander 2.0.2
  CubicSegment toCubic(Offset start);

  Segment sow(Offset position);

  Offset getEnd();
}

class SegmentInfo<S extends Segment> {
  SegmentInfo(this.start, this.segment);

  final Offset start;

  final S segment;
}

List<List<Segment>> _spliteContours(List<Segment> segments) {
  final contours = <List<Segment>>[];
  var currentContour = [segments.first];
  for (var i = 1; i < segments.length; i++) {
    final segment = segments[i];
    if (segment is MoveSegment) {
      contours.add(currentContour);
      currentContour = [segment];
    } else {
      currentContour.add(segment);
    }
  }
  contours.add(currentContour);
  return contours;
}

List<List<Segment>> _complementContours(
    List<List<Segment>> shorter, List<List<Segment>> longer) {
  final rst = [...shorter];
  for (var i = 0; i < longer.length - shorter.length; i++) {
    final start = rst.last.last.getEnd();
    rst.add([MoveSegment(end: start)]);
  }
  return rst;
}

// No first move.
List<SegmentInfo> _getContourInfos(List<Segment> contour) {
  final rst = <SegmentInfo>[];
  assert(contour.first is MoveSegment);
  final start = contour.first.getEnd();
  Offset current = start;
  for (var i = 1; i < contour.length; i++) {
    final segment = contour[i];
    rst.add(SegmentInfo(current, segment));
    if (segment is CloseSegment) {
      current = start;
    } else {
      current = segment.getEnd();
    }
  }
  return rst;
}

// assume that every in shorter in needed.
List<SegmentInfo> _complementInfos(
    List<SegmentInfo> shorter, List<SegmentInfo> longer) {
  final rst = <SegmentInfo>[];
  int needCount = longer.length - shorter.length;
  int shorterIndex = 0;
  int longerIndex = 0;
  while (longerIndex < longer.length) {
    if (shorterIndex < shorter.length) {
      // complement in prev.

      final shorterInfo = shorter[shorterIndex];
      final longerInfo = longer[longerIndex];
      if (shorterInfo.segment.tag == longerInfo.segment.tag || needCount == 0) {
        rst.add(shorterInfo);
        shorterIndex++;
        longerIndex++;
      } else {
        rst.add(SegmentInfo(
            shorterInfo.start, longerInfo.segment.sow(shorterInfo.start)));
        longerIndex++;
        needCount--;
      }
    } else {
      // complement in next.

      final shorterEnd = shorter[shorterIndex - 1].segment.getEnd();
      final longerInfo = longer[longerIndex];
      rst.add(SegmentInfo(shorterEnd, longerInfo.segment.sow(shorterEnd)));
      longerIndex++;
      needCount--;
    }
  }
  return rst;
}

List<List<Segment>> nomalizeSegments(List<Segment> from, List<Segment> to) {
  var fromContours = _spliteContours(from);
  var toContours = _spliteContours(to);
  if (fromContours.length < toContours.length) {
    fromContours = _complementContours(fromContours, toContours);
  }
  if (fromContours.length > toContours.length) {
    toContours = _complementContours(toContours, fromContours);
  }
  final fromRst = <Segment>[];
  final toRst = <Segment>[];
  for (var i = 0; i < toContours.length; i++) {
    final fromContour = fromContours[i];
    final toContour = toContours[i];
    fromRst.add(fromContour.first);
    toRst.add(toContour.first);
    var fromInfos = _getContourInfos(fromContour);
    var toInfos = _getContourInfos(toContour);
    if (fromInfos.length < toInfos.length) {
      fromInfos = _complementInfos(fromInfos, toInfos);
    }
    if (fromInfos.length > toInfos.length) {
      toInfos = _complementInfos(toInfos, fromInfos);
    }
    for (var i = 0; i < toInfos.length; i++) {
      final fromInfo = fromInfos[i];
      final toInfo = toInfos[i];
      if (fromInfo.segment.runtimeType == toInfo.segment.runtimeType) {
        fromRst.add(fromInfo.segment);
        toRst.add(toInfo.segment);
      } else if (fromInfo.segment is CloseSegment ||
          toInfo.segment is CloseSegment) {
        fromRst.add(toInfo.segment);
        toRst.add(toInfo.segment);
      } else {
        fromRst.add(fromInfo.segment.toCubic(fromInfo.start));
        toRst.add(toInfo.segment.toCubic(toInfo.start));
      }
    }
  }
  return [fromRst, toRst];
}

// Make sure nomalized.
List<Segment> lerpSegments(List<Segment> from, List<Segment> to, double t) {
  final rst = <Segment>[];
  for (var i = 0; i < to.length; i++) {
    rst.add(to[i].lerpFrom(from[i], t));
  }
  return rst;
}
