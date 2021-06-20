import 'function.dart';

abstract class LineShape extends FunctionShape {
  
}

class BasicLineShape extends LineShape {
  @override
  bool equalTo(Object other) =>
    other is BasicLineShape;
}
