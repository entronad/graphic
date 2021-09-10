import 'dart:ui';

import 'package:meta/meta.dart';

abstract class Painter {
  /// Subclass override this method.
  @protected
  void paint(Canvas canvas);
}

/// Scene and it's subclass has no paramed constructor,
///     because params are unknow when they are set to render operator in parsing.
abstract class Scene {
  int zIndex = 0;

  @protected
  int get layer;

  // Help to order stablely.
  int? _preOrder;

  // Make sure to set this before _paint, or _paint will do nothing.
  Painter? painter;

  Path? clip;

  /// Set a region as clip.
  void setRegionClip(Rect region, bool circular) => clip = circular
    ? (Path()..addOval(Rect.fromCircle(
        center: region.center,
        radius: region.shortestSide / 2,
      )))
    : (Path()..addRect(region));

  void _paint(Canvas canvas) {
    if (painter != null) {
      canvas.save();
      if (clip != null) {
        canvas.clipPath(clip!);
      }

      painter!.paint(canvas);

      canvas.restore();
    }
  }
}

class Graffiti {
  final _scenes = <Scene>[];

  Rect? _clip;

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
      _scenes[i]._preOrder = i;
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
          return a._preOrder! - b._preOrder!;
        }
      }
    });
  }

  /// Used for CustomPainter's paint method.
  /// Won't paint outside size.
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(_clip!);

    for (var scene in _scenes) {
      scene._paint(canvas);
    }

    canvas.restore();
  }
}
