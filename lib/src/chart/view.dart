import 'dart:ui';

import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/interaction/gesture/arena.dart';
import 'package:graphic/src/interaction/gesture/gesture.dart';
import 'package:graphic/src/parse/spec.dart';

class View<D> extends Dataflow {
  View(Spec<D> spec) {
    arena.on((gesture) {
      gestureSource.emit(GestureEvent(gesture));
    });
  }

  final graffiti = Graffiti();

  final arena = GestureArena();

  final gestureSource = EventSource<GestureEvent>();

  final sizeSouce = EventSource<ResizeEvent>();

  final dataSouce = EventSource<ChangeDataEvent<D>>();

  void resize(Size size) =>
    sizeSouce.emit(ResizeEvent(size));

  void changeData(List<D> data) =>
    dataSouce.emit(ChangeDataEvent(data));
}
