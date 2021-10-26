import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

import 'view.dart';

/// A widget to display the chart.
/// 
/// All specification properties are declared in the constructor and then collected
/// by a [spec] property to build the chart. See details in [Spec] class.
/// 
/// Usually, if any specification or data is changed, the chart will rebuild or
/// reevaluate automatically. Some subtle setting is controlled by [rebuild] and
/// [Spec.changeData].
/// 
/// The generic [D] is the type of datum in [Spec.data] list.
/// 
/// See also:
/// 
/// - [Spec], to see the specification property details.
class Chart<D> extends StatefulWidget {
  /// Creates a chart widget.
  Chart({
    required List<D> data,
    bool? changeData,
    required Map<String, Variable<D, dynamic>> variables,
    List<VariableTransform>? transforms,
    required List<GeomElement> elements,
    Coord? coord,
    EdgeInsets? padding,
    List<AxisGuide>? axes,
    TooltipGuide? tooltip,
    CrosshairGuide? crosshair,
    List<Annotation>? annotations,
    Map<String, Selection>? selections,
    this.rebuild,
  }) : spec = Spec<D>(
    data: data,
    changeData: changeData,
    variables: variables,
    transforms: transforms,
    elements: elements,
    coord: coord,
    padding: padding,
    axes: axes,
    tooltip: tooltip,
    crosshair: crosshair,
    annotations: annotations,
    selections: selections,
  );

  /// Specification of the chart.
  /// 
  /// Properties are collected from the [Chart] constructor.
  final Spec<D> spec;

  /// The behavior when widget is updated.
  /// 
  /// If null, new [spec] will be compared with the old one, and chart will rebuild
  /// only when [spec] is changed.
  /// 
  /// If true, chart will always rebuild.
  /// 
  /// If false, chart will never rebuild.
  final bool? rebuild;

  @override
  _ChartState<D> createState() => _ChartState<D>();
}

// initState -> build -> getPositionForChild -> paint
class _ChartState<D> extends State<Chart<D>> {
  View<D>? view;

  Size size = Size.zero;

  Offset gestureLocalPosition = Offset.zero;

  PointerDeviceKind gestureKind = PointerDeviceKind.unknown;

  Offset? gestureLocalMoveStart;

  ScaleUpdateDetails? gestureScaleDetail;

