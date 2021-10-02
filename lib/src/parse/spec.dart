import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

class Spec<D> {
  Spec({
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
    this.selects,
    this.onEvent,
    this.onSelect,
  });

  final List<D> data;

  final bool? changeData;

  final Map<String, Variable<D, dynamic>> variables;

  final List<VariableTransform>? transforms;

  final List<GeomElement> elements;

  final Coord? coord;

  final EdgeInsets? padding;

  final List<AxisGuide>? axes;

  final TooltipGuide? tooltip;

  final CrosshairGuide? crosshair;

  final List<Annotation>? annotations;

  final Map<String, Select>? selects;

  final Map<EventType, void Function(Event)>? onEvent;

  final Map<String, void Function(List<Original>)>? onSelect;

  @override
  bool operator ==(Object other) =>
    other is Spec &&
    DeepCollectionEquality().equals(data, other.data) &&
    changeData == other.changeData &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    DeepCollectionEquality().equals(transforms, other.transforms) &&
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
