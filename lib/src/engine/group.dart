import 'dart:ui';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';

import 'element.dart';
import 'render_shape/base.dart';

int compareElementOrder(Element a, Element b) {
  var rst = a.props.zIndex - b.props.zIndex;
  if (rst == 0) {
    rst = a.props.siblingIndex - b.props.siblingIndex;
  }
  return rst;
}

class GroupProps extends ElementProps<ElementAttrs> {
  List<Element> get children => this['children'] as List<Element>;
  set children(List<Element> value) => this['children'] = value;
}

class Group extends Element<GroupProps, ElementAttrs> {
  Group([TypedMap cfg]) : super(cfg);

  @override
  GroupProps get originalProps => GroupProps();

  @override
  ElementAttrs get originalAttrs => ElementAttrs();

  @override
  void initDefaultProps() {
    super.initDefaultProps();
    props.children = [];
  }

  RenderShape addShape(RenderShapeAttrs attrs) {
    final shape = RenderShape.create(attrs);
    _add(shape);
    return shape;
  }

  Group addGroup() {
    final group = Group();
    _add(group);
    return group;
  }

  void _add(Element element) {
    element.props.parent = this;

    props.children.add(element);
  }

  void sort() {
    final children = props.children;
    for (var i = 0; i < children.length; i++) {
      children[i].props.siblingIndex = i;
    }

    children.sort(compareElementOrder);
  }

  void clear() {
    props.children.clear();
  }

  @override
  void draw(Canvas canvas) {
    for (var child in props.children) {
      child.paint(canvas);
    }
  }

  @override
  Rect get bbox {
    final children = props.children;
    if (children.isEmpty) {
      return null;
    }

    final matrix = attrs.matrix;
    final isTransfromed = matrix != Matrix4.identity();

    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    for (var child in children) {
      final childBBox = child.bbox;
      var topLeft = childBBox.topLeft;
      var topRight = childBBox.topRight;
      var bottomRight = childBBox.bottomRight;
      var bottomLeft = childBBox.bottomLeft;
      if (isTransfromed) {
        topLeft = MatrixUtils.transformPoint(matrix, childBBox.topLeft);
        topRight = MatrixUtils.transformPoint(matrix, childBBox.topRight);
        bottomRight = MatrixUtils.transformPoint(matrix, childBBox.bottomRight);
        bottomLeft = MatrixUtils.transformPoint(matrix, childBBox.bottomLeft);
      }
      final candidatesX = [topLeft.dx, bottomLeft.dx, topRight.dx, bottomRight.dx, minX, maxX];
      final candidatesY = [topLeft.dy, bottomLeft.dy, topRight.dy, bottomRight.dy, minY, maxY];

      minX = candidatesX.reduce(min);
      maxX = candidatesX.reduce(max);
      minY = candidatesY.reduce(min);
      maxY = candidatesY.reduce(max);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}