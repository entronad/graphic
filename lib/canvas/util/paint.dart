import 'dart:ui' show Canvas, Size;
import '../element.dart' show Element, ChangeType;
import '../shape/shape.dart' show Shape;

void paintChildren(Canvas canvas, List<Element> children, Size size) {
  for (var child in children) {
    if (child.cfg.visible) {
      child.paint(canvas, size);
    } else {
      child.skipDraw();
    }
  }
}

void refreshElement(Element element, ChangeType changeType) {
  final renderer = element.cfg.renderer;
  if (renderer != null) {
    if (changeType == ChangeType.remove) {
      element.cacheCanvasBBox = element.cfg.cacheCanvasBBox;
    }
    if (!element.cfg.hasChanged) {
      if (renderer.cfg.autoDraw) {
        renderer.repaint();
      }
      element.cfg.hasChanged = true;
    }
  }
}

void applyClip(Canvas canvas, Shape clip) {
  if (clip != null) {
    canvas.save();
    final clipPath = clip.path;
    final clipMatrix = clip.matrix;
    canvas.transform(clipMatrix.storage);
    canvas.clipPath(clipPath);
    canvas.restore();
    clip.afterDraw();
  }
}
