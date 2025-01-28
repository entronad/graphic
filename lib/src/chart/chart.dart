import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/mark/mark.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/collection.dart';
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
/// [changeData]. Note that function properties will always be regarded unchanged.
///
/// The generic [D] is the type of datum in [data] list.
///
/// The properties of this chart sepcification are final because it is also an immutable
/// [StatefulWidget], but other specifications can be modified.
class Chart<D> extends StatefulWidget {
  /// Creates a chart widget.
  const Chart({
    Key? key,
    required this.data,
    this.changeData,
    required this.variables,
    this.transforms,
    required this.marks,
    this.coord,
    this.padding,
    this.axes,
    this.tooltip,
    this.crosshair,
    this.annotations,
    this.selections,
    this.rebuild,
    this.gestureStream,
    this.resizeStream,
    this.changeDataStream,
  }) : super(key: key);

  /// The data list to visualize.
  final List<D> data;

  /// Name identifiers and specifications of variables.
  ///
  /// The name identifier string will represent the variable in other specifications.
  final Map<String, Variable<D, dynamic>> variables;

  /// Specifications of transforms applied to variable data.
  final List<VariableTransform>? transforms;

  /// Specifications of geometry marks.
  final List<Mark> marks;

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
  /// If null, new [data] will be compared with the old one, a [ChangeDataEvent]
  /// will be emitted and the chart will be reevaluated only when they are not the
  /// same instance.
  ///
  /// If true, a [ChangeDataEvent] will always be emitted and the chart will always
  /// be reevaluated. **So be cautious to set true**.
  ///
  /// If false, a [ChangeDataEvent] will never be emitted and the chart will never
  /// be reevaluated.
  final bool? changeData;

  /// The interaction stream of gesture events.
  ///
  /// You can either get gesture events by listening to it's stream, or mannually
  /// emit gesture events into this chart by adding to it's sink.
  ///
  /// You can also share it with other charts for sharing gesture events, in which
  /// case make sure it is broadcast.
  final StreamController<GestureEvent>? gestureStream;

  /// The interaction stream of resize events.
  ///
  /// You can either get resize events by listening to it's stream, or mannually
  /// emit resize events into this chart by adding to it's sink.
  ///
  /// You can also share it with other charts for sharing resize events, in which
  /// case make sure it is broadcast.
  final StreamController<ResizeEvent>? resizeStream;

  /// The interaction stream of change data events.
  ///
  /// You can either get change data events by listening to it's stream, or mannually
  /// emit change data events into this chart by adding to it's sink.
  ///
  /// You can also share it with other charts for sharing change data events, in which
  /// case make sure it is broadcast.
  final StreamController<ChangeDataEvent<D>>? changeDataStream;

  /// Checks the equlity of two chart specifications.
  bool equalSpecTo(Object other) =>
      other is Chart<D> &&
      // data are checked by changeData.
      deepCollectionEquals(variables, other.variables) &&
      deepCollectionEquals(transforms, other.transforms) &&
      deepCollectionEquals(marks, other.marks) &&
      coord == other.coord &&
      deepCollectionEquals(axes, other.axes) &&
      tooltip == other.tooltip &&
      crosshair == other.crosshair &&
      deepCollectionEquals(annotations, other.annotations) &&
      deepCollectionEquals(selections, other.selections) &&
      rebuild == other.rebuild &&
      changeData == other.changeData &&
      gestureStream == other.gestureStream &&
      resizeStream == other.resizeStream &&
      changeDataStream == other.changeDataStream;

  @override
  ChartState<D> createState() => ChartState<D>();
}

