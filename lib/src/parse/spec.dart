import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/guide/interaction/crosshair.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/guide/annotation/annotation.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/variable/transform/transform.dart';
import 'package:graphic/src/variable/variable.dart';

/// The specification of a chart.
/// 
/// The generic [D] is the type of datum in [data] list.
/// 
/// See also:
/// 
/// - [Chart], the widget where the specification is declared.
/// - [Variable], variable specification.
/// - [VariableTransform], variable transform specification.
/// - [GeomElement], geometory element specification.
/// - [Coord], coordinate specification.
/// - [AxisGuide], axis specification.
/// - [TooltipGuide], tooltip specification.
/// - [CrosshairGuide], crosshair specification.
/// - [Annotation], annotation specification.
/// - [Selection], selection specification.
class Spec<D> {
  /// Creates a chart specification.
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
    this.selections,
  });

  /// The data list to visualize.
  final List<D> data;

  /// The behavior of data reevaluation when widget is updated.
  /// 
  /// If null, new [data] will be compared with the old one, a [ChangeDataSignal]
  /// will be emitted and the chart will be reevaluated only when they are not the
  /// same instance.
  /// 
  /// If true, a [ChangeDataSignal] will always be emitted and the chart will always
  /// be reevaluated.
  /// 
  /// If false, a [ChangeDataSignal] will never be emitted and the chart will never
  /// be reevaluated.
  final bool? changeData;

  /// Name identifiers and specifications of variables.
  /// 
  /// The name identifier string will represent the variable in other specifications.
  final Map<String, Variable<D, dynamic>> variables;

  /// Specifications of transforms applied to variable data.
  final List<VariableTransform>? transforms;

  /// Specifications of geometory elements.
  final List<GeomElement> elements;

  /// Specification of the coordinate.
  /// 
  /// If null, a default [RectCoord] is set.
  final Coord? coord;

  /// The padding from coordinate region to the widget border.
  /// 
  /// Usually, the [axes] is attached to the border of coordinate region (See details
  /// in [Coord]), and in the [padding] space.
  /// 
  /// If null, a default `EdgeInsets.fromLTRB(40, 5, 10, 20)` for [RectCoord] and
  /// `EdgeInsets.all(10)` for [PolarCoord] is set.
  final EdgeInsets? padding;

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
    DeepCollectionEquality().equals(selections, other.selections);
}
