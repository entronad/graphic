import 'dart:ui' show Rect;
import '../element.dart' show Element, ChangeType;

void refreshElement(Element element, ChangeType changeType) {
  final canvasController = element.cfg.canvasController;
  if (canvasController != null) {
    if (changeType == ChangeType.remove) {
      element.cacheCanvasBBox = element.cfg.cacheCanvasBBox;
    }
    if (!element.cfg.hasChanged) {
      canvasController.refreshElement(element);
      if (canvasController.cfg.autoDraw) {
        canvasController.draw();
      }
      element.cfg.hasChanged = true;
    }
  }
}

Rect getRefreshRegion(Element element) {
  Rect region;
  if (!element.destroyed) {
    final cacheBox = element.cfg.cacheCanvasBBox;
    final bbox = element.canvasBBox;
    region = cacheBox.expandToInclude(bbox);
  } else {
    region = element.cacheCanvasBBox;
  }
  return region;
}

Rect getMergedRegion(List<Element> elements) {
  if (elements.isEmpty) {
    return null;
  }
  return elements
    .map((element) => getRefreshRegion(element))
    .reduce((region1, region2) => region1.expandToInclude(region2));
}