/// The state of a [Chart].
///
/// The methods calling order is:
///
/// [initState] --> [build] --> [_ChartLayoutDelegate.getPositionForChild] --> [_ChartPainter.paint]
class ChartState<D> extends State<Chart<D>> with TickerProviderStateMixin {
  /// The view that controlls the data visualization.
  ///
  /// For a chart widget, to "rebuild" means to create a new [view].
  ChartView<D>? view;

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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant Chart<D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Checke whether to rebuild or tirgger changeData.
    if (widget.rebuild ?? !widget.equalSpecTo(oldWidget)) {
      //Dispose of old view, when the widget rebuilds
      view?.dispose();
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
      child: MouseRegion(
        child: Listener(
          child: GestureDetector(
            child: RepaintBoundary(
              child: CustomPaint(
                // Make sure the Listener and the GestureDetector inflate the container.
                size: Size.infinite,
                painter: _ChartPainter<D>(this),
              ),
            ),
            onDoubleTap: () {
              view!.gesture(Gesture(
                GestureType.doubleTap,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onDoubleTapCancel: () {
              view!.gesture(Gesture(
                GestureType.doubleTapCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onLongPress: () {
              view!.gesture(Gesture(
                GestureType.longPress,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onLongPressCancel: () {
              view!.gesture(Gesture(
                GestureType.longPressCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
                localMoveStart: gestureLocalMoveStart,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onLongPressUp: () {
              view!.gesture(Gesture(
                GestureType.longPressUp,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onScaleEnd: (detail) {
              view!.gesture(Gesture(
                GestureType.scaleEnd,
                gestureKind,
                gestureLocalPosition,
                size,
                detail,
                chartKey: widget.key,
                localMoveStart: gestureLocalMoveStart,
              ));
              gestureLocalMoveStart = null;
              gestureScaleDetail = null;
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
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onSecondaryLongPressCancel: () {
              view!.gesture(Gesture(
                GestureType.secondaryLongPressCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
                localMoveStart: gestureLocalMoveStart,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onSecondaryLongPressUp: () {
              view!.gesture(Gesture(
                GestureType.secondaryLongPressUp,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onSecondaryTap: () {
              view!.gesture(Gesture(
                GestureType.secondaryTap,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onSecondaryTapCancel: () {
              view!.gesture(Gesture(
                GestureType.secondaryTapCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onTap: () {
              view!.gesture(Gesture(
                GestureType.tap,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onTapCancel: () {
              view!.gesture(Gesture(
                GestureType.tapCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onTertiaryLongPress: () {
              view!.gesture(Gesture(
                GestureType.tertiaryLongPress,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onTertiaryLongPressCancel: () {
              view!.gesture(Gesture(
                GestureType.tertiaryLongPressCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
                localMoveStart: gestureLocalMoveStart,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            },
            onTertiaryLongPressUp: () {
              view!.gesture(Gesture(
                GestureType.tertiaryLongPressUp,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
              ));
            },
            onTertiaryTapCancel: () {
              view!.gesture(Gesture(
                GestureType.tertiaryTapCancel,
                gestureKind,
                gestureLocalPosition,
                size,
                null,
                chartKey: widget.key,
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
                chartKey: widget.key,
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
                chartKey: widget.key,
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
              chartKey: widget.key,
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
                chartKey: widget.key,
              ));
            }
          },
        ),
        onEnter: (event) {
          gestureKind = event.kind;
          gestureLocalPosition = event.localPosition;
          view!.gesture(Gesture(
            GestureType.mouseEnter,
            gestureKind,
            gestureLocalPosition,
            size,
            null,
            chartKey: widget.key,
          ));
        },
        onExit: (event) {
          gestureKind = event.kind;
          gestureLocalPosition = event.localPosition;
          view!.gesture(Gesture(
            GestureType.mouseExit,
            gestureKind,
            gestureLocalPosition,
            size,
            null,
            chartKey: widget.key,
          ));
        },
      ),
    );
  }

  @override
  void dispose() {
    view?.dispose();
    super.dispose();
  }
}

/// The delegate of [CustomSingleChildLayout] to get the chart widgit size.
class _ChartLayoutDelegate<D> extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.state);

  /// The chart state.
  final ChartState<D> state;

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => true;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (state.view == null) {
      // When rebuild is required, the state.view is set null. To rebuild meanse
      // to create a new view. A view is and only is created in _ChartLayoutDelegate.getPositionForChild
      // because it needs the current size.

      state.view = ChartView<D>(
        state.widget,
        size,
        state,
        state.repaint,
      );
    } else if (size != state.size) {
      // Only emmit resize when size is realy changed.

      state.view!.resize(size);
    }

    state.size = size;

    return super.getPositionForChild(size, childSize);
  }
}

/// The painter for [_ChartState]'s [CustomPaint].
class _ChartPainter<D> extends CustomPainter {
  _ChartPainter(this.state);

  /// The chart state.
  final ChartState<D> state;

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
