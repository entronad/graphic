import 'package:flutter/painting.dart';
import 'package:graphic/src/encode/position.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// The specification of an aesthetic encode.
///
/// Aesthetic encodes determin how an mark item is perceived. An encode
/// value usually represent an variable value of a tuple. the encoding rules form
/// data to encode value can be defined in various ways (See details in the properties).
///
/// The generic [EV] is the type of encode value.
abstract class Encode<EV> {
  /// Creates an aesthetic encode.
  Encode({
    this.value,
    this.encoder,
    this.updaters,
  });

  /// Indicates a encode value for all tuples directly.
  EV? value;

  /// Indicates how to get encode value from a tuple directly.
  EV Function(Tuple)? encoder;

  /// Encode updaters when a selection occurs.
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
  Map<String, Map<bool, SelectionUpdater<EV>>>? updaters;

  @override
  bool operator ==(Object other) => other is Encode<EV> && value == other.value;
}

/// The base class of encoders.
///
/// It gets encode values in different ways according to [Encode] types and their
/// indicating properties.
abstract class Encoder<EV> {
  /// Gets an encode value.
  ///
  /// Usually it needs a [scaled] input, while [tuple] is for [CustomEncoder]s and
  /// [ValueEncodeEncoder]s don't need any input.
  EV encode(Scaled scaled, Tuple tuple);
}

/// The encoder for which [Encode.value] is set.
class ValueEncodeEncoder<EV> extends Encoder<EV> {
  ValueEncodeEncoder(this.value);

  /// The indicated value for all cases.
  final EV value;

  @override
  EV encode(Scaled scaled, Tuple tuple) => value;
}

/// The encoder for which [Encode.encoder] is set.
class CustomEncoder<EV> extends Encoder<EV> {
  CustomEncoder(this.customEncoder);

  /// The costom encoding function.
  final EV Function(Tuple) customEncoder;

  @override
  EV encode(Scaled scaled, Tuple tuple) => customEncoder(tuple);
}

/// The operator to encode all encodes and create [Attributes] list.
class EncodeOp extends Operator<List<Attributes>> {
  EncodeOp(Map<String, dynamic> params) : super(params);

  @override
  List<Attributes> evaluate() {
    final scaleds = params['scaleds'] as List<Scaled>;
    final tuples = params['tuples'] as List<Tuple>;
    final positionEncoder = params['positionEncoder'] as PositionEncoder;
    final shapeEncoder = params['shapeEncoder'] as Encoder<Shape>;
    final colorEncoder = params['colorEncoder'] as Encoder<Color>?;
    final gradientEncoder = params['gradientEncoder'] as Encoder<Gradient>?;
    final elevationEncoder = params['elevationEncoder'] as Encoder<double>?;
    final labelEncoder = params['labelEncoder'] as Encoder<Label>?;
    final sizeEncoder = params['sizeEncoder'] as Encoder<double>?;
    final tagEncoder = params['tagEncoder'] as String? Function(Tuple)?;

    assert(isSingle([colorEncoder, gradientEncoder]));

    final rst = <Attributes>[];
    for (var i = 0; i < scaleds.length; i++) {
      final scaled = scaleds[i];
      final tuple = tuples[i];
      rst.add(Attributes(
        index: i,
        tag: tagEncoder == null ? null : tagEncoder(tuple),
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
