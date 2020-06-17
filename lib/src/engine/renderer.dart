import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'container.dart';
import 'event/event_arena.dart';

class Painter extends CustomPainter {
  Painter(this.renderer);

  final Renderer renderer;

  @override
  void paint(Canvas canvas, Size size) {
    renderer.paint(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
    this != oldDelegate;
}

class Renderer extends Container {
  Renderer() : super(null);

  Painter _painter;

  EventArena _eventArena;

  void Function() _repaintTrigger;

  TickerProvider _tickerProvider;

  bool _mounted = false;

  Painter get painter => _painter;

  EventArena get eventArena => _eventArena;

  void Function() get repaintTrigger => _repaintTrigger;

  TickerProvider get tickerProvider => _tickerProvider;

  bool get mounted => _mounted;

  void mount(
    void Function() repaintTrigger,
    TickerProvider tickerProvider,
    EventArena eventArena,
  ) {
    _repaintTrigger = repaintTrigger;
    _tickerProvider = tickerProvider;
    _eventArena = eventArena;

    _painter = Painter(this);

    _mounted = true;
  }

  void repaint() {
    if (_mounted) {
      _painter = Painter(this);
      _repaintTrigger();
    }
  }
}
