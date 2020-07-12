import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'group.dart';

abstract class ElementState with TypedMap {
  Path get clip => this['clip'] as Path;
  set clip(Path value) => this['clip'] = value;

  Matrix4 get matrix => this['matrix'] as Matrix4;
  set matrix(Matrix4 value) => this['matrix'] = value;

  int get zIndex => this['zIndex'] as int;
  set zIndex(int value) => this['zIndex'] = value;

  bool get visible => this['visible'] as bool ?? false;
  set visible(bool value) => this['visible'] = value;

  Group get parent => this['parent'] as Group;
  set parent(Group value) => this['parent'] = value;
}

abstract class Element<S extends ElementState> extends Component<S> {
  Element([TypedMap props]) : super(props);
  
  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..zIndex = 0
      ..visible = true;
  }

  Rect get bbox;

  void paint(Canvas canvas) {
    if (!state.visible) {
      return;
    }

    _setCanvas(canvas);
    draw(canvas);
    _restoreCanvas(canvas);
  }

  void _setCanvas(Canvas canvas) {
    canvas.save();

    final matrix = state.matrix;
    if (matrix != Matrix4.identity()) {
      canvas.transform(matrix.storage);
    }

    final clip = state.clip;
    if (clip != null) {
      canvas.clipPath(clip);
    }
  }

  @protected
  void draw(Canvas canvas);

  void _restoreCanvas(Canvas canvas) {
    canvas.restore();
  }

  void remove() {
    final siblings = state.parent?.state?.children;
    if (siblings != null) {
      siblings.remove(this);
    }
  }

  void transform(Matrix4 matrix) {
    if (matrix == null || matrix == Matrix4.identity()) {
      return;
    }
    state.matrix.multiply(matrix);

    onUpdate();
  }

  void translate({double x = 0, double y = 0}) {
    x ??= 0;
    y ??= 0;

    if (x == 0 && y == 0) {
      return;
    }
    state.matrix.leftTranslate(x, y);

    onUpdate();
  }

  void scale({double x = 1, double y = 1, Offset origin}) {
    x ??= 1;
    y ??= 1;

    if (x == 1 && y == 1) {
      return;
    }
    if ((origin == null) || (origin.dx == 0.0 && origin.dy == 0.0)) {
      state.matrix.multiply(Matrix4.identity()..scale(x, y));
      return;
    }
    state.matrix
      ..translate(origin.dx, origin.dy)
      ..multiply(Matrix4.identity()..scale(x, y))
      ..translate(-origin.dx, -origin.dy);

    onUpdate();
  }

  void rotate(double angleRadians, {Offset origin}) {
    if (angleRadians == null || angleRadians == 0) {
      return;
    }
    if ((origin == null) || (origin.dx == 0.0 && origin.dy == 0.0)) {
      state.matrix.rotateZ(angleRadians);
      return;
    }
    state.matrix
      ..translate(origin.dx, origin.dy)
      ..multiply(Matrix4.rotationZ(angleRadians))
      ..translate(-origin.dx, -origin.dy);

    onUpdate();
  }
}
