import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';

V? _update<V>(
  V? value,
  bool? status,
  Map<bool, SelectionUpdate<V>>? updator,
) {
  if (status != null && value != null && updator != null) {
    final update = updator[status];
    if (update != null) {
      return update(value);
    }
  }
  return value;
}

/// It is still in the aes scope so share the same aeses instance.
class ElementSelectionOp extends Operator<List<Aes>> {
  ElementSelectionOp(Map<String, dynamic> params) : super(params);

  @override
  List<Aes> evaluate() {
    final aeses = params['aeses'] as List<Aes>;
    final statuses = params['statuses'] as Map<int, bool>;
    final shapeUpdater = params['shapeUpdater'] as Map<bool, SelectionUpdate<Shape>>?;
    final colorUpdater = params['colorUpdater'] as Map<bool, SelectionUpdate<Color>>?;
    final gradientUpdater = params['gradientUpdater'] as Map<bool, SelectionUpdate<Gradient>>?;
    final elevationUpdater = params['elevationUpdater'] as Map<bool, SelectionUpdate<double>>?;
    final labelUpdater = params['labelUpdater'] as Map<bool, SelectionUpdate<Label>>?;
    final sizeUpdater = params['sizeUpdater'] as Map<bool, SelectionUpdate<double>>?;

    if (
      shapeUpdater == null &&
      colorUpdater == null &&
      gradientUpdater == null &&
      elevationUpdater == null &&
      labelUpdater == null &&
      sizeUpdater == null
    ) {
      return [...aeses];
    }

    final rst = <Aes>[];
    for (var i = 0; i < aeses.length; i++) {
      final aes = aeses[i];
      final status = statuses[i];
      if (status != null) {
        rst[i] = Aes(
          position: [...aes.position],
          shape: _update(aes.shape, status, shapeUpdater)!,
          color: _update(aes.color, status, colorUpdater),
          gradient: _update(aes.gradient, status, gradientUpdater),
          elevation: _update(aes.elevation, status, elevationUpdater),
          label: _update(aes.label, status, labelUpdater),
          size: _update(aes.size, status, sizeUpdater),
        );
      } else {
        rst[i] = aes;
      }
    }
    return rst;
  }
}
