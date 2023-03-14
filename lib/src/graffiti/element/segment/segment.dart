import 'dart:ui';

import 'cubic.dart';
import 'move.dart';
import 'close.dart';
import '../path.dart';
import '../element.dart';

/// Built-in segment tags.
///
/// Built-in elements use these tags to optimize morphing.
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

/// Path segments of [PathElement]s.
abstract class Segment {
  /// Creates a segment.
  Segment({
    this.tag,
  });

  /// The tag to indicate correspondence of this segment in animation.
  ///
  /// The order and connecting relations of items in a segment list is important,
  /// which is different to [MarkElement] list. So to make a best morphing, two
  /// path segments should:
  /// - Tags should be unique.
  /// - The shorter's tags are subset of the longer's.
  /// - The shorter's tags' order are same with they are in longer's.
  final String? tag;

  /// Draws this segment on a path.
  void drawPath(Path path);

  /// Linearly interpolate between this segment and [from].
  Segment lerpFrom(covariant Segment from, double t);

  /// Converts this segment to a [CubicSegment].
  ///
  /// This method is used for morphing.
  ///
  /// The algrithoms are from https://github.com/thednp/svg-path-commander 2.0.2
  CubicSegment toCubic(Offset start);

  /// Shrinks this segment to a point in [position].
  Segment sow(Offset position);

  /// Gets the end point of this segment.
  Offset getEnd();

  @override
  bool operator ==(Object other) => other is Segment && tag == other.tag;
}

/// A [segment] and its [start]ing point.
///
/// This is used for [Segment.toCubic] in morphing.
class SegmentInfo<S extends Segment> {
  /// Creates a segment info.
  SegmentInfo(this.start, this.segment);

  /// Starting point of the segment.
  final Offset start;

  /// The segment.
  final S segment;
}

/// Splites a path segments into contours.
///
/// A contour is a continuous path that starts with a [MoveSegment] but dosen't
/// include other [MoveSegment]s in the middle.
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

/// Complements the [shorter]’s contours count to the [longer].
///
/// The complementing contours are at the end with a single [MoveSegment].
List<List<Segment>> _complementContours(
    List<List<Segment>> shorter, List<List<Segment>> longer) {
  final rst = [...shorter];
  for (var i = 0; i < longer.length - shorter.length; i++) {
    final start = rst.last.last.getEnd();
    rst.add([MoveSegment(end: start)]);
  }
  return rst;
}

/// Converts contour segment list to [SegmentInfo] list.
List<SegmentInfo> _getContourInfos(List<Segment> contour) {
  final rst = <SegmentInfo>[];
  assert(contour.first is MoveSegment);
  // The first MoveSegment will not be an item.
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

/// Complements [SegmentInfo]s of [shorter] contour to [longer].
///
/// The complemention is mainly according to tags.
///
/// Every item in [shorter] will be kept.
List<SegmentInfo> _complementInfos(
    List<SegmentInfo> shorter, List<SegmentInfo> longer) {
  final rst = <SegmentInfo>[];
  int needCount = longer.length - shorter.length;
  int shorterIndex = 0;
  int longerIndex = 0;
  while (longerIndex < longer.length) {
    if (shorterIndex < shorter.length) {
      // When there are still items in shorter, sows before the not-matching candidate.

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
      // When shorter is used up, sows after the shorter.

      final shorterEnd = shorter[shorterIndex - 1].segment.getEnd();
      final longerInfo = longer[longerIndex];
      rst.add(SegmentInfo(shorterEnd, longerInfo.segment.sow(shorterEnd)));
      longerIndex++;
      needCount--;
    }
  }
  return rst;
}

/// Normalizes two path segments into same length and same corresponding segment types.
///
/// Returns a pair of two path results: \[fromRst, toRst\].
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

/// Linearly interpolate between two path segments.
///
/// Make sure the two path segments are nomalized.
List<Segment> lerpSegments(List<Segment> from, List<Segment> to, double t) {
  final rst = <Segment>[];
  for (var i = 0; i < to.length; i++) {
    rst.add(to[i].lerpFrom(from[i], t));
  }
  return rst;
}
