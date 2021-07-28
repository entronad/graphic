import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:collection/collection.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/map.dart';

// Attr

/// An Attr can be determined by algebra/variable, value, or encode, but only one of them can be defined.
/// Attr can be updated by signal or selection.
abstract class Attr<AV> {
  Attr({
    this.value,
    this.encode,
    this.signal,
    this.select,
  });

  final AV? value;

  /// Encode original value tuple to aes value.
  final AV Function(Tuple)? encode;

  final Signal<AV>? signal;

  final Map<Select, SelectUpdate<AV>>? select;

  @override
  bool operator ==(Object other) =>
    other is Attr<AV> &&
    value == other.value &&
    signal == other.signal &&
    // encode: Function
    DeepCollectionEquality().equals(signal?.keys, other.signal?.keys) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(select?.keys, other.select?.keys);  // SignalUpdata: Function
}

abstract class AttrConv<SV extends num, AV> extends Converter<SV, AV> {
  @override
  SV invert(AV output) {
    throw UnimplementedError();
  }
}

/// For any attr specification that has value.
class ValueAttrConv<AV> extends AttrConv<num, AV> {
  ValueAttrConv(this.value);

  final AV value;

  @override
  AV convert(num input) => value;
}

// Aes

/// Used for shape painting methods.
/// Created by aes value tuple.
class Aes {
  Aes(Tuple tuple)
    : color = tuple['color'] as Color?,
      elevation = tuple['elevation'] as double?,
      gradient = tuple['gradient'] as Gradient?,
      label = tuple['label'] as Label?,
      position = tuple['position'] as List<Offset>,
      shape = tuple['shape'] as Shape,
      size = tuple['size'] as double
    {
      assert(isSingle([color, gradient]));
    }

  final Color? color;

  final double? elevation;

  final Gradient? gradient;

  final Label? label;

  /// Composed of normal value of each dim, result of the position operator.
  /// It can be converted to canvas position by coord in shape.
  final List<Offset> position;

  final Shape shape;

  /// If needed, default to shape's defaultSize.
  final double? size;
}

abstract class AesOp<AV> extends Transformer {
  AesOp(
    Map<String, dynamic> params,
    this.attr,
  ) : super(params);

  final String attr;

  @override
  Pulse? transform(Pulse pulse) {
    pulse.visit(PulseFlags.add, (tuple) {
      aes(tuple);
    });

    if (pulse.modFields.contains(attr)) {
      pulse.visit(PulseFlags.mod, (tuple) {
        aes(tuple);
      });
    }

    return pulse;
  }

  @protected
  void aes(Tuple tuple);
}

/// All attr can be aesed by an encode operator(except position).
///
/// params:
/// - attr: String, Aes value this operator handles.
/// - encode: AV Function(Tuple)
/// - scaledRelay: Map<Tuple, Tuple>, Relay from original value to scaled value.
/// - aesRelay: Map<Tuple, Tuple>, Relay from scaled value to aes value.
class EncodeOp<AV> extends AesOp<AV> {
  EncodeOp(
    Map<String, dynamic> params,
    String attr,
  ) : super(params, attr);

  @override
  void aes(Tuple tuple) {
    final encode = params['encode'] as AV Function(Tuple);
    final scaledRelay = params['scaledRelay'] as Map<Tuple, Tuple>;
    final aesRelay = params['aesRelay'] as Map<Tuple, Tuple>;

    final originalTuple = scaledRelay.keyOf(aesRelay.keyOf(tuple));
    tuple[attr] = encode(originalTuple);
  }
}
