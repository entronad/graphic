import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/interaction/gesture.dart';

/// Gets signal update for different dimensions.
SignalUpdater<List<double>> _getRangeUpdate(
        bool isHorizontal, bool focusMouseScale) =>
    (
      List<double> init,
      List<double> pre,
      Signal signal,
    ) {
      if (signal is GestureSignal) {
        final gesture = signal.gesture;

        if (gesture.type == GestureType.scaleUpdate) {
          final detail = gesture.details as ScaleUpdateDetails;

          if (detail.pointerCount == 1) {
            // Panning.

            final deltaRatio = isHorizontal
                ? gesture.preScaleDetail!.focalPointDelta.dx
                : -gesture.preScaleDetail!.focalPointDelta.dy;
            final delta = deltaRatio /
                (isHorizontal
                    ? gesture.chartSize.width
                    : gesture.chartSize.height);
            return [pre.first + delta, pre.last + delta];
          } else {
            // Scaling.

            double Function(ScaleUpdateDetails) getScaleDim =
                (p0) => isHorizontal ? p0.horizontalScale : p0.verticalScale;
            final preScale = getScaleDim(gesture.preScaleDetail!);
            final scale = getScaleDim(detail);
            final deltaRatio = (scale - preScale) / preScale / 2;
            final preRange = pre.last - pre.first;
            final delta = deltaRatio * preRange;
            return [pre.first - delta, pre.last + delta];
          }
        } else if (gesture.type == GestureType.scroll) {
          const step = -0.1;
          final scrollDelta = gesture.details as Offset;
          final deltaRatio = scrollDelta.dy == 0
              ? 0.0
              : scrollDelta.dy > 0
                  ? (step / 2)
                  : (-step / 2);
          final preRange = pre.last - pre.first;
          final delta = deltaRatio * preRange;
          if (!focusMouseScale) {
            return [pre.first - delta, pre.last + delta];
          } else {
            double mousePos;
            if (isHorizontal) {
              mousePos = gesture.localPosition.dx / 752 - 0.052527;
            } else {
              mousePos = 1 - (gesture.localPosition.dy / 780 - 0.006410);
            }
            mousePos = (mousePos - pre.first) / (pre.last - pre.first);
            return [
              pre.first - delta * 2 * mousePos,
              pre.last + delta * 2 * (1 - mousePos)
            ];
          }
        } else if (gesture.type == GestureType.doubleTap) {
          return init;
        }
      }

      return pre;
    };

/// Some useful default values for specifications.
abstract class Defaults {
  /// A single primary color.
  static Color primaryColor = const Color(0xff1890ff);

  /// A color for auxiliary lines.
  static Color strokeColor = const Color(0xffe8e8e8);

  /// A color for text.
  static Color textColor = const Color(0xff808080);

  /// A color palette of 10 colors.
  static List<Color> get colors10 => [
        const Color(0xff5b8ff9),
        const Color(0xff5ad8a6),
        const Color(0xff5d7092),
        const Color(0xfff6bd16),
        const Color(0xff6f5ef9),
        const Color(0xff6dc8ec),
        const Color(0xff945fb9),
        const Color(0xffff9845),
        const Color(0xff1e9493),
        const Color(0xffff99c3),
      ];

  /// A color palette of 20 colors.
  static List<Color> get colors20 => [
        const Color(0xff5b8ff9),
        const Color(0xffcdddfd),
        const Color(0xff5ad8a6),
        const Color(0xffcdf3e4),
        const Color(0xff5d7092),
        const Color(0xffced4de),
        const Color(0xfff6bd16),
        const Color(0xfffcebb9),
        const Color(0xff6f5ef9),
        const Color(0xffd3cefd),
        const Color(0xff6dc8ec),
        const Color(0xffd3eef9),
        const Color(0xff945fb9),
        const Color(0xffdecfea),
        const Color(0xffff9845),
        const Color(0xffffe0c7),
        const Color(0xff1e9493),
        const Color(0xffbbdede),
        const Color(0xffff99c3),
        const Color(0xffffe0ed),
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
  static TextStyle get runeStyle => const TextStyle(
        fontSize: 10,
        color: Color(0xe6ffffff),
      );

  /// A specification for horizontal axis.
  static AxisGuide get horizontalAxis => AxisGuide(
        line: strokeStyle,
        label: LabelStyle(
          style: textStyle,
          offset: const Offset(0, 7.5),
        ),
      );

  /// A specification for vertical axis.
  static AxisGuide get verticalAxis => AxisGuide(
        label: LabelStyle(
          style: textStyle,
          offset: const Offset(-7.5, 0),
        ),
        grid: strokeStyle,
      );

  /// A specification for radial axis.
  static AxisGuide get radialAxis => AxisGuide(
        line: strokeStyle,
        label: LabelStyle(style: textStyle),
        grid: strokeStyle,
      );

  /// A specification for circular axis.
  static AxisGuide get circularAxis => AxisGuide(
        position: 1,
        line: strokeStyle,
        label: LabelStyle(style: textStyle),
        grid: strokeStyle,
      );

  /// A signal update for scaling and panning horizontal coordinate range.
  static SignalUpdater<List<double>> get horizontalRangeSignal =>
      _getRangeUpdate(true, false);

  /// A signal update for scaling and panning vertical coordinate range.
  static SignalUpdater<List<double>> get verticalRangeSignal =>
      _getRangeUpdate(false, false);

  /// A signal update for scaling and panning horizontal coordinate range by cursor focus.
  static SignalUpdater<List<double>> get horizontalRangeFocusSignal =>
      _getRangeUpdate(true, true);

  /// A signal update for scaling and panning vertical coordinate range by cursor focus.
  static SignalUpdater<List<double>> get verticalRangeFocusSignal =>
      _getRangeUpdate(false, true);
}
