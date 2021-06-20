import 'package:collection/collection.dart';
import 'package:graphic/src/annotation/base.dart';
import 'package:graphic/src/axis/base.dart';
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/base.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/event/selection/base.dart';
import 'package:graphic/src/tooltip/base.dart';

class Spec {
  Spec({
    required this.data,
    required this.elements,
    this.coord,
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

  final List<GuideAxis>? axes;

  final Tooltip? tooltip;

  final List<Annotation>? annotations;

  final Map<String, Selection>? selections;

  final Map<EventType, void Function(Event)>? onEvent;

  final Map<String, void Function(List<Tuple>)>? onSelection;

  @override
  bool operator ==(Object other) =>
    other is Spec &&
    DeepCollectionEquality().equals(data, other.data) &&
    DeepCollectionEquality().equals(elements, other.elements) &&
    coord == other.coord &&
    DeepCollectionEquality().equals(axes, other.axes) &&
    tooltip == other.tooltip &&
    DeepCollectionEquality().equals(annotations, other.annotations) &&
    DeepCollectionEquality().equals(selections, other.selections) &&
    DeepCollectionEquality().equals(onEvent?.keys, onEvent?.keys) &&  // Function
    DeepCollectionEquality().equals(onSelection?.keys, other.onSelection?.keys);  // Function
}
