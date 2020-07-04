import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/component.dart';

import 'group.dart';

// Also used by instantiable subclass Group, so not abstract.
class ElementAttrs with TypedMap {
  Path get clip => this['clip'] as Path;
  set clip(Path value) => this['clip'] = value;

  Matrix4 get matrix => this['matrix'] as Matrix4;
  set matrix(Matrix4 value) => this['matrix'] = value;
}

abstract class ElementProps<A extends ElementAttrs> with TypedMap {
  A get attrs => this['attrs'] as A;
  set attrs(A value) => this['attrs'] = value;

  int get zIndex => this['zIndex'] as int;
  set zIndex(int value) => this['zIndex'] = value;

  int get siblingIndex => this['siblingIndex'] as int;
  set siblingIndex(int value) => this['siblingIndex'] = value;

  bool get visible => this['visible'] as bool ?? false;
  set visible(bool value) => this['visible'] = value;

  Group get parent => this['parent'] as Group;
  set parent(Group value) => this['parent'] = value;
}

abstract class Element<P extends ElementProps, A extends ElementAttrs> extends Component<P> {
  Element([TypedMap cfg]) : super(cfg) {
    attrs = originalAttrs;
    initDefaultAttrs();
    if (cfg != null) {
      attrs.mix(cfg['attrs'] as TypedMap);
    }

    if (attrs.matrix == null) {
      attrs.matrix = Matrix4.identity();
    }
  }
  
  @override
  void initDefaultProps() {
    props.zIndex = 0;
    props.visible = true;
  }
  
  A get attrs => props.attrs;

  set attrs(A attrs) => props.attrs = attrs;

  @protected
  A get originalAttrs;

  @protected
  void initDefaultAttrs() {}

  void attr(A attrs) {
    this.attrs.mix(attrs);
  }

  Rect get bbox;

  void paint(Canvas canvas) {
    if (!props.visible) {
      return;
    }

    _setCanvas(canvas);
    draw(canvas);
    _restoreCanvas(canvas);
  }

  void _setCanvas(Canvas canvas) {
    canvas.save();

    final matrix = attrs.matrix;
    if (matrix != Matrix4.identity()) {
      canvas.transform(matrix.storage);
    }

    final clip = attrs.clip;
    canvas.clipPath(clip);
  }

  @protected
  void draw(Canvas canvas);

  void _restoreCanvas(Canvas canvas) {
    canvas.restore();
  }

  void remove() {
    final siblings = props.parent?.props?.children;
    if (siblings != null) {
      siblings.remove(this);
    }
  }

  void transform(Matrix4 matrix) {
    if (matrix == null || matrix == Matrix4.identity()) {
      return;
    }
    attrs.matrix.multiply(matrix);
  }

  void translate({double x = 0, double y = 0}) {
    x ??= 0;
    y ??= 0;

    if (x == 0 && y == 0) {
      return;
    }
    attrs.matrix.leftTranslate(x, y);
  }

  void scale({double x = 1, double y = 1, Offset origin}) {
    x ??= 1;
    y ??= 1;

    if (x == 1 && y == 1) {
      return;
    }
    if ((origin == null) || (origin.dx == 0.0 && origin.dy == 0.0)) {
      attrs.matrix.multiply(Matrix4.identity()..scale(x, y));
      return;
    }
    attrs.matrix
      ..translate(origin.dx, origin.dy)
      ..multiply(Matrix4.identity()..scale(x, y))
      ..translate(-origin.dx, -origin.dy);
  }

  void rotate(double angleRadians, {Offset origin}) {
    if (angleRadians == null || angleRadians == 0) {
      return;
    }
    if ((origin == null) || (origin.dx == 0.0 && origin.dy == 0.0)) {
      attrs.matrix.rotateZ(angleRadians);
      return;
    }
    attrs.matrix
      ..translate(origin.dx, origin.dy)
      ..multiply(Matrix4.rotationZ(angleRadians))
      ..translate(-origin.dx, -origin.dy);
  }
}
