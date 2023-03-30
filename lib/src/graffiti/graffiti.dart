import 'package:flutter/widgets.dart';

import 'scene.dart';
import 'transition.dart';

/// The rendering engine.
class Graffiti {
  /// Create a graffiti rendering engine.
  Graffiti({
    required this.tickerProvider,
    required this.repaint,
  });

  /// The ticker provider for animation.
  /// 
  /// It is the widget state with [TickerProviderStateMixin].
  final TickerProvider tickerProvider;

  /// The handler to notify widget state to repaint.
  final void Function() repaint;

  /// The scenes to paint.
  final _scenes = <Scene>[];

  /// Creates a scene, add it to graffiti, and returns this scene.
  Scene createScene({
    int layer = 0,
    int builtinLayer = 0,
    Transition? transition,
  }) {
    final scene = Scene(
        layer: layer,
        builtinLayer: builtinLayer,
        transition: transition,
        tickerProvider: tickerProvider,
        repaint: repaint);
    _scenes.add(scene);
    return scene;
  }

  /// Sorts [_scenes].
  ///
  /// The priority of comparing is [Scene.layer] > [Scene.builtinLayer].
  void sort() {
    for (var i = 0; i < _scenes.length; i++) {
      _scenes[i].preIndex = i;
    }
    _scenes.sort((a, b) {
      final layerRst = a.layer - b.layer;
      if (layerRst != 0) {
        return layerRst;
      } else {
        final builtinLayerRst = a.builtinLayer - b.builtinLayer;
        if (builtinLayerRst != 0) {
          return builtinLayerRst;
        } else {
          return a.preIndex - b.preIndex;
        }
      }
    });
  }

  /// Updates all scenes.
  /// 
  /// Call this method when all scene settings are down and notify widget for the next frame.
  void update() {
    for (var scene in _scenes) {
      scene.update();
    }
  }

  /// Used for CustomPainter's paint method.
  ///
  /// Paints the scenes.
  ///
  /// It is called by [CustomPainter.paint].
  void paint(Canvas canvas) {
    for (var scene in _scenes) {
      scene.paint(canvas);
    }
  }

  /// Disposes all scenes.
  void dispose() {
    for (var scene in _scenes) {
      scene.dispose();
    }
  }
}
