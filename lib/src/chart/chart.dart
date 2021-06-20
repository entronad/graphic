import 'package:flutter/widgets.dart';
import 'package:graphic/src/annotation/base.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/event/selection/base.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/tooltip/base.dart';

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
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
