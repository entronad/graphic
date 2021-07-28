import 'dart:ui';

import 'package:flutter/painting.dart';

class StrokeStyle {
  StrokeStyle({
    this.color = const Color(0xff000000),
    this.width = 1,
  });

  final Color color;

  final double width;

  bool operator ==(Object other) =>
    other is StrokeStyle &&
    color == other.color &&
    width == other.width;
}

class LableSyle {
  LableSyle({
    this.style,
    this.offset,
    this.rotation,
  });

  /// Note that default color is white.
  final TextStyle? style;

  final Offset? offset;

  final double? rotation;

  @override
  bool operator ==(Object other) =>
    other is LableSyle &&
    style == other.style &&
    offset == other.offset &&
    rotation == other.rotation;
}
