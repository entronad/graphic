import 'dart:ui';
import 'dart:math';

import 'cfg.dart';
import 'element.dart';
import 'shape.dart';
import 'group.dart';
import 'util/vector2.dart';

Comparator<Element> getComparer(Comparator<Element> compare) =>
  (left, right) {
    final result = compare(left, right);
    return result == 0 ? left.cfg.index - right.cfg.index : result;
  };

abstract class Container extends Element {
  Container(Cfg cfg) : super(cfg);

  List<Element> get children => cfg.children;

  @override
  void drawInner(Canvas canvas, Size size) {
    for (var child in children) {
      child.paint(canvas, size);
    }
  }

  @override
  Rect get bbox {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (var child in children) {
      if (child.cfg.visible) {
        final bbox = child.bbox;
        if (bbox == null) {
          continue;
        }

        final topLeft = Vector2.fromOffset(bbox.topLeft);
        final bottomLeft = Vector2.fromOffset(bbox.bottomLeft);
        final topRight = Vector2.fromOffset(bbox.topRight);
        final bottomRight = Vector2.fromOffset(bbox.bottomRight);
        final matrix = child.attrs.matrix;

        topLeft.transformMat2d(matrix);
        bottomLeft.transformMat2d(matrix);
        topRight.transformMat2d(matrix);
        bottomRight.transformMat2d(matrix);

        final candidatesX = [topLeft.x, bottomLeft.x, topRight.x, bottomRight.x, minX, maxX];
        final candidatesY = [topLeft.y, bottomLeft.y, topRight.y, bottomRight.y, minY, maxY];

        minX = candidatesX.reduce(min);
        maxX = candidatesX.reduce(max);
        minY = candidatesY.reduce(min);
        maxY = candidatesY.reduce(max);
      }
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Shape addShape(Cfg cfg) {
    final type = cfg.type;
    final creator = Shape.creators[type];
    final shape = creator(cfg);
    add(shape);
    return shape;
  }

  Group addGroup([Cfg cfg]) {
    cfg = cfg ?? Cfg();
    cfg.renderer = this.cfg.renderer;
    cfg.parent = this;
    final group = Group(cfg);
    add(group);
    return group;
  }

  bool contain(Element element) =>
    children.contains(element);

  void sort() {
    for (var i = 0; i < children.length; i++) {
      children[i].cfg.index = i;
    }

    children.sort(getComparer(
      (obj1, obj2) => obj1.cfg.zIndex - obj2.cfg.zIndex
    ));
  }

  void clear() {
    while (children.length != 0) {
      children[children.length - 1].remove(true);
    }
  }

  void add(Element element) {
    final parent = element.cfg.parent;
    if (parent != null) {
      final descendants = parent.cfg.children;
      descendants?.remove(element);
    }
    _setEvn(element);
    children.add(element);
  }

  void _setEvn(Element element) {
    element.cfg.parent = this;
    element.cfg.renderer = cfg.renderer;
    final clip = element.attrs.clip;
    if (clip != null) {
      clip.cfg.parent = this;
    }
    if (element.cfg.isGroup) {
      final children = element.cfg.children;
      for (var child in children) {
        (element as Group)._setEvn(child);
      }
    }
  }
}
