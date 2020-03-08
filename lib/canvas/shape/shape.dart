import '../Cfg.dart' show Cfg;
import '../element.dart' show Element;

class Shape extends Element {
  Shape(Cfg cfg) : super(cfg);

  bool isHit(double x, double y) => true;
}

enum ShapeType {
  base,
  circle,
  ellipse,
  image,
  line,
  marker,
  path,
  polygon,
  polyline,
  rect,
  text,
}

Shape _baseCtor(Cfg cfg) => Shape(cfg);

const shapeBase = {
  ShapeType.base: _baseCtor,
};
