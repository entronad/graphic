import 'dart:ui';

import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/interaction/gesture/gesture.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

class View<D> extends Dataflow {
  View(
    Spec<D> spec,
    this.size,
    this.arena,
    this.repaint,
  )
    : graffiti = Graffiti(size)
  {
    arena
      ..clear()
      ..on((gesture) {
        gestureSource.emit(GestureEvent(gesture));
      });

    parse<D>(spec, this);

    graffiti.sort();

    run();
  }

  final Size size;

  final GestureArena arena;

  final void Function() repaint;

  final graffiti;

  final gestureSource = EventSource<GestureEvent>();

  final sizeSouce = EventSource<ResizeEvent>();

  final dataSouce = EventSource<ChangeDataEvent<D>>();

  bool dirty = false;

  void resize(Size size) =>
    sizeSouce.emit(ResizeEvent(size));

  void changeData(List<D> data) =>
    dataSouce.emit(ChangeDataEvent(data));

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
