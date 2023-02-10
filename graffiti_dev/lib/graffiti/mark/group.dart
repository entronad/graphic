import 'dart:ui';

import 'mark.dart';

class _GroupStyle extends MarkStyle {
  @override
  _GroupStyle lerpFrom(covariant _GroupStyle from, double t) {
    throw UnsupportedError('Should not lerp _GroupStyle.');
  }
}

final _groupStyle = _GroupStyle();

class GroupMark extends Mark<_GroupStyle> {
  GroupMark({
    required this.marks,

    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: _groupStyle,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final List<Mark> marks;

  @override
  void draw(Canvas canvas) {
    for (var mark in marks) {
      mark.paint(canvas);
    }
  }

  @override
  GroupMark lerpFrom(covariant GroupMark from, double t) {
    assert(from.marks.length == marks.length);
    final rstMarks = <Mark>[];
    for (var i = 0; i < marks.length; i++) {
      rstMarks.add(marks[i].lerpFrom(from.marks[i], t));
    }

    return GroupMark(
      marks: rstMarks,
      rotation: lerpDouble(from.rotation, rotation, t),
      rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
    );
  }
}
