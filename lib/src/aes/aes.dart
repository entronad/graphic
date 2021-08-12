import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/tuple.dart';

// Attr

/// An Attr can be determined by algebra/variable, value, or encode, but only one of them can be defined.
/// Attr can be updated by signal or selection.
abstract class Attr<AV> {
  Attr({
    this.value,
    this.encode,
    this.onSelection,
  });

  final AV? value;

  /// Encode original value tuple to aes value.
  final AV Function(Original)? encode;

  final Map<String, Map<bool, SelectionUpdate<AV>>>? onSelection;

  @override
  bool operator ==(Object other) =>
    other is Attr<AV> &&
    value == other.value;
    // encode: Function
    // onSelection: Function
}

// attr conv

abstract class AttrConv<SV extends num, AV> extends Converter<SV, AV> {
  @override
  SV invert(AV output) {
    throw UnimplementedError();
  }
}

// encoder

abstract class Encoder<AV> {
  AV encode(Scaled scaled, Original original);  // Original is for custom encode function.
}

/// For specs that value is set.
class ValueAttrEncoder<AV> extends Encoder<AV> {
  ValueAttrEncoder(this.value);

  final AV value;

  @override
  AV encode(Scaled scaled, Original original) => value;
}

/// For specs that encode is set.
class CustomEncoder<AV> extends Encoder<AV> {
  CustomEncoder(this.customEncode);

  final AV Function(Original) customEncode;

  @override
  AV encode(Scaled scaled, Original original)
    => customEncode(original);
}

// op

class AesOp extends Operator<List<Aes>> {
  AesOp(Map<String, dynamic> params) : super(params);

  @override
  List<Aes> evaluate() {
    final scaleds = params['scaleds'] as List<Scaled>; // From scaled collector operator.
    final originals = params['originals'] as List<Original>;  // From original collect operator.
    final positionEncoder = params['positionEncode'] as PositionEncoder; // From PostionOp.
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
      final original = originals[i];
      rst.add(Aes(
        position: positionEncoder.encode(scaled, original),
        shape: shapeEncoder.encode(scaled, original),
        color: colorEncoder?.encode(scaled, original),
        gradient: gradientEncoder?.encode(scaled, original),
        elevation: elevationEncoder?.encode(scaled, original),
        label: labelEncoder?.encode(scaled, original),
        size: sizeEncoder?.encode(scaled, original),
      ));
    }
    return rst;
  }
}
