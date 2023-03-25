import 'dart:ui';

import 'package:graphic/src/util/collection.dart';

import 'element.dart';

class _GroupStyle extends ElementStyle {
  @override
  _GroupStyle lerpFrom(covariant _GroupStyle from, double t) {
    throw UnsupportedError('Should not lerp _GroupStyle.');
  }
}

final _groupStyle = _GroupStyle();

class GroupElement extends MarkElement<_GroupStyle> {
  GroupElement({
    required this.elements,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  }) : super(
          style: _groupStyle,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
        );

  final List<MarkElement> elements;

  @override
  void draw(Canvas canvas) {
    for (var element in elements) {
      element.paint(canvas);
    }
  }

  @override
  GroupElement lerpFrom(covariant GroupElement from, double t) {
    assert(from.elements.length == elements.length);
    final rstElements = <MarkElement>[];
    for (var i = 0; i < elements.length; i++) {
      rstElements.add(elements[i].lerpFrom(from.elements[i], t));
    }

    return GroupElement(
      elements: rstElements,
      rotation: lerpDouble(from.rotation, rotation, t),
      rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
      tag: tag,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GroupElement &&
      super == other &&
      deepCollectionEquals(elements, other.elements);
}
