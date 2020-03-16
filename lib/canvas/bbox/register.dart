import 'dart:ui' show Rect;

import '../shape/shape.dart' show Shape, ShapeType;

typedef BBoxMethod = Rect Function(Shape shape);

final cache = <ShapeType, BBoxMethod>{};

void register(ShapeType type, BBoxMethod method) => cache[type] = method;

BBoxMethod getMethod(ShapeType type) => cache[type];
