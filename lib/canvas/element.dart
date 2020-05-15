import 'dart:ui' show Rect, Offset, Canvas, Size;

import 'package:flutter/widgets.dart' show UniqueKey;
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector4;

import 'attrs.dart' show Attrs;
import 'cfg.dart' show Cfg;
import 'base.dart' show Base, Ctor;
import 'group.dart' show Group;
import 'container.dart' show Container;
import './shape/shape.dart' show ShapeType, Shape;
import 'renderer.dart' show Renderer;
import './event/graph_event.dart' show EventType, EventTag, GraphEvent;
import './animate/animation.dart' show AnimationCfg, Animation;

List<Animation> checkExistedAttrs(List<Animation> animations, Animation animation) {
  if (animation.onFrame != null) {
    return animations;
  }
  final startTime = animation.startTime;
  final delay = animation.delay;
  final duration = animation.duration;
  for (var item in animations) {
    if (
      startTime + delay < item.startTime + item.delay + item.duration
      && duration > item.delay
    ) {
      for (var k in animation.toAttrs.keys) {
        item.toAttrs[k] = null;
        item.fromAttrs[k] = null;
      }
    }
  }

  return animations;
}

enum ChangeType {
  changeSize,
  add,
  sort,
  clear,
  attr,
  show,
  hide,
  zIndex,
  remove,
  matrix,
  clip,
}

class Pause {
  Pause(this.isPaused, [this.pauseTime]);

  final bool isPaused;
  final Duration pauseTime;
}

class AnimationParam {
  AnimationParam(this.element, this.toAttrs, this.onFrame, this.animationCfg);

  final Element element;
  final Attrs toAttrs;
  final Attrs Function(double) onFrame;
  final AnimationCfg animationCfg;
}

abstract class Element extends Base {
  Element(Cfg cfg)
    : super(cfg) 
  {
    final attrs = defaultAttrs;
    attrs.mix(cfg?.attrs);
    this.attrs = attrs;
    this.initAttrs(attrs);
    this.initAnimate();
  }

  // Index as child, used for sorting comparison.
  int index;

  Attrs attrs;

  // for hack usage of refreshElement
  Rect cacheCanvasBBox;

  @override
  Cfg get defaultCfg => Cfg(
    visible: true,
    capture: true,
    zIndex: 0,
  );

  Attrs get defaultAttrs => Attrs(
    matrix: defaultMatrix,
  );

  Map<ShapeType, Ctor<Shape>> get shapeBase;

  Ctor<Group> get groupBase;

  void onRendererChange(ChangeType changeType);

  void initAttrs(Attrs attrs) {}

  void initAnimate() {
    cfg.animable = true;
    cfg.animating = false;
  }

  bool get isGroup => false;

  bool get isRenderer => false;

  Container get parent => cfg.parent;

  Renderer get renderer => cfg.renderer;

  Element attr(Attrs attrs) {
    for (var k in attrs.keys) {
      setAttr(k, attrs[k]);
    }
    afterAttrsChange(attrs);
    return this;
  }

  Rect get bbox;

  Rect get canvasBBox;

  bool isClipped(Offset refPoint) {
    final clip = this.clip;
    return (clip != null) && !clip.isHit(refPoint);
  }

  void setAttr(String name, Object value) {
    final originValue = attrs[name];
    if (originValue != value) {
      attrs[name] = value;
      onAttrChange(name, value, originValue);
    }
  }

  void onAttrChange(String name, Object value, Object originValue) {
    if (name == 'matrix') {
      cfg.totalMatrix = null;
    }
  }

  void afterAttrsChange(Attrs targetAttrs) {
    onRendererChange(ChangeType.attr);
  }

  Element show() {
    cfg.visible = true;
    onRendererChange(ChangeType.show);
    return this;
  }

  Element hide() {
    cfg.visible = false;
    onRendererChange(ChangeType.hide);
    return this;
  }

  Element setZIndex(int zIndex) {
    cfg.zIndex = zIndex;
    final parent = this.parent;
    if (parent != null) {
      parent.sort();
    }
    return this;
  }

