import 'function.dart';

abstract class AreaShape extends FunctionShape {
  
}

class BasicAreaShape extends AreaShape {
  @override
  bool equalTo(Object other) =>
    other is BasicAreaShape;
}
