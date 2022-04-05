import 'dart:ui';

import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/scale/scale.dart';

/// For each tuple:
/// Firstly compose points by algebra form.
/// Secondly convert values of points from scaled value to normal value.
/// Thirdly complete abstract position points by geom.
///
/// The position attribute encoder.
///
/// The process of encoding for each tuple is:
/// 1. Composes points by the algebracal form.
/// 2. Converts values of points from scaled value to normal value.
/// 3. Completes position points by geom.
class PositionEncoder extends Encoder<List<Offset>> {
  PositionEncoder(
    this.form,
    this.scales,
    this.completer,
    this.origin,
  );

  /// The algebracal form.
  final AlgForm form;

  /// The scale converters.
  final Map<String, ScaleConv> scales;

  /// The position points completer.
  ///
  /// It is determined by the geometory element type.
  final PositionCompleter completer;

  /// The origin point's position.
  final Offset origin;

  @override
  List<Offset> encode(Scaled scaled, Tuple tuple) {
    final position = <Offset>[];
    for (var term in form) {
      if (term.length == 1) {
        // For 1D coordinate, the point domain dimension is filled with an arbitry
        // 0, which will be replaced by dimFill in the coordinate converter and
        // the single term factor is for measure dimension.

        position.add(Offset(
          0,
          scales[term[0]]!.normalize(scaled[term[0]]!),
        ));
      } else {
        position.add(Offset(
          scales[term[0]]!.normalize(scaled[term[0]]!),
          scales[term[1]]!.normalize(scaled[term[1]]!),
        ));
      }
    }
    return completer(position, origin);
  }
}

/// The operator to create the position encoder.
class PositionOp extends Operator<PositionEncoder> {
  PositionOp(Map<String, dynamic> params) : super(params);

  @override
  PositionEncoder evaluate() {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final completer = params['completer'] as PositionCompleter;
    final origin = params['origin'] as Offset;

    /// Makes sure that scales in the same dim have same properties.
    assert(form.variablesByDim.every((dim) {
      final scale = scales[dim.first];
      for (var variable in dim) {
        if (scales[variable] != scale) {
          return false;
        }
      }
      return true;
    }));

    return PositionEncoder(
      form,
      scales,
      completer,
      origin,
    );
  }
}

/// The operator to get the origin point's position.
class OriginOp extends Operator<Offset> {
  OriginOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    if (coord.dimCount == 1) {
      final field = form.first[0];
      return Offset(
        coord.dimFill,
        scales[field]!.normalZero,
      );
    } else {
      final xField = form.first[0];
      final yField = form.first[1];
      return Offset(
        scales[xField]!.normalZero,
        scales[yField]!.normalZero,
      );
    }
  }
}
