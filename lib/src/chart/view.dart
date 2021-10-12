import 'dart:ui';

import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

class View<D> extends Dataflow {
  View(
    Spec<D> spec,
    this.size,
    this.repaint,
  )
    : graffiti = Graffiti(size)
  {
    parse<D>(spec, this);

    graffiti.sort();

    run();
  }

  final Size size;

  final void Function() repaint;

  final graffiti;

  final gestureSource = EventSource<GestureEvent>();

  final sizeSouce = EventSource<ResizeEvent>();

  final dataSouce = EventSource<ChangeDataEvent<D>>();

  bool dirty = false;

  Future<void> gesture(Gesture gesture) async {
    await gestureSource.emit(GestureEvent(gesture));
  }

  Future<void> resize(Size size) async {
    await sizeSouce.emit(ResizeEvent(size));
  }

  Future<void> changeData(List<D> data) async {
    await dataSouce.emit(ChangeDataEvent(data));
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
