import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/dataflow.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/parse/parse.dart';

import 'chart.dart';
import 'size.dart';

/// The dataflow graph of a chart.
class ChartView<D> extends Dataflow {
  ChartView(
    Chart<D> spec,
    Size size,
    TickerProvider tickerProvider,
    void Function() repaint,
  ) : graffiti = Graffiti(tickerProvider: tickerProvider, repaint: repaint) {
    // The view won't hold the size, only to init the size operator.
    parse<D>(spec, this, size);

    graffiti.sort();

    // Initialization.
    run(init: true);
  }

  /// The rendering engine.
  final Graffiti graffiti;

  /// Whether to trigger a [repaint] after evaluation.
  ///
  /// The view is dirty when any [Render] operater has rendered.
  bool dirty = false;

  /// The gesture event stream.
  ///
  /// This is generated in [parse] and hold by [ChartView] for internal interactions.
  late StreamController<GestureEvent> gestureStream;

  /// The resize event stream.
  ///
  /// This is generated in [parse] and hold by [ChartView] for internal interactions.
  late StreamController<ResizeEvent> resizeStream;

  /// The changeData event stream.
  ///
  /// This is generated in [parse] and hold by [ChartView] for internal interactions.
  late StreamController<ChangeDataEvent<D>> changeDataStream;

  /// Emits a gesture event.
  Future<void> gesture(Gesture gesture) async {
    await Future(() {
      gestureStream.sink.add(GestureEvent(gesture));
    });
  }

  /// Emits a resize event.
  Future<void> resize(Size size) async {
    await Future(() {
      resizeStream.sink.add(ResizeEvent(size));
    });
  }

  /// Emits a change data event.
  Future<void> changeData(List<D> data) async {
    await Future(() {
      changeDataStream.sink.add(ChangeDataEvent<D>(data));
    });
  }

  @override
  Future<Dataflow> init() async {
    await super.init();

    // There always needs painting after initialization.
    graffiti.update();
    dirty = false;

    return this;
  }

  @override
  Future<Dataflow> evaluate() async {
    await super.evaluate();

    if (dirty) {
      graffiti.update();
      dirty = false;
    }

    return this;
  }

  @override
  void dispose() {
    graffiti.dispose();
    super.dispose();
  }
}
