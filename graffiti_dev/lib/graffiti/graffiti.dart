import 'package:flutter/widgets.dart';

import 'scene.dart';
import 'transition.dart';

/// The rendering engine.
class Graffiti {
  Graffiti({
    required this.tickerProvider,
    required this.repaint,
  });

  final TickerProvider tickerProvider;

  final void Function() repaint;

  /// The scenes to paint.
  final _scenes = <Scene>[];

  /// Adds a scene to this graffiti.
  Scene createScene({
    int layer = 0,
    int chartLayer = 0,
    Transition? transition,
  }) {
    final scene = Scene(layer: layer, chartLayer: chartLayer, transition: transition, tickerProvider: tickerProvider, repaint: repaint);
    _scenes.add(scene);
    return scene;
  }

  /// Sorts [_scenes].
  ///
  /// The priority of comparing is [Scene.layer] > [Scene.layer] > [Scene.preOrder].
  void sort() {
    for (var i = 0; i < _scenes.length; i++) {
      _scenes[i].preIndex = i;
    }
    _scenes.sort((a, b) {
      final layerRst = a.layer - b.layer;
      if (layerRst != 0) {
        return layerRst;
      } else {
        final chartLayerRst = a.chartLayer - b.chartLayer;
        if (chartLayerRst != 0) {
          return chartLayerRst;
        } else {
          return a.preIndex - b.preIndex;
        }
      }
    });
  }

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

  void dispose() {
    for (var scene in _scenes) {
      scene.dispose();
    }
  }
}
