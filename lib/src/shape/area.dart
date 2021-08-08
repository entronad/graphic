import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';

import 'function.dart';
import 'util/smooth.dart' as smooth_util;
import 'util/aes_basic_item.dart';

abstract class AreaShape extends FunctionShape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Area needs no size.');

  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  ) => throw UnimplementedError('Area only paints group.');
}

class BasicAreaShape extends AreaShape {
  BasicAreaShape({
    this.smooth = false,
    this.loop = false,
  });

  final bool smooth;

  final bool loop;

  @override
  bool equalTo(Object other) =>
    other is BasicAreaShape &&
    smooth == other.smooth &&
    loop == other.loop;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
  ) {
    assert(!(coord is PolarCoordConv && coord.transposed));
    
    final segments = <List<List<Offset>>>[];
    final labels = <Aes, Offset>{};

    var currentSegment = <List<Offset>>[];
    for (var item in group) {
      final position = item.position;
      if (position[0].dy.isFinite && position[1].dy.isFinite) {
        final start = coord.convert(position[0]);
        final end = coord.convert(position[1]);
        currentSegment.add([start, end]);
        labels[item] = end;
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }
    if (
      loop &&
      group.first.position[0].dy.isFinite &&
      group.first.position[1].dy.isFinite &&
      group.last.position[0].dy.isFinite &&
      group.last.position[1].dy.isFinite
    ) {
      // Because line can be broken by NaN, loop cannot use close.
      segments.last.add(segments.first.first);
    }

    final path = Path();
    for (var segment in segments) {
      final starts = <Offset>[];
      final ends = <Offset>[];
      for (var points in segment) {
        starts.add(points[0]);
        ends.add(points[1]);
      }

      // Because area is a single closed subpath, cannot use polyline.
      path.moveTo(ends.first.dx, ends.first.dy);
      if (smooth) {
        final segments = smooth_util.smooth(
          ends,
          false,
          true,
        );
        for (var s in segments) {
          path.cubicTo(
            s.cp1.dx,
            s.cp1.dy,
            s.cp2.dx,
            s.cp2.dy,
            s.p.dx,
            s.p.dy
          );
        }
      } else {
        for (var point in ends) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.lineTo(starts.last.dx, starts.last.dy);
      final reversedStarts = starts.reversed.toList();
      if (smooth) {
        final segments = smooth_util.smooth(
          reversedStarts,
          false,
          true,
        );
        for (var s in segments) {
          path.cubicTo(
            s.cp1.dx,
            s.cp1.dy,
            s.cp2.dx,
            s.cp2.dy,
            s.p.dx,
            s.p.dy
          );
        }
      } else {
        for (var point in reversedStarts) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
    }

    final represent = group.first;
    aesBasicItem(
      path,
      represent,
      false,
      0,
      canvas,
    );

    for (var item in labels.keys) {
      if (item.label != null) {
        paintLabel(
          item.label!,
          labels[item]!,
          coord.transposed ? Alignment.centerLeft : Alignment.bottomCenter,
          canvas,
        );
      }
    }
  }
}