  void toFront() {
    final parent = this.parent;
    if (parent == null) {
      return;
    }
    final children = parent.children;
    children.remove(this);
    children.add(this);
    onRendererChange(ChangeType.zIndex);
  }

  void toBack() {
    final parent = this.parent;
    if (parent == null) {
      return;
    }
    final children = parent.children;
    children.remove(this);
    children.insert(0, this);
    onRendererChange(ChangeType.zIndex);
  }

  void remove([bool destroy = true]) {
    final parent = this.parent;
    if (parent != null) {
      parent.children.remove(this);
      if (!parent.cfg.clearing) {
        onRendererChange(ChangeType.remove);
      }
    } else {
      onRendererChange(ChangeType.remove);
    }
    if (destroy) {
      this.destroy();
    }
  }

  void resetMatrix() {
    attr(Attrs(matrix: defaultMatrix));
    onRendererChange(ChangeType.matrix);
  }

  Matrix4 get matrix => attrs.matrix;

  void setMatrix(Matrix4 m) {
    attr(Attrs(matrix: m));
    onRendererChange(ChangeType.matrix);
  }

  Matrix4 get totalMatrix {
    var totalMatrix = cfg.totalMatrix;
    if (totalMatrix == null) {
      final currentMatrix = attrs.matrix;
      final parentMatrix = cfg.parentMatrix;
      if (parentMatrix != null && currentMatrix != null) {
        totalMatrix = parentMatrix * currentMatrix;
      } else {
        totalMatrix = currentMatrix ?? parentMatrix;
      }
      cfg.totalMatrix = totalMatrix;
    }
    return totalMatrix;
  }

  void applyMatrix(Matrix4 matrix) {
    final currentMatrix = attrs.matrix;
    var totalMatrix;
    if (matrix != null && currentMatrix != null) {
      totalMatrix = matrix * currentMatrix;
    } else {
      totalMatrix = currentMatrix ?? matrix;
    }
    cfg.totalMatrix = totalMatrix;
    cfg.parentMatrix = matrix;
  }

  Matrix4 get defaultMatrix => Matrix4.identity();

  Vector4 applyToMatrix(Vector4 v) {
    final matrix = attrs.matrix;
    if (matrix != null) {
      return matrix * v;
    }
    return v;
  }

  Vector4 invertFromMatrix(Vector4 v) {
    final matrix = attrs.matrix;
    if (matrix != null) {
      final invertMatrix = Matrix4.tryInvert(matrix);
      if (invertMatrix != null) {
        return invertMatrix * v;
      }
    }
    return v;
  }

  Shape setClip(Cfg clipCfg) {
    final renderer = this.renderer;
    Shape clipShape;
    if (clipCfg != null) {
      final shapeBase = this.shapeBase;
      final shapeType = clipCfg.type;
      final cons = shapeBase[shapeType];
      if (cons != null) {
        clipShape = cons(Cfg(
          type: clipCfg.type,
          isClipShape: true,
          attrs: clipCfg.attrs,
          renderer: renderer,
        ));
      }
    }
    cfg.clipShape = clipShape;
    onRendererChange(ChangeType.clip);
    return clipShape;
  }

  Shape get clip => cfg.clipShape;

  Element clone();

  void destroy() {
    if (destroyed) {
      return;
    }
    attrs = Attrs();
    super.destroy();
  }

  bool isAnimatePaused() => cfg.pause.isPaused;

  void animate({
    Attrs toAttrs,
    Attrs Function(double) onFrame,
    AnimationCfg animationCfg,
  }) {
    if (!cfg.renderer.isInflated) {
      cfg.renderer.reservedAnimations.add(AnimationParam(
        this,
        toAttrs,
        onFrame,
        animationCfg,
      ));
      return;
    }

    cfg.animating = true;
    var timeline = cfg.timeline;
    if (timeline == null) {
      timeline = cfg.renderer.cfg.timeline;
      cfg.timeline = timeline;
    }
    var animations = cfg.animations ?? [];
    if (timeline.ticker == null) {
      timeline.initTicker();
    }
    final animation = Animation(
      cfg: animationCfg,
      id: UniqueKey(),
      fromAttrs: attrs.clone(),
      toAttrs: toAttrs,
      startTime: timeline.time,
      pathFormatted: false,
      onFrame: onFrame,
      paused: false,
      pauseTime: null,
    );
    if (animations.isNotEmpty) {
      animations = checkExistedAttrs(animations, animation);
    } else {
      timeline.addAnimator(this);
    }
    animations.add(animation);
    cfg.animations = animations;
    cfg.pause = Pause(false);
  }

