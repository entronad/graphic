abstract class ShapeFactoryBase {
  
}

abstract class ShapeBase {
  String get defaultShapeType => null;

  
}

abstract class Shape {
  static final Map<String, ShapeFactoryBase Function()> factories = {};
  static final Map<String, Map<String, ShapeBase Function()>> shapes = {};

  static void registerFactory(
    String factoryName,
    ShapeFactoryBase Function() factoryCreator,
  ) {
    factories[factoryName] = factoryCreator;
  }

  static void registerShape (
    String factoryName,
    String shapeType,
    ShapeBase Function() shapeCreator,
  ) {
    assert(factories.containsKey(factoryName));

    if (!shapes.containsKey(factoryName)) {
      shapes[factoryName] = {};
    }
    shapes[factoryName][shapeType] = shapeCreator;
  }
}
