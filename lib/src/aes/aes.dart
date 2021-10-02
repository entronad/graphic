import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/graphic.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'channel.dart';
import 'color.dart';
import 'elevation.dart';
import 'gradient.dart';
import 'shape.dart';
import 'size.dart';

// Attr

/// An Attr can be determined by algebra/variable, value, or encode, but only one of them can be defined.
/// Attr can be updated by signal or selection.
abstract class Attr<AV> {
  Attr({
    this.value,
    this.encode,
    this.onSelect,
  });

  AV? value;

  /// Encode original value tuple to aes value.
  AV Function(Original)? encode;

  Map<String, Map<bool, SelectUpdate<AV>>>? onSelect;

  @override
  bool operator ==(Object other) =>
    other is Attr<AV> &&
    value == other.value;
    // encode: Function
    // onSelect: Function
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
    final positionEncoder = params['positionEncoder'] as PositionEncoder; // From PostionOp.
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
        index: i,
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

void parseAes(
  Spec spec,
  View view,
  Scope scope,
) {
  for (var elementSpec in spec.elements) {
    var form = elementSpec.position?.form;
    // Default position.
    if (form == null) {
      final variables = scope.scaleSpecs.keys.toList();
      form = (Varset(variables[0]) * Varset(variables[1])).form;
    }
    scope.forms.add(form); // For geom usage.

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
      'originals': scope.originals,
      'positionEncoder': position,
      'shapeEncoder': getChannelEncoder<Shape>(
        elementSpec.shape ?? ShapeAttr(value: getDefaultShape(elementSpec)),
        scope.scaleSpecs,
        null,
      ),
      'colorEncoder': elementSpec.gradient == null  // If gradient is null color will have defult value.
        ? getChannelEncoder<Color>(
            elementSpec.color ?? ColorAttr(value: Color(0xff1890ff)),
            scope.scaleSpecs,
            (List<Color> values, List<double> stops) => ContinuousColorConv(values, stops),
          )
        : null,
      'gradientEncoder': elementSpec.gradient == null
        ? null
        : getChannelEncoder<Gradient>(
            elementSpec.gradient!,
            scope.scaleSpecs,
            (List<Gradient> values, List<double> stops) => ContinuousGradientConv(values, stops),
          ),
      'elevationEncoder': elementSpec.elevation == null
        ? null
        : getChannelEncoder<double>(
            elementSpec.elevation!,
            scope.scaleSpecs,
            (List<double> values, List<double> stops) => ContinuousElevationConv(values, stops),
          ),
      'labelEncoder': elementSpec.label == null
        ? null
        : CustomEncoder<Label>(elementSpec.label!.encode!),
      'sizeEncoder': elementSpec.size == null
        ? null
        : getChannelEncoder<double>(
            elementSpec.size!,
            scope.scaleSpecs,
            (List<double> values, List<double> stops) => ContinuousSizeConv(values, stops),
          ),
    })));
  }
}
