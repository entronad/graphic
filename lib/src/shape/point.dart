import 'function.dart';

abstract class PointShape extends FunctionShape {
  
}

class CircleShape extends PointShape {
  @override
  bool equalTo(Object other) =>
    other is CircleShape;
}

class SquareShape extends PointShape {
  @override
  bool equalTo(Object other) =>
    other is SquareShape;
}
