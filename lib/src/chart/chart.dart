import 'package:flutter/widgets.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
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
class Chart extends StatefulWidget {
  Chart({
    required DataSet data,
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
  }) : spec = Spec(
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

  final Spec spec;

  final bool? rebuild;

  @override
  _ChartState createState() => _ChartState();
}

// initState -> build -> getPositionForChild -> paint
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

    if (widget.rebuild ?? widget.spec != oldWidget.spec) {
      // TODO: rebuild.
      return;
    }
    if (dataChanged(widget.spec.data, oldWidget.spec.data)) {
      // TODO: emmit changeData.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}