  void repaint() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant Chart<D> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rebuild ?? widget.spec != oldWidget.spec) {
      view = null;
    } else if (
      widget.spec.changeData == true ||
      (widget.spec.changeData == null && widget.spec.data != oldWidget.spec.data)
    ) {
      view!.changeData(widget.spec.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ChartLayoutDelegate<D>(this),
      child: Listener(
        child: GestureDetector(
          child: CustomPaint(
            painter: _ChartPainter<D>(this),
          ),
          onDoubleTap: () {
            view!.gesture(Gesture(
              GestureType.doubleTap,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onDoubleTapCancel: () {
            view!.gesture(Gesture(
              GestureType.doubleTapCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onDoubleTapDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.doubleTapDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onForcePressEnd: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.forcePressEnd,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onForcePressPeak: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.forcePressPeak,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onForcePressStart: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.forcePressStart,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onForcePressUpdate: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.forcePressUpdate,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onLongPress: () {
            view!.gesture(Gesture(
              GestureType.longPress,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onLongPressCancel: () {
            view!.gesture(Gesture(
              GestureType.longPressCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onLongPressDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.longPressDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onLongPressEnd: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = null;
            view!.gesture(Gesture(
              GestureType.longPressEnd,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onLongPressMoveUpdate: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.longPressMoveUpdate,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
              localMoveStart: gestureLocalMoveStart,
            ));
          },
          onLongPressStart: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.longPressStart,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onLongPressUp: () {
            view!.gesture(Gesture(
              GestureType.longPressUp,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onScaleEnd: (detail) {
            gestureLocalMoveStart = null;
            gestureScaleDetail = null;
            view!.gesture(Gesture(
              GestureType.scaleEnd,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onScaleStart: (detail) {
            gestureLocalPosition = detail.localFocalPoint;
            gestureLocalMoveStart = detail.localFocalPoint;
            gestureScaleDetail = ScaleUpdateDetails(
              focalPoint: detail.focalPoint,
              localFocalPoint: detail.localFocalPoint,
              pointerCount: detail.pointerCount,
            );
            view!.gesture(Gesture(
              GestureType.scaleStart,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onScaleUpdate: (detail) {
            gestureLocalPosition = detail.localFocalPoint;
            view!.gesture(Gesture(
              GestureType.scaleUpdate,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
              localMoveStart: gestureLocalMoveStart,
              preScaleDetail: gestureScaleDetail,
            ));
            gestureScaleDetail = detail;
          },
          onSecondaryLongPress: () {
            view!.gesture(Gesture(
              GestureType.secondaryLongPress,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onSecondaryLongPressCancel: () {
            view!.gesture(Gesture(
              GestureType.secondaryLongPressCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onSecondaryLongPressDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.secondaryLongPressDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onSecondaryLongPressEnd: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = null;
            view!.gesture(Gesture(
              GestureType.secondaryLongPressEnd,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onSecondaryLongPressMoveUpdate: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.secondaryLongPressMoveUpdate,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
              localMoveStart: gestureLocalMoveStart,
            ));
          },
          onSecondaryLongPressStart: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.secondaryLongPressStart,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onSecondaryLongPressUp: () {
            view!.gesture(Gesture(
              GestureType.secondaryLongPressUp,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onSecondaryTap: () {
            view!.gesture(Gesture(
              GestureType.secondaryTap,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onSecondaryTapCancel: () {
            view!.gesture(Gesture(
              GestureType.secondaryTapCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onSecondaryTapDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.secondaryTapDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onSecondaryTapUp: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.secondaryTapUp,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTap: () {
            view!.gesture(Gesture(
              GestureType.tap,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTapCancel: () {
            view!.gesture(Gesture(
              GestureType.tapCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTapDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tapDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTapUp: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tapUp,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTertiaryLongPress: () {
            view!.gesture(Gesture(
              GestureType.tertiaryLongPress,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTertiaryLongPressCancel: () {
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTertiaryLongPressDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTertiaryLongPressEnd: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = null;
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressEnd,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTertiaryLongPressMoveUpdate: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressMoveUpdate,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
              localMoveStart: gestureLocalMoveStart,
            ));
          },
          onTertiaryLongPressStart: (detail) {
            gestureLocalPosition = detail.localPosition;
            gestureLocalMoveStart = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressStart,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTertiaryLongPressUp: () {
            view!.gesture(Gesture(
              GestureType.tertiaryLongPressUp,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTertiaryTapCancel: () {
            view!.gesture(Gesture(
              GestureType.tertiaryTapCancel,
              gestureKind,
              gestureLocalPosition,
              size,
              null,
            ));
          },
          onTertiaryTapDown: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tertiaryTapDown,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
          onTertiaryTapUp: (detail) {
            gestureLocalPosition = detail.localPosition;
            view!.gesture(Gesture(
              GestureType.tertiaryTapUp,
              gestureKind,
              gestureLocalPosition,
              size,
              detail,
            ));
          },
        ),
        onPointerHover: (event) {
          gestureKind = event.kind;
          gestureLocalPosition = event.localPosition;
          view!.gesture(Gesture(
            GestureType.hover,
            gestureKind,
            gestureLocalPosition,
            size,
            null,
          ));
        },
        onPointerSignal: (event) {
          gestureLocalPosition = event.localPosition;
          if (event is PointerScrollEvent) {
            view!.gesture(Gesture(
              GestureType.scroll,
              gestureKind,
              gestureLocalPosition,
              size,
              event.scrollDelta,
            ));
          }
        },
      ),
    );
  }
}

// build -> getPositionForChild -> paint

class _ChartLayoutDelegate<D> extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.state);

  final _ChartState<D> state;

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => false;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    state.size = size;

    if (state.view == null) {
      state.view = View<D>(
        state.widget.spec,
        size,
        state.repaint,
      );
    } else if (size != state.view!.size) {
      state.view!.resize(size);
    }
    
    return super.getPositionForChild(size, childSize);
  }
}

class _ChartPainter<D> extends CustomPainter {
  _ChartPainter(this.state);

  final _ChartState<D> state;

  @override
  void paint(Canvas canvas, Size size) {
    if (state.view != null) {
      state.view!.graffiti.paint(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
    this != oldDelegate;
}
