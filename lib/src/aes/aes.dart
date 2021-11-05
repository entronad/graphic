import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'channel.dart';
import 'color.dart';
import 'elevation.dart';
import 'gradient.dart';
import 'shape.dart';
import 'size.dart';

// Attr

/// The specification of an aesthetic attribute.
///
/// Aesthetic attributes determin how an element item is perceived. An attribute
/// value usually represent an variable value of a tuple. the encoding rules form
/// data to attribute value can be defined in various ways (See details in the properties).
///
/// The generic [AV] is the type of attribute value.
abstract class Attr<AV> {
  /// Creates an aesthetic attribute.
  Attr({
    this.value,
    this.encode,
    this.onSelection,
  });

  /// Indicates a attribute value for all tuples directly.
  AV? value;

  /// Indicates how to get attribute form a tuple directly.
  AV Function(Tuple)? encode;

  /// Attribute updates when a selection occurs.
  ///
  /// The keys of outer map are names of selections defined, and Corresponding definitions
  /// will only react to their on selections.
  ///
  /// The keys of inner map are selection states. True means selected and false
  /// means unselected. The corresponding updates will react when the tuple is in
  /// That state.
  ///
  /// Not that this definition is only meaningfull when a selection orrurs. If there
  /// is no current selection, tuples are neither selected or unselected.
  Map<String, Map<bool, SelectionUpdate<AV>>>? onSelection;

  @override
  bool operator ==(Object other) => other is Attr<AV> && value == other.value;
}

/// The base class of attribute encoders.
///
/// It gets attribute values in different ways according to [Attr] types and their
/// indicating properties.
abstract class Encoder<AV> {
  /// Gets an attribute value.
  ///
  /// Usually it needs a [scaled] input, while [tuple] is for [CustomEncoder]s and
  /// [ValueAttrEncoder]s don't need any input.
  AV encode(Scaled scaled, Tuple tuple);
}

/// The encoder for which [Attr.value] is set.
class ValueAttrEncoder<AV> extends Encoder<AV> {
  ValueAttrEncoder(this.value);

  /// The indicated value for all cases.
  final AV value;

  @override
  AV encode(Scaled scaled, Tuple tuple) => value;
}

/// The encoder for which [Attr.encode] is set.
class CustomEncoder<AV> extends Encoder<AV> {
  CustomEncoder(this.customEncode);

  /// The costom encoding function.
  final AV Function(Tuple) customEncode;

  @override
  AV encode(Scaled scaled, Tuple tuple) => customEncode(tuple);
}

/// The operator to encode all attributes and create [Aes]s.
class AesOp extends Operator<List<Aes>> {
  AesOp(Map<String, dynamic> params) : super(params);

  @override
  List<Aes> evaluate() {
    final scaleds = params['scaleds'] as List<Scaled>;
    final tuples = params['tuples'] as List<Tuple>;
    final positionEncoder = params['positionEncoder'] as PositionEncoder;
    final shapeEncoder = params['shapeEncoder'] as Encoder<Shape>;
    final colorEncoder = params['colorEncoder'] as Encoder<Color>?;
    final gradientEncoder = params['gradientEncoder'] as Encoder<Gradient>?;
    final elevationEncoder = params['elevationEncoder'] as Encoder<double>?;
    final labelEncoder = params['labelEncoder'] as Encoder<Label>?;
    final sizeEncoder = params['sizeEncoder'] as Encoder<double>?;

    assert(isSingle([colorEncoder, gradientEncoder]));

    final rst = <Aes>[];
    for (var i = 0; i < scaleds.length; i++) {
      final scaled = scaleds[i];
      final tuple = tuples[i];
      rst.add(Aes(
        index: i,
        position: positionEncoder.encode(scaled, tuple),
        shape: shapeEncoder.encode(scaled, tuple),
        color: colorEncoder?.encode(scaled, tuple),
        gradient: gradientEncoder?.encode(scaled, tuple),
        elevation: elevationEncoder?.encode(scaled, tuple),
        label: labelEncoder?.encode(scaled, tuple),
        size: sizeEncoder?.encode(scaled, tuple),
      ));
    }
    return rst;
  }
}

/// Parses the aesthetic related specifications.
void parseAes(
  Chart spec,
  View view,
  Scope scope,
) {
  for (var elementSpec in spec.elements) {
    var form = elementSpec.position?.form;
    // Default algebracal form.
    if (form == null) {
      final variables = scope.scaleSpecs.keys.toList();
      form = (Varset(variables[0]) * Varset(variables[1])).form;
    }
    scope.forms.add(form);

    final origin = view.add(OriginOp({
      'form': form,
      'scales': scope.scales,
      'coord': scope.coord,
    }));
    scope.origins.add(origin);

    final position = view.add(PositionOp({
      'form': form,
      'scales': scope.scales,
      'completer': getPositionCompleter(elementSpec),
      'origin': origin,
    }));

    scope.aesesList.add(view.add(AesOp({
      'scaleds': scope.scaleds,
      'tuples': scope.tuples,
      'positionEncoder': position,
      'shapeEncoder': getChannelEncoder<Shape>(
        elementSpec.shape ?? ShapeAttr(value: getDefaultShape(elementSpec)),
        scope.scaleSpecs,
        null,
      ),
      // Uses a default color when both color and gradient attributes are null.
      'colorEncoder': elementSpec.gradient == null
          ? getChannelEncoder<Color>(
              elementSpec.color ?? ColorAttr(value: Defaults.primaryColor),
              scope.scaleSpecs,
              (List<Color> values, List<double> stops) =>
                  ContinuousColorConv(values, stops),
            )
          : null,
      'gradientEncoder': elementSpec.gradient == null
          ? null
          : getChannelEncoder<Gradient>(
              elementSpec.gradient!,
              scope.scaleSpecs,
              (List<Gradient> values, List<double> stops) =>
                  ContinuousGradientConv(values, stops),
            ),
      'elevationEncoder': elementSpec.elevation == null
          ? null
          : getChannelEncoder<double>(
              elementSpec.elevation!,
              scope.scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousElevationConv(values, stops),
            ),
      'labelEncoder': elementSpec.label == null
          ? null
          : CustomEncoder<Label>(elementSpec.label!.encode!),
      'sizeEncoder': elementSpec.size == null
          ? null
          : getChannelEncoder<double>(
              elementSpec.size!,
              scope.scaleSpecs,
              (List<double> values, List<double> stops) =>
                  ContinuousSizeConv(values, stops),
            ),
    })));
  }
}
