import 'package:flutter/widgets.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/geom_element.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/parse/spec.dart';

import 'view.dart';

/// [D]: Type of source data items.
class Chart<D> extends StatefulWidget {
  Chart({
    required DataSet<D> data,
    required List<GeomElement> elements,
    Coord? coord,
    EdgeInsets? padding,
    List<GuideAxis>? axes,
    Tooltip? tooltip,
    Crosshair? crosshair,
    List<Annotation>? annotations,
    Map<String, Select>? selects,
    Map<EventType, void Function(Event)>? onEvent,
    Map<String, void Function(List<Original>)>? onSelect,
    this.rebuild,
  }) : spec = Spec<D>(
    data: data,
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
  late View<D> view;

  @override
  void initState() {
    super.initState();

    view = View<D>(widget.spec);
  }

  @override
  void didUpdateWidget(covariant Chart<D> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.rebuild ?? widget.spec != oldWidget.spec) {
      view = View<D>(widget.spec);
    } else if (dataChanged(widget.spec.data, oldWidget.spec.data)) {
      view.changeData(widget.spec.data.source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _ChartLayoutDelegate(view),
      child: Listener(
        child: CustomPaint(
          painter: _ChartPainter(view),
        ),
        onPointerDown: (event) {
          view.arena.emit(
            ListenerEvent(ListenerEventType.pointerDown, event),
          );
        },
        onPointerMove: (event) {
          view.arena.emit(
            ListenerEvent(ListenerEventType.pointerMove, event),
          );
        },
        onPointerUp: (event) {
          view.arena.emit(
            ListenerEvent(ListenerEventType.pointerUp, event),
          );
        },
        onPointerCancel: (event) {
          view.arena.emit(
            ListenerEvent(ListenerEventType.pointerCancel, event),
          );
        },
        onPointerSignal: (event) {
          view.arena.emit(
            ListenerEvent(ListenerEventType.pointerSignal, event),
          );
        },
      ),
    );
  }
}

// build -> getPositionForChild -> paint

class _ChartLayoutDelegate extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate(this.view);

  final View view;

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) => false;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    view.resize(size);
    return super.getPositionForChild(size, childSize);
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.view);

  final View view;

  @override
  void paint(Canvas canvas, Size size) =>
    view.graffiti.paint(canvas);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
    this != oldDelegate;
}
