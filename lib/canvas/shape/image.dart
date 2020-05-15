import 'dart:ui' show
  Rect,
  Canvas,
  Size,
  Offset,
  instantiateImageCodec,
  Path,
  Paint;
import 'dart:ui'as ui show Image;
import 'dart:typed_data' show ByteData;

import 'package:flutter/services.dart' show rootBundle, AssetBundle;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;

class Image extends Shape {
  Image(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0;

  @override
  bool get isOnlyHitBBox => true;

  @override
  Rect calculateBBox() {
    final image = attrs.image;
    final width = image?.width?.toDouble() ?? 0.0;
    final height = image?.height?.toDouble() ?? 0.0;
    return Rect.fromLTWH(attrs.x, attrs.y, width, height);
  }

  @override
  void paintShape(Canvas canvas, Size size, Path path, Paint paint) {
    final image = attrs.image;
    final point = Offset(attrs.x, attrs.y);
    if (image != null) {
      canvas.drawImage(image, point, paint);
    }
  }

  @override
  Image clone() => Image(cfg.clone());
}

Future<ui.Image> getAssetImage(
  String assetName, {
  AssetBundle bundle,
  String package,
  int targetWidth,
  int targetHeight,
}) async {
  assert(assetName != null);

  final keyName = package == null ? assetName : 'packages/$package/$assetName';
  bundle = bundle ?? rootBundle;

  final ByteData data = await bundle.load(keyName);
  final codec = await instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: targetWidth,
    targetHeight: targetHeight
  );
  final frame = await codec.getNextFrame();
  return frame.image;
}
