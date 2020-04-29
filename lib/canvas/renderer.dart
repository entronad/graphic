import 'dart:ui' show Size;
import 'dart:ui' as ui show Canvas;

import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:flutter/scheduler.dart' show TickerProvider;

import './event/event_arena.dart' show EventArena;
import './event/event_controller.dart' show EventController;
import 'container.dart' show Container;
import 'cfg.dart' show Cfg;
import './animate/timeline.dart' show Timeline;
import 'element.dart' show ChangeType, AnimationParam;
import './shape/shape.dart' show ShapeBase, ShapeType, Shape;
import 'base.dart' show Ctor;
import 'group.dart' show Group;
import './util/paint.dart' show paintChildren;
import 'canvas.dart' show CanvasState;

class Painter extends CustomPainter {
  Painter(this.renderer);

  final Renderer renderer;

  @override
  void paint(ui.Canvas canvas, Size size) {
    renderer.paint(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
    this != oldDelegate;
}

class Renderer extends Container {
  Renderer()
    : _eventArena = EventArena(),
      super(null)
  {
    _painter = Painter(this);
    initEvents();
    initTimline();
  }

  Painter _painter;

  final EventArena _eventArena;

  void Function() _repaintTrigger;

  TickerProvider _tickerProvider;

  bool _isInflated = false;

  Painter get painter => _painter;

  EventArena get eventArena => _eventArena;

  void Function() get repaintTrigger => _repaintTrigger;

  TickerProvider get tickerProvider => _tickerProvider;

  bool get isInflated => _isInflated;

  final List<AnimationParam> reservedAnimations = [];

  void inflate(CanvasState state) {
    _repaintTrigger = state.update;
    _tickerProvider = state;
    _isInflated = true;

    for (var param in reservedAnimations) {
      param.element.animate(
        toAttrs: param.toAttrs,
        onFrame: param.onFrame,
        animationCfg: param.animationCfg,
      );
    }
  }

  void deflate() {
    _repaintTrigger = null;
    _tickerProvider = null;
    _isInflated = false;

    destroy();
  }

  void repaint() {
    _painter = Painter(this);
    if (isInflated) {
      repaintTrigger();
    }
  }

  @override
  void paint(ui.Canvas canvas, Size size) {
    final children = cfg.children;
    paintChildren(canvas, children, size);
  }

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..autoDraw = true
    ..quickHit = false;

  void initEvents() {
    final eventController = EventController(this);
    eventController.init();
    cfg.eventController = eventController;
  }

  void initTimline() {
    final timeline = Timeline(this);
    cfg.timeline = timeline;
  }

  @override
  bool get isRenderer => true;

  @override
  Container get parent => null;

  @override
  void destroy() {
    final eventController = cfg.eventController;
    eventController.destroy();

    final timeline = cfg.timeline;
    if (cfg.destroyed) {
      return;
    }
    clear();
    if (timeline != null) {
      timeline.stop();
    }
    super.destroy();
  }

  @override
  void onRendererChange(ChangeType changeType) {
    if (
      changeType == ChangeType.attr ||
      changeType == ChangeType.sort ||
      changeType == ChangeType.changeSize
    ) {
      repaint();
    }
  }

  @override
  Map<ShapeType, Ctor<Shape>> get shapeBase => ShapeBase;

  @override
  Ctor<Group> get groupBase => (Cfg cfg) => Group(cfg);

  @override
  void clear() {
    super.clear();
    repaint();
  }

  @override
  void skipDraw() {
  }

  @override
  Renderer clone() => Renderer()..cfg = this.cfg.clone();
}
