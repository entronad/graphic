import 'package:flutter/widgets.dart';
import 'package:graphic/src/annotation/annotation.dart';
import 'package:graphic/src/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/geom_element.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/tooltip/tooltip.dart';

import 'view.dart';

/// [D]: Type of source data items.
class Chart extends StatefulWidget {
  Chart({
    required Map<String, DataSet> data,
    required List<GeomElement> elements,
    Coord? coord,
    List<GuideAxis>? axes,
    Tooltip? tooltip,
    List<Annotation>? annotations,
    Map<String, Selection>? selections,
    Map<EventType, void Function(Event)>? onEvent,
    Map<String, void Function(List<Tuple>)>? onSelection,
    this.forceRebuild = false,
  }) : spec = Spec(
    data: data,
    elements: elements,
    coord: coord,
    axes: axes,
    tooltip: tooltip,
    annotations: annotations,
    selections: selections,
    onEvent: onEvent,
    onSelection: onSelection,
  );

  final Spec spec;

  final bool forceRebuild;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  View? _view;

  @override
  void initState() {
    super.initState();

    _view = View(widget);
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.forceRebuild || widget.spec != oldWidget.spec) {
      // TODO: rebuild.
      return;
    }
    final changedData = widget.spec.diffDataSource(oldWidget.spec);
    if (changedData.isNotEmpty) {
      // TODO: emmit changeData.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
