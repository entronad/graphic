import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

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
    this.encoder,
    this.onSelection,
  });

  /// Indicates a attribute value for all tuples directly.
  AV? value;

  /// Indicates how to get attribute form a tuple directly.
  AV Function(Tuple)? encoder;

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
  Map<String, Map<bool, SelectionUpdater<AV>>>? onSelection;

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
  CustomEncoder(this.customEncoder);

  /// The costom encoding function.
  final AV Function(Tuple) customEncoder;

  @override
  AV encode(Scaled scaled, Tuple tuple) => customEncoder(tuple);
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
