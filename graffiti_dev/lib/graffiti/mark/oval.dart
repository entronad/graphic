import 'dart:ui';

import 'mark.dart';

class OvalMark extends Primitive {
  OvalMark({
    required this.oval,

    required Paint style,
    Shadow? shadow,
    List<double>? dash,
  }) : super(
    style: style,
    shadow: shadow,
    dash: dash,
  );

  final Rect oval;
  
  @override
  void createPath(Path path) =>
    path.addOval(oval);
}
