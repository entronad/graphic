import 'dart:ui' show Size;
import 'dart:ui' as ui show Canvas;

import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:graphic/canvas/element.dart';

import './event/event_arena.dart' show EventArena;
import './event/event_controller.dart' show EventController;
import 'container.dart' show Container;
import 'cfg.dart' show Cfg;
import './animate/timeline.dart' show Timeline;
import 'element.dart' show ChangeType;
import './shape/shape.dart' show ShapeBase, ShapeType, Shape;
import 'base.dart' show Ctor;
import 'group.dart' show Group;
import './util/paint.dart' show paintChildren;

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

  // unconfigurable
  Painter _painter;

  // unconfigurable
  final EventArena _eventArena;

  Painter get painter => _painter;

  EventArena get eventArena => _eventArena;

  void repaint() {
    _painter = Painter(this);
    final repaintTrigger = cfg.repaintTrigger;
    if (repaintTrigger != null) {
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
