import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
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

class Spec<D> {
  Spec({
    required this.data,
    required this.elements,
    this.coord,
    this.padding,
    this.axes,
    this.tooltip,
    this.crosshair,
    this.annotations,
    this.selects,
    this.onEvent,
    this.onSelect,
  });

  final DataSet<D> data;

  final List<GeomElement> elements;

  final Coord? coord;

  final EdgeInsets? padding;

  final List<GuideAxis>? axes;

  final Tooltip? tooltip;

  final Crosshair? crosshair;

  final List<Annotation>? annotations;

  final Map<String, Select>? selects;

  final Map<EventType, void Function(Event)>? onEvent;

  final Map<String, void Function(List<Original>)>? onSelect;

  @override
  bool operator ==(Object other) =>
    other is Spec &&
    DeepCollectionEquality().equals(data, other.data) &&
    DeepCollectionEquality().equals(elements, other.elements) &&
    coord == other.coord &&
    padding == other.padding &&
    DeepCollectionEquality().equals(axes, other.axes) &&
    tooltip == other.tooltip &&
    crosshair == other.crosshair &&
    DeepCollectionEquality().equals(annotations, other.annotations) &&
    DeepCollectionEquality().equals(selects, other.selects) &&
    DeepCollectionEquality().equals(onEvent?.keys, onEvent?.keys) &&  // Function
    DeepCollectionEquality().equals(onSelect?.keys, other.onSelect?.keys);  // Function
}
