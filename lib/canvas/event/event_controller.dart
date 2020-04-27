import 'dart:ui' show Offset;

import 'package:flutter/gestures.dart';

import '../renderer.dart' show Renderer;
import '../element.dart' show Element;
import '../shape/shape.dart' show Shape;
import '../container.dart' show Container;
import 'graph_event.dart' show
  EventType,
  GraphEvent,
  EventTag,
  OriginalEvent;

void emitTargetEvent(Element target, EventTag tag, GraphEvent graphEvent) {
  graphEvent.tag = tag;
  graphEvent.currentTarget = target;
  graphEvent.delegateTarget = target;
  target.emit(tag, graphEvent);
}

void bubbleEvent(Container container, EventTag tag, GraphEvent graphEvent) {
  if (graphEvent.bubbles) {
    graphEvent.tag = tag;
    graphEvent.currentTarget = container;
    graphEvent.delegateTarget = container;
    container.emit(tag, graphEvent);
  }
}

class EventController {
  EventController(Renderer renderer)
    : _renderer = renderer;

  Renderer _renderer;

  // drag = pan
  // longPressDrag = longPress

  // bool _isDragging = false;

  Shape _pickedShape;

  void init() {
    _bindEvents();
  }

  void _bindEvents() {
    final eventErena = _renderer.eventArena;
    eventErena.addEventListener(EventType.all, _eventCallback);
  }

  void _clearEvents() {
    final eventErena = _renderer.eventArena;
    eventErena.removeAllEventListener();
  }

  GraphEvent _getGraphEvent(
    EventTag tag,
    OriginalEvent event,
    Offset localPosition,
    Offset globalPosition,
    Element target,
    Shape fromShape,
    Shape toShape,
    Offset offset,
    ScaleUpdateDetails scale,
  ) {
    final graphEvent = GraphEvent(tag, event);
    graphEvent.fromShape = fromShape;
    graphEvent.toShape = toShape;
    graphEvent.localPosition = localPosition;
    graphEvent.globalPosition = globalPosition;
    graphEvent.propagationPath.add(target);
    graphEvent.offset = offset;
    graphEvent.scale = scale;

    return graphEvent;
  }

  void _eventCallback (OriginalEvent ev) {
    final type = ev.type;
    _triggerEvent(type, ev);
  }

  Shape _getShape(Offset point, OriginalEvent ev) {
    return _renderer.getShape(point, ev);
  }

  void _triggerEvent(EventType type, OriginalEvent ev) {
    final shape = _getShape(ev.pointerEvent.localPosition, ev);

    switch (type) {
      case EventType.tap:
      case EventType.tapDown:
      case EventType.tapUp:
      case EventType.tapCancel:
      case EventType.doubleTap:
      case EventType.panDown:
      case EventType.panCancel:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          shape,
          null,
          null,
          null,
          null,
        );
        break;
      case EventType.longPress:
      case EventType.longPressStart:
      case EventType.panStart:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          shape,
          shape,
          shape,
          null,
          null,
        );
        // _isDragging = true;
        _pickedShape = shape;
        break;
      case EventType.scaleStart:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          shape,
          null,
          null,
          null,
          null,
        );
        _pickedShape = shape;
        break;
      case EventType.longPressMoveUpdate:
      case EventType.panUpdate:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          _pickedShape,
          _pickedShape,
          shape,
          ev.offset,
          null,
        );
        break;
      case EventType.scaleUpdate:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          _pickedShape,
          null,
          null,
          null,
          ev.scale,
        );
        break;
      case EventType.longPressUp:
      case EventType.longPressEnd:
      case EventType.panEnd:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          _pickedShape,
          _pickedShape,
          shape,
          ev.offset,
          null,
        );
        // _isDragging = false;
        _pickedShape = null;
        break;
      case EventType.scaleEnd:
        _emitEvent(
          EventTag(type),
          ev,
          ev.pointerEvent.localPosition,
          ev.pointerEvent.position,
          _pickedShape,
          _pickedShape,
          shape,
          null,
          ev.scale,
        );
        _pickedShape = null;
        break;
      default:
    }
  }

  void _emitEvent(
    EventTag tag,
    OriginalEvent event,
    Offset localPosition,
    Offset globalPosition,
    Shape shape,
    Shape fromShape,
    Shape toShape,
    Offset offset,
    ScaleUpdateDetails scale,
  ) {
    final graphEvent = _getGraphEvent(
      tag,
      event,
      localPosition,
      globalPosition,
      shape,
      fromShape,
      toShape,
      offset,
      scale,
    );
    if (shape != null) {
      graphEvent.shape = shape;
      emitTargetEvent(shape, tag, graphEvent);
      var parent = shape.parent;
      while (parent != null) {
        parent.emitDelegation(tag.type, graphEvent);
        if (!graphEvent.propagationStopped) {
          bubbleEvent(parent, tag, graphEvent);
        }
        graphEvent.propagationPath.add(parent);
        parent = parent.parent;
      }
    } else {
      final renderer = this._renderer;
      emitTargetEvent(renderer, tag, graphEvent);
    }
  }

  void destroy() {
    _clearEvents();
    _renderer = null;
    // _isDragging = null;
    _pickedShape = null;
  }
}
