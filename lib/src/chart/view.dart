import 'dart:ui';

import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/parse/parse.dart';

import 'chart.dart';
import 'size.dart';

class View<D> extends Dataflow {
  View(
    Chart<D> spec,
    this.size,
    this.repaint,
  ) : graffiti = Graffiti(size) {
    parse<D>(spec, this);

    graffiti.sort();

    run();
  }

  final Size size;

  final void Function() repaint;

  final graffiti;

  final gestureSource = SignalSource<GestureSignal>();

  final sizeSouce = SignalSource<ResizeSignal>();

  final dataSouce = SignalSource<ChangeDataSignal<D>>();

  bool dirty = false;

  Future<void> gesture(Gesture gesture) async {
    await gestureSource.emit(GestureSignal(gesture));
  }

  Future<void> resize(Size size) async {
    await sizeSouce.emit(ResizeSignal(size));
  }

  Future<void> changeData(List<D> data) async {
    await dataSouce.emit(ChangeDataSignal(data));
  }

  @override
  Future<Dataflow> evaluate() async {
    await super.evaluate();

    if (dirty) {
      graffiti.sort();
      repaint();
      dirty = false;
    }

    return this;
  }
}
