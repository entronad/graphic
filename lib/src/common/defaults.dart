import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/interaction/gesture.dart';

/// Gets signal update for different dimensions.
SignalUpdate<List<double>> _getRangeUpdate(
        double Function(ScaleUpdateDetails) getDeltaDim,
        double Function(ScaleUpdateDetails) getScaleDim,
        double Function(Size) getSizeDim) =>
    (
      List<double> init,
      List<double> pre,
      Signal signal,
    ) {
      signal as GestureSignal;
      final gesture = signal.gesture;

      if (gesture.type == GestureType.scaleUpdate) {
        final detail = gesture.details as ScaleUpdateDetails;

        if (detail.pointerCount == 1) {
          // Panning.

          // ScaleUpdateDetails.delta is from moveStart, not from previous one.
          final prePan = getDeltaDim(gesture.preScaleDetail!);
          final pan = getDeltaDim(detail);
          final deltaRatio = pan - prePan;
          final delta = deltaRatio / getSizeDim(gesture.chartSize);
          return [pre.first + delta, pre.last + delta];
        } else {
          // Scaling.

          final preScale = getScaleDim(gesture.preScaleDetail!);
          final scale = getScaleDim(detail);
          final deltaRatio = (scale - preScale) / preScale / 2;
          final preRange = pre.last - pre.first;
          final delta = deltaRatio * preRange;
          return [pre.first - delta, pre.last + delta];
        }
      } else if (gesture.type == GestureType.scroll) {
        final step = 0.1;
        final scrollDelta = gesture.details as Offset;
        final deltaRatio = scrollDelta.dy == 0
            ? 0.0
            : scrollDelta.dy > 0
                ? (step / 2)
                : (-step / 2);
        final preRange = pre.last - pre.first;
        final delta = deltaRatio * preRange;
        return [pre.first - delta, pre.last + delta];
      } else if (gesture.type == GestureType.doubleTap) {
        return init;
      }
      return pre;
    };

/// Some useful default values for specifications.
abstract class Defaults {
  /// A single primary color.
  static Color primaryColor = Color(0xff1890ff);

  /// A color for auxiliary lines.
  static Color strokeColor = Color(0xffe8e8e8);

  /// A color for text.
  static Color textColor = Color(0xff808080);

  /// A color palette of 10 colors.
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

  /// A color palette of 20 colors.
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

  /// A stroke style for auxiliary lines.
  static StrokeStyle get strokeStyle => StrokeStyle(
        color: strokeColor,
      );

  /// A text style for labels.
  static TextStyle get textStyle => TextStyle(
        fontSize: 10,
        color: textColor,
      );

  /// A text style for labels curved in colored surfaces.
  static TextStyle get runeStyle => TextStyle(
        fontSize: 10,
        color: Color(0xe6ffffff),
      );

  /// A specification for horizontal axis.
  static AxisGuide get horizontalAxis => AxisGuide(
        line: strokeStyle,
        label: LabelStyle(
          textStyle,
          offset: Offset(0, 7.5),
        ),
      );

  /// A specification for vertical axis.
  static AxisGuide get verticalAxis => AxisGuide(
        label: LabelStyle(
          textStyle,
          offset: Offset(-7.5, 0),
        ),
        grid: strokeStyle,
      );

  /// A specification for radial axis.
  static AxisGuide get radialAxis => AxisGuide(
        line: strokeStyle,
        label: LabelStyle(textStyle),
        grid: strokeStyle,
      );

  /// A specification for circular axis.
  static AxisGuide get circularAxis => AxisGuide(
        position: 1,
        line: strokeStyle,
        label: LabelStyle(textStyle),
        grid: strokeStyle,
      );

  /// A signal update for scaling and panning horizontal coordinate range.
  static SignalUpdate<List<double>> get horizontalRangeSignal =>
      _getRangeUpdate(
        (detail) => detail.delta.dx,
        (detail) => detail.horizontalScale,
        (size) => size.width,
      );

  /// A signal update for scaling and panning vertical coordinate range.
  static SignalUpdate<List<double>> get verticalRangeSignal => _getRangeUpdate(
        (detail) => -detail.delta.dy,
        (detail) => detail.verticalScale,
        (size) => size.height,
      );
}
