import 'dart:ui';

import 'figure.dart';

/// Scene and it's subclass has no paramed constructor,
///     because params are unknow when they are set to render operator in parsing.
abstract class Scene {
  int zIndex = 0;

  int get layer;

  // Help to order stablely.
  late int preOrder;

  // Make sure to set this before _paint, or _paint will do nothing.
  List<Figure>? figures;

  Path? clip;

  /// Set a region as clip.
  void setRegionClip(Rect region) => clip = Path()..addRect(region);

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
