import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/interaction/gesture/gesture.dart';
import 'package:graphic/src/interaction/signal.dart';

/// The scale and rotation is calculated from the initial.
/// The state-transform scale should be calculated by pointEvent.
SignalUpdate<List<double>, Event> _getRangeUpdate(
  double Function(Offset) getOffsetDim,
  double Function(Size) getSizeDim
) => (
  List<double> init,
  List<double> pre,
  Event event,
) {
  event as GestureEvent;
  final gesture = event.gesture;

  if (gesture.type == GestureType.scaleUpdate) {
    final currentDistance = getOffsetDim(
      gesture.pointerEvent.position - gesture.scale!.focalPoint
    ).abs();
    final preDistance = getOffsetDim(
      gesture.pointerEvent.position - gesture.pointerEvent.delta - gesture.scale!.focalPoint
    ).abs();
    final deltaRatio = (currentDistance - preDistance) / preDistance / 2;
    
    final preRange = pre.last - pre.first;
    final delta = deltaRatio * preRange;

    return [pre.first - delta, pre.last + delta];
  } else if (gesture.type == GestureType.panUpdate) {
    final pan = getOffsetDim(gesture.pointerEvent.delta);

    final preRange = pre.last - pre.first;
    final delta = (pan / getSizeDim(gesture.arenaSize)) * preRange;
    return [pre.first + delta, pre.last + delta];
  } else if (gesture.type == GestureType.doubleTap) {
    return init;
  }
  return pre;
};

abstract class Defaults {
  static List<Color> get colors10 => [
    Color(0xff5b8ff9),
    Color(0xff5ad8a6),
    Color(0xff5d7092),
    Color(0xfff6bd16),
    Color(0xff6f5ef9),
    Color(0xff6dc8ec),
    Color(0xff945fb9),
    Color(0xffff9845),
    Color(0xff1e9493),
    Color(0xffff99c3),
  ];

  static List<Color> get colors20 => [
    Color(0xff5b8ff9),
    Color(0xffcdddfd),
    Color(0xff5ad8a6),
    Color(0xffcdf3e4),
    Color(0xff5d7092),
    Color(0xffced4de),
    Color(0xfff6bd16),
    Color(0xfffcebb9),
    Color(0xff6f5ef9),
    Color(0xffd3cefd),
    Color(0xff6dc8ec),
    Color(0xffd3eef9),
    Color(0xff945fb9),
    Color(0xffdecfea),
    Color(0xffff9845),
    Color(0xffffe0c7),
    Color(0xff1e9493),
    Color(0xffbbdede),
    Color(0xffff99c3),
    Color(0xffffe0ed),
  ];

  static StrokeStyle get strokeStyle => StrokeStyle(
    color: Color(0xffe8e8e8),
  );

  static TextStyle get textStyle => TextStyle(
    fontSize: 10,
    color: Color(0xff808080),
  );

  static AxisGuide get horizontalAxis => AxisGuide(
    line: strokeStyle,
    label: LabelSyle(
      offset: Offset(0, 7.5),
      style: textStyle,
    ),
  );

  static AxisGuide get verticalAxis => AxisGuide(
    label: LabelSyle(
      offset: Offset(-7.5, 0),
      style: textStyle,
    ),
    grid: strokeStyle,
  );

  static AxisGuide get radialAxis => AxisGuide(
    line: strokeStyle,
    label: LabelSyle(
      style: textStyle,
    ),
    grid: strokeStyle,
  );

  static AxisGuide get circularAxis => AxisGuide(
    position: 1,
    line: strokeStyle,
    label: LabelSyle(
      style: textStyle,
    ),
    grid: strokeStyle,
  );

  static Signal<List<double>> get horizontalRangeSignal => {
    EventType.gesture: _getRangeUpdate(
      (offset) => offset.dx,
      (size) => size.width,
    ),
  };

  static Signal<List<double>> get verticalRangeSignal => {
    EventType.gesture: _getRangeUpdate(
      (offset) => -offset.dy,
      (size) => size.height,
    ),
  };
}
