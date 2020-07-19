import 'dart:ui';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'node.dart';
import 'render_shape/base.dart';

class GroupState extends NodeState {
  List<Node> get children => this['children'] as List<Node>;
  set children(List<Node> value) => this['children'] = value;
}

class Group extends Node<GroupState> {
  Group([TypedMap props]) : super(props);

  @override
  GroupState get originalState => GroupState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..children = [];
  }

  RenderShape addShape(Props<RenderShapeType> props) {
    final shape = RenderShape.create(props);
    _add(shape);
    return shape;
  }

  Group addGroup() {
    final group = Group();
    _add(group);
    return group;
  }

  void _add(Node element) {
    element.state.parent = this;

    state.children.add(element);
    _onAdd();
  }

  void _onAdd() {
    _sort();
  }

  void _sort() {
    final children = state.children;

    final siblingOrders = <Node, int>{};
    for (var i = 0; i < children.length; i++) {
      siblingOrders[children[i]] = i;
    }

    children.sort((a, b) {
      var rst = a.state.zIndex - b.state.zIndex;
      if (rst == 0) {
        rst = siblingOrders[a] - siblingOrders[b];
      }
      return rst;
    });
  }

  void clear() {
    state.children.clear();
  }

  @override
  void draw(Canvas canvas) {
    for (var child in state.children) {
      child.paint(canvas);
    }
  }

  // The child's bbox changing is unknow,
  // so the calculation has to be jit. 
  @override
  Rect get bbox {
    final children = state.children;
    if (children.isEmpty) {
      return null;
    }

    final matrix = state.matrix;
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
