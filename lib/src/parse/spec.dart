import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/geom_element.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/guide/tooltip/tooltip.dart';

class Spec {
  Spec({
    required this.data,
    required this.elements,
    this.coord,
    this.padding,
    this.axes,
    this.tooltip,
    this.annotations,
    this.selections,
    this.onEvent,
    this.onSelection,
  });

  final Map<String, DataSet> data;

  final List<GeomElement> elements;

  final Coord? coord;

  final EdgeInsets? padding;

  final List<GuideAxis>? axes;

  final Tooltip? tooltip;

  final List<Annotation>? annotations;

  final Map<String, Selection>? selections;

  final Map<EventType, void Function(Event)>? onEvent;

  final Map<String, void Function(List<Original>)>? onSelection;

  @override
  bool operator ==(Object other) =>
    other is Spec &&
    DeepCollectionEquality().equals(data, other.data) &&
    DeepCollectionEquality().equals(elements, other.elements) &&
    coord == other.coord &&
    padding == other.padding &&
    DeepCollectionEquality().equals(axes, other.axes) &&
    tooltip == other.tooltip &&
    DeepCollectionEquality().equals(annotations, other.annotations) &&
    DeepCollectionEquality().equals(selections, other.selections) &&
    DeepCollectionEquality().equals(onEvent?.keys, onEvent?.keys) &&  // Function
    DeepCollectionEquality().equals(onSelection?.keys, other.onSelection?.keys);  // Function
  
  Set<String> diffDataSource(Spec other) {
    assert(this == other);

    final rst = <String>{};
    for (var name in data.keys) {
      if (data[name]?.source != other.data[name]?.source) {
        rst.add(name);
      }
    }
    return rst;
  }
}
