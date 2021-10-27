import 'dart:ui';

import 'package:flutter/painting.dart';

import 'scene.dart';

class Graffiti {
  Graffiti(Size size)
      : _clip = Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        );

  final _scenes = <Scene>[];

  Rect _clip;

  void set size(Size value) {
    _clip = Rect.fromLTWH(
      0,
      0,
      value.width,
      value.height,
    );
  }

  S add<S extends Scene>(S scene) {
    _scenes.add(scene);
    return scene;
  }

  /// Should and only should sort before first paint.
  /// zIndex -> layer -> preOrder
  void sort() {
    for (var i = 0; i < _scenes.length; i++) {
      _scenes[i].preOrder = i;
    }
    _scenes.sort((a, b) {
      final zIndexRst = a.zIndex - b.zIndex;
      if (zIndexRst != 0) {
        return zIndexRst;
      } else {
        final layerRst = a.layer - b.layer;
        if (layerRst != 0) {
          return layerRst;
        } else {
          return a.preOrder - b.preOrder;
        }
      }
    });
  }

  /// Used for CustomPainter's paint method.
  /// Won't paint outside size.
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(_clip);

    for (var scene in _scenes) {
      scene.paint(canvas);
    }

    canvas.restore();
  }
}