  void stopAnimate([bool toEnd = true]) {
    assert(cfg.renderer.isInflated);

    final animations = cfg.animations;
    for (var animation in animations) {
      if (toEnd) {
        if (animation.onFrame != null) {
          attr(animation.onFrame(1));
        } else {
          attr(animation.toAttrs);
        }
      }
      if (animation.onFinish != null) {
        animation.onFinish();
      }
    }
    cfg.animating = true;
    cfg.animations = [];
  }

  Element pauseAnimate() {
    assert(cfg.renderer.isInflated);

    final timeline = cfg.timeline;
    final animations = cfg.animations;
    final pauseTime = timeline.time;
    for (var animation in animations) {
      animation.paused = true;
      animation.pauseTime = pauseTime;
      if (animation.onPause != null) {
        animation.onPause();
      }
    }
    cfg.pause = Pause(true, pauseTime);
    return this;
  }

  Element resumeAnimate() {
    assert(cfg.renderer.isInflated);

    final timeline = cfg.timeline;
    final current = timeline.time;
    final animations = cfg.animations;
    final pauseTime = cfg.pause.pauseTime;
    for (var animation in animations) {
      animation.startTime = animation.startTime + (current - pauseTime);
      animation.paused = false;
      animation.pauseTime = null;
      if (animation.onResume != null) {
        animation.onResume();
      }
    }
    cfg.pause = Pause(false);
    cfg.animations = animations;
    return this;
  }

  void emitDelegation(EventType type, GraphEvent eventObj) {
    final paths = eventObj.propagationPath;
    for (var element in paths) {
      final name = element.cfg.name;
      if (name != null) {
        _emitDelegationEvent(element, name, eventObj);
      }
    }
  }

  void _emitDelegationEvent(Element element, String name, GraphEvent eventObj) {
    final events = this.events;
    final eventTag = EventTag(eventObj.tag.type, name);
    if (events[eventTag] != null || events[EventTag.all] != null) {
      eventObj.tag = eventTag;
      eventObj.currentTarget = element;
      eventObj.delegateTarget = this;
      eventObj.delegateObject = element.cfg.delegateObject;
      emit(eventTag, eventObj);
    }
  }

  Element translate(double dx, double dy) {
    final matrix = this.matrix ?? Matrix4.identity();
    matrix.leftTranslate(dx, dy);
    setMatrix(matrix);
    return this;
  }

  Element moveTo(Offset target) {
    final x = attrs.x ?? 0.0;
    final y = attrs.y ?? 0.0;
    translate(target.dx - x, target.dy - y);
    return this;
  }

  Element scale(double sx, [double sy]) {
    final matrix = this.matrix ?? Matrix4.identity();
    matrix.multiply(Matrix4.identity()..scale(sx, sy));
    setMatrix(matrix);
    return this;
  }

  Element rotate(double radians) {
    final matrix = this.matrix ?? Matrix4.identity();
    matrix.rotateZ(radians);
    setMatrix(matrix);
    return this;
  }

  Element rotateAtStart(double radians) {
    final startPoint = Offset(attrs.x ?? 0.0, attrs.y ?? 0.0);
    return rotateAtPoint(startPoint, radians);
  }

  Element rotateAtPoint(Offset point, double radians) {
    final matrix = this.matrix ?? Matrix4.identity();
    matrix
      ..translate(-point.dx, -point.dy)
      ..rotateZ(radians)
      ..translate(point.dx, point.dy);
    setMatrix(matrix);
    return this;
  }

  void paint(Canvas canvas, Size size);

  void skipPaint();
}
