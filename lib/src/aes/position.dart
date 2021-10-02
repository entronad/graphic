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
class PositionEncoder extends Encoder<List<Offset>> {
  PositionEncoder(
    this.form,
    this.scales,
    this.completer,
    this.origin,
  );

  final AlgForm form;

  final Map<String, ScaleConv> scales;

  final PositionCompleter completer;  // Defined by each geom.

  final Offset origin;

  @override
  List<Offset> encode(Scaled scaled, Original original) {
    final position = <Offset>[];
    for (var term in form) {
      if (term.length == 1) {  // For dim 1 coord.
        position.add(Offset(
          0,  // Fill the domain dim.
              // This is an arbitry value, and will be replaced by dimFill in coord converter.
          scales[term[0]]!.normalize(scaled[term[0]]!),  // The only factor is regarded as measure dim.
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

/// Position Encode needs a operator to create because it needs dynamic params form other operators.
class PositionOp extends Operator<PositionEncoder> {
  PositionOp(Map<String, dynamic> params) : super(params);

  @override
  PositionEncoder evaluate() {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final completer = params['completer'] as PositionCompleter;
    final origin = params['origin'] as Offset;

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

/// params:
/// - form: AlgForm
/// - scales: Map<String, ScaleConv>, Scale convertors.
/// 
/// value: Offset
/// The abstract origin point
class OriginOp extends Operator<Offset> {
  OriginOp(Map<String, dynamic> params) : super(params);

  @override
  Offset evaluate() {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final coord = params['coord'] as CoordConv;

    if (coord.dim == 1) {
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
