import 'dart:ui';

import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/util/map.dart';

typedef PositionCompleter = List<Offset> Function(List<Offset> position, Offset origin);

/// For each tuple:
/// Firstly compose points by algebra form.
/// Secondly convert values of points from scaled value to normal value.
/// Thirdly complete position points by geom.
/// 
/// params:
/// - form: AlgForm
/// - scales: Map<String, ScaleConv>, Scale convertors.
/// - aesRelay: Map<Tuple, Tuple>, Relay from scaled value to aes value.
/// - completer: PositonCompleter, Defined by each geom.
/// - origin: Offset, The normal origin point.
/// 
/// pulse:
/// The position field output is normal points.
class PositionOp extends AesOp<List<Offset>> {
  PositionOp(
    Map<String, dynamic> params,
  ) : super(params, 'position');

  @override
  void aes(Tuple tuple) {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final aesRelay = params['aesRelay'] as Map<Tuple, Tuple>;
    final completer = params['completer'] as PositionCompleter;
    final origin = params['origin'] as Offset;

    final scaledTuple = aesRelay.keyOf(tuple);
    final position = <Offset>[];
    for (var term in form) {
      if (term.length == 1) {  // For dim 1 coord.
        position.add(Offset(
          scales[term[0]]!.normalize(scaledTuple[term[0]]),
          0,  // This is an arbitry value, and will be replaced by dimFill in coord converter.
        ));
      } else {
        position.add(Offset(
          scales[term[0]]!.normalize(scaledTuple[term[0]]),
          scales[term[1]]!.normalize(scaledTuple[term[1]]),
        ));
      }
    }
    
    tuple['position'] = completer(position, origin);
  }
}

/// params:
/// - form: AlgForm
/// - scales: Map<String, ScaleConv>, Scale convertors.
/// 
/// value: Offset
/// The normal origin point
class OriginOp extends Updater<Offset> {
  OriginOp(Map<String, dynamic> params) : super(params);

  @override
  Offset update(Pulse pulse) {
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;

    final xField = form.first[0];
    final yField = form.first[1];
    return Offset(
      scales[xField]!.normalZero,
      scales[yField]!.normalZero,
    );
  }
}
