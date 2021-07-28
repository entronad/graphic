import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/coord/coord.dart';

import 'function.dart';
import 'util/aes_basic_item.dart';
import 'util/paths.dart';
import 'util/label.dart';

abstract class LineShape extends FunctionShape {
  @override
  double get defaultSize => 2;

  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  ) => throw UnimplementedError('Line only paints group.');
}

class BasicLineShape extends LineShape {
  BasicLineShape({
    this.smooth = false,
    this.loop = false,
  });

  final bool smooth;

  final bool loop;

  @override
  bool equalTo(Object other) =>
    other is BasicLineShape &&
    smooth == other.smooth &&
    loop == other.loop;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
  ) {
    final segments = <List<Offset>>[];
    final labels = <Aes, Offset>{};

    var currentSegment = <Offset>[];
    for (var item in group) {
      if (item.position.first.dy.isFinite) {
        final point = coord.convert(item.position.first);
        currentSegment.add(point);
        labels[item] = point;
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = [];
      }
    }
    if (
      loop &&
      group.first.position.first.dy.isFinite &&
      group.last.position.first.dy.isFinite
    ) {
      // Because line can be broken by NaN, loop cannot use close.
      segments.last.add(segments.first.first);
    }

    final path = Path();
    for (var segment in segments) {
      Paths.polyline(
        points: segment,
        smooth: smooth,
        path: path,
      );
    }

    final represent = group.first;
    aesBasicItem(
      path,
      represent,
      true,
      represent.size ?? defaultSize,
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
