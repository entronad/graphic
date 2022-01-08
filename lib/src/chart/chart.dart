import 'dart:ui';

import 'package:graphic/src/util/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

import 'view.dart';

/// A widget to display the chart.
///
/// Specifications details of data visualization are seen in this class properties.
/// The are set in the constructor[new Chart].
///
/// Usually, if any specification or data is changed, the chart will rebuild or
/// reevaluate automatically. Some subtle setting is controlled by [rebuild] and
/// [changeData]. Note that function properties will not be checked in change test.
///
/// The generic [D] is the type of datum in [data] list.
class Chart<D> extends StatefulWidget {
  /// Creates a chart widget.
  Chart({
    required this.data,
    this.changeData,
    required this.variables,
    this.transforms,
    required this.elements,
    this.coord,
    this.padding,
    this.axes,
    this.tooltip,
    this.crosshair,
    this.annotations,
    this.selections,
    this.rebuild,
  });

  /// The data list to visualize.
  final List<D> data;

  /// Name identifiers and specifications of variables.
  ///
  /// The name identifier string will represent the variable in other specifications.
  final Map<String, Variable<D, dynamic>> variables;

  /// Specifications of transforms applied to variable data.
  final List<VariableTransform>? transforms;

  /// Specifications of geometory elements.
  final List<GeomElement> elements;

  /// Specification of the coordinate.
  ///
  /// If null, a default [RectCoord] is set.
  final Coord? coord;

  /// The padding from coordinate region to the widget border.
  ///
  /// This is a function with chart size as input that you may need to calculate
  /// the padding.
  ///
  /// Usually, the [axes] is attached to the border of coordinate region (See details
  /// in [Coord]), and in the [padding] space.
  ///
  /// If null, a default `EdgeInsets.fromLTRB(40, 5, 10, 20)` for [RectCoord] and
  /// `EdgeInsets.all(10)` for [PolarCoord] is set.
  final EdgeInsets Function(Size)? padding;

  /// Specifications of axes.
  final List<AxisGuide>? axes;

  /// Specification of tooltip on [selections].
  final TooltipGuide? tooltip;

  /// Specification of pointer crosshair on [selections].
  final CrosshairGuide? crosshair;

  /// Specifications of annotations.
  final List<Annotation>? annotations;

  /// Name identifiers and specifications of selection definitions.
  ///
  /// The name identifier string will represent the selection in other specifications.
  final Map<String, Selection>? selections;

  /// The behavior of chart rebuilding when widget is updated.
  ///
  /// If null, new [Chart] will be compared with the old one, and chart will rebuild
  /// only when specifications are changed.
  ///
  /// If true, chart will always rebuild. **So be cautious to set true**.
  ///
  /// If false, chart will never rebuild.
  final bool? rebuild;

  /// The behavior of data reevaluation when widget is updated.
  ///
  /// If null, new [data] will be compared with the old one, a [ChangeDataSignal]
  /// will be emitted and the chart will be reevaluated only when they are not the
  /// same instance.
  ///
  /// If true, a [ChangeDataSignal] will always be emitted and the chart will always
  /// be reevaluated. **So be cautious to set true**.
  ///
  /// If false, a [ChangeDataSignal] will never be emitted and the chart will never
  /// be reevaluated.
  final bool? changeData;

  /// Checks the equlity of two chart specifications.
  bool equalSpecTo(Object other) =>
      other is Chart<D> &&
      // data are checked by changeData.
      changeData == other.changeData &&
      deepCollectionEquals(variables, other.variables) &&
      deepCollectionEquals(transforms, other.transforms) &&
      deepCollectionEquals(elements, other.elements) &&
      coord == other.coord &&
      deepCollectionEquals(axes, other.axes) &&
      tooltip == other.tooltip &&
      crosshair == other.crosshair &&
      deepCollectionEquals(annotations, other.annotations) &&
      deepCollectionEquals(selections, other.selections) &&
      rebuild == other.rebuild;

  @override
  _ChartState<D> createState() => _ChartState<D>();
}

/// The state of a [Chart].
///
/// The methods calling order is:
///
/// [initState] --> [build] --> [_ChartLayoutDelegate.getPositionForChild] --> [_ChartPainter.paint]
class _ChartState<D> extends State<Chart<D>> {
  /// The view that controlls the data visualization.
  ///
  /// For a chart widget, to "rebuild" means to create a new [view].
  View<D>? view;

  /// Size of the chart widget.
  ///
  /// The chart state hold this for the [Listener] and the [GestureDetector] to
  /// create [Gesture]s.
  Size size = Size.zero;

  /// The local position of the last [Gesture].
  ///
  /// It is record by chart state to for [Gesture]s when the [GestureDetector]
  /// callback dosen't have a current position. It is updated when the callback
  /// has a current position.
  Offset gestureLocalPosition = Offset.zero;

  /// The device kind of the last [Gesture].
  ///
  /// It is record by chart state to for [Gesture]s when the [GestureDetector]
  /// callback dosen't have a current device kind. It is updated when the callback
  /// has a current device kind.
  PointerDeviceKind gestureKind = PointerDeviceKind.unknown;

  /// The start postion of a scale or long press gesture.
  Offset? gestureLocalMoveStart;

  /// Details of previous scale update.
  ScaleUpdateDetails? gestureScaleDetail;

  /// Asks the chart state to trigger a repaint.
  void repaint() {
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant Chart<D> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Checke whether to rebuild or tirgger changeData.
    if (widget.rebuild ?? !widget.equalSpecTo(oldWidget)) {
      view = null;
    } else if (widget.changeData == true ||
        (widget.changeData == null && widget.data != oldWidget.data)) {
      view!.changeData(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ChartLayoutDelegate<D>(this),
      // Listener for hover and scroll.
      child: Listener(
        child: GestureDetector(
          child: CustomPaint(
            // Make sure the Listener and the GestureDetector inflate the container.
            size: Size.infinite,
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
            // Mock a ScaleUpdateDetails so that the first scale update will have
            // a preScaleDetail.
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

/// The delegate of [CustomSingleChildLayout] to get the chart widgit size.
class _ChartLayoutDelegate<D> extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.state);

  /// The chart state for configuration.
  final _ChartState<D> state;

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => true;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    state.size = size;

    if (state.view == null) {
      // When rebuild is required, the state.view is set null. To rebuild meanse
      // to create a new view. A view is and only is created in _ChartLayoutDelegate.getPositionForChild
      // because it needs the current size.

      state.view = View<D>(
        state.widget,
        size,
        state.repaint,
      );
    } else if (size != state.view!.graffiti.size) {
      // Only emmit resize when size is realy changed.

      state.view!.resize(size);
    }

    return super.getPositionForChild(size, childSize);
  }
}

/// The painter for [_ChartState]'s [CustomPaint].
class _ChartPainter<D> extends CustomPainter {
  _ChartPainter(this.state);

  /// The chart state for configuration.
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
