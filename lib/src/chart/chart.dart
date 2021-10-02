import 'package:flutter/widgets.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

import 'view.dart';

/// [D]: Type of source data items.
class Chart<D> extends StatefulWidget {
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
    Map<String, Select>? selects,
    Map<EventType, void Function(Event)>? onEvent,
    Map<String, void Function(List<Original>)>? onSelect,
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
    selects: selects,
    onEvent: onEvent,
    onSelect: onSelect,
  );

  final Spec<D> spec;

  final bool? rebuild;

  @override
  _ChartState<D> createState() => _ChartState<D>();
}

// initState -> build -> getPositionForChild -> paint
class _ChartState<D> extends State<Chart<D>> {
  final arena = GestureArena(Size.zero);

  View<D>? view;

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
        child: CustomPaint(
          painter: _ChartPainter<D>(this),
        ),
        onPointerDown: (event) {
          arena.emit(
            ListenerEvent(ListenerEventType.pointerDown, event),
          );
        },
        onPointerMove: (event) {
          arena.emit(
            ListenerEvent(ListenerEventType.pointerMove, event),
          );
        },
        onPointerUp: (event) {
          arena.emit(
            ListenerEvent(ListenerEventType.pointerUp, event),
          );
        },
        onPointerCancel: (event) {
          arena.emit(
            ListenerEvent(ListenerEventType.pointerCancel, event),
          );
        },
        onPointerSignal: (event) {
          arena.emit(
            ListenerEvent(ListenerEventType.pointerSignal, event),
          );
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
    state.arena.size = size;

    if (state.view == null) {
      state.view = View<D>(
        state.widget.spec,
        size,
        state.arena,
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
