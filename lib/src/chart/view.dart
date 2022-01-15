import 'dart:ui';

import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/parse/parse.dart';

import 'chart.dart';
import 'size.dart';

/// The dataflow graph of a chart.
class View<D> extends Dataflow {
  View(
    Chart<D> spec,
    Size size,
    this.repaint,
  ) : graffiti = Graffiti(size) {
    parse<D>(spec, this);

    graffiti.sort();

    run();
  }

  /// Asks the chart state to trigger a repaint.
  final void Function() repaint;

  /// The rendering engine.
  final Graffiti graffiti;

  /// The gesture signal source.
  final gestureSource = SignalSource<GestureSignal>();

  /// The resize signal source.
  final sizeSouce = SignalSource<ResizeSignal>();

  /// The change data signal source.
  final dataSouce = SignalSource<ChangeDataSignal<D>>();

  /// Whether to trigger a [repaint] after evaluation.
  ///
  /// The view is dirty when any [Render] operater has rendered.
  bool dirty = false;

  /// Select operators of this dataflow.
  /// 
  /// This is for [emitSelection].
  final List<SelectOp> selectOps = [];

  /// onSelections of this dataflow.
  /// 
  /// This is for [emitSelection].
  final List<void Function(Map<String, Set<int>>)?> onSelections = [];

  /// Emits a gesture signal.
  Future<void> gesture(Gesture gesture) async {
    await gestureSource.emit(GestureSignal(gesture));
  }

  /// Emits a resize signal.
  Future<void> resize(Size size) async {
    // Only the graffiti and the sizeOp hold the size.
    graffiti.size = size;
    await sizeSouce.emit(ResizeSignal(size));
  }

  /// Emits a change data signal.
  Future<void> changeData(List<D> data) async {
    await dataSouce.emit(ChangeDataSignal(data));
  }

  /// Emits a selection.
  void emitSelection(List<Map<String, Set<int>>?> selected) {
    assert(selected.length <= selectOps.length);
    for (var i = 0; i < selected.length; i++) {
      final selects = selected[i];
      if (selects != null) {
        final selectOp = selectOps[i];
        update(selectOp, selects);
        final onSelection = onSelections[i];
        if (onSelection != null) {
          onSelection(selects);
        }
      }
    }
    run();
  }

  @override
  Future<Dataflow> evaluate() async {
    await super.evaluate();

    if (dirty) {
      repaint();
      dirty = false;
    }

    return this;
  }
}
