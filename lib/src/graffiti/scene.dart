import 'dart:ui';

import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/common/operators/render.dart';

import 'figure.dart';
import 'graffiti.dart';

/// The base class of scenes.
///
/// A scene holds a group of [Figure]s for the [Graffiti] to paint. They are held
/// by [Graffiti] and [Render] operators simutaniously, so they connect the dataflow
/// and rendering engine. Once the chart is built, the scene instances will not
/// change, but the figures they hold may vary on reevaluation.
abstract class Scene {
  Scene(this.layer);

  /// The layer of this scene.
  int layer;

  /// The intrinsic layer of this scene.
  ///
  /// It determins the stacking order when [layer]s are the same. It is picked
  /// from [IntrinsicLayers] by subclass implementation.
  int get intrinsicLayer;

  /// The previous stakcking order.
  ///
  /// It helps the [Graffiti] to sort scenes stably.
  late int preOrder;

  /// Figures to paint.
  ///
  /// If null, the scene will do nothing in painting.
  List<Figure>? figures;

  /// The painting clip of the figures of this scene.
  Path? clip;

  /// Sets a Rectangle [clip].
  void setRegionClip(Rect region) => clip = Path()..addRect(region);

  /// Paints the figures
  ///
  /// It is called by [Graffiti.paint].
  void paint(Canvas canvas) {
    if (figures != null) {
      canvas.save();
      if (clip != null) {
        canvas.clipPath(clip!);
      }

      for (var figure in figures!) {
        figure.paint(canvas);
      }

      canvas.restore();
    }
  }
}
