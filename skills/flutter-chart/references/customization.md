# Custom Chart Development Reference

Graphic's true power lies in its customization capabilities. Every visual layer — shapes, tooltips, annotations, encodings, and modifiers — can be fully customized to create unique, bespoke data visualizations that go far beyond standard chart types.

## Customization Entry Points

| What to Customize | How | Key Classes |
|-------------------|-----|-------------|
| **Chart geometry** | Create custom Shape | Extend `IntervalShape`, `LineShape`, `AreaShape`, `PointShape`, or `PolygonShape` |
| **Visual encoding** | Custom encoder functions | `ColorEncode(encoder: ...)`, `SizeEncode(encoder: ...)`, etc. |
| **Tooltips** | Custom tooltip renderer | `TooltipGuide(renderer: ...)` |
| **Annotations** | Custom annotation renderer | `CustomAnnotation(renderer: ...)` |
| **Data processing** | Custom transforms | `MapTrans(mapper: ...)`, `Filter(predicate: ...)` |
| **Collision handling** | Custom modifier | Extend `Modifier` |

---

## Custom Shapes (Most Powerful Customization)

Custom shapes let you define entirely new geometry renderers — triangles, arrows, lollipops, candlesticks, gauges, or any visual form you can imagine.

### Shape Base Class

```dart
abstract class Shape extends CustomizableSpec {
  /// Renders the primary geometry for a group of data elements.
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,   // Encoded data attributes
    CoordConv coord,          // Coordinate converter
    Offset origin,            // Canvas origin
  );

  /// Renders labels above the geometry.
  List<MarkElement> drawGroupLabels(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  );

  /// Default size when Attributes.size is null.
  double get defaultSize;

  /// The representative point for interactions/animations.
  Offset representPoint(List<Offset> position) => position.last;
}
```

### Shape Type Hierarchy

Choose the base class that matches your mark type:

| Base Class | For Mark | Default Size | Notes |
|------------|----------|--------------|-------|
| `IntervalShape` | `IntervalMark` / `CustomMark` | 15 | 2 position points (baseline, value) |
| `LineShape` | `LineMark` | 2 (stroke width) | Multiple connected points per group |
| `AreaShape` | `AreaMark` | N/A | Multiple points, fills between line and axis |
| `PointShape` | `PointMark` | 5 | 1 position point per element |
| `PolygonShape` | `PolygonMark` | N/A | Multiple vertices per element |

### Writing a Custom Shape: Step by Step

#### Step 1: Extend the appropriate base class

```dart
class TriangleShape extends IntervalShape {
  // ...
}
```

#### Step 2: Implement `drawGroupPrimitives()`

This is the core rendering method. It receives a group of `Attributes` (one per data element) and must return `MarkElement` objects to draw.

```dart
@override
List<MarkElement> drawGroupPrimitives(
  List<Attributes> group,
  CoordConv coord,
  Offset origin,
) {
  final rst = <MarkElement>[];

  for (var item in group) {
    // 1. Skip invalid data
    if (item.position.any((p) => !p.dx.isFinite || !p.dy.isFinite)) continue;

    // 2. Get paint style from attributes (handles color, gradient, elevation)
    final style = getPaintStyle(item, false, 0, null, null);

    // 3. Convert normalized positions [0,1] to canvas coordinates
    final start = coord.convert(item.position[0]);  // baseline
    final end = coord.convert(item.position[1]);     // value point

    // 4. Get size (falls back to defaultSize)
    final size = item.size ?? defaultSize;

    // 5. Build geometry using MarkElement primitives
    rst.add(PolygonElement(
      points: [
        end,                                       // tip
        Offset(start.dx - size / 2, start.dy),     // bottom-left
        Offset(start.dx + size / 2, start.dy),     // bottom-right
      ],
      style: style,
      tag: item.tag,  // Important: preserve tag for animations!
    ));
  }

  return rst;
}
```

#### Step 3: Implement `drawGroupLabels()` (optional)

```dart
@override
List<MarkElement> drawGroupLabels(
  List<Attributes> group,
  CoordConv coord,
  Offset origin,
) {
  final rst = <MarkElement>[];
  for (var item in group) {
    if (item.label?.haveText ?? false) {
      final anchor = coord.convert(item.position.last);
      rst.add(LabelElement(
        text: item.label!.text!,
        anchor: anchor,
        defaultAlign: Alignment.topCenter,
        style: item.label!.style,
        tag: item.tag,
      ));
    }
  }
  return rst;
}
```

#### Step 4: Implement `equalTo()`

Required for the reactive system to detect changes:

```dart
@override
bool equalTo(Object other) => other is TriangleShape;
```

For shapes with configurable parameters:

```dart
class ArrowShape extends IntervalShape {
  ArrowShape({this.headSize = 10, this.hollow = false});
  final double headSize;
  final bool hollow;

  @override
  bool equalTo(Object other) =>
    other is ArrowShape &&
    headSize == other.headSize &&
    hollow == other.hollow;

  // ... drawGroupPrimitives() ...
}
```

#### Step 5: Use in Chart

```dart
Chart(
  data: data,
  variables: { /* ... */ },
  marks: [
    IntervalMark(
      shape: ShapeEncode(value: TriangleShape()),
    ),
    // Or with CustomMark for non-standard shapes:
    CustomMark(
      shape: ShapeEncode(value: MyCustomShape()),
    ),
  ],
)
```

### Custom PointShape Example

```dart
class DiamondShape extends PointShape {
  DiamondShape({bool hollow = false, double strokeWidth = 1})
    : super(hollow: hollow, strokeWidth: strokeWidth);

  @override
  MarkElement drawPoint(Attributes item, CoordConv coord) {
    final point = coord.convert(item.position.first);
    final size = item.size ?? defaultSize;
    final style = getPaintStyle(item, hollow, strokeWidth, null, null);

    return PolygonElement(
      points: [
        Offset(point.dx, point.dy - size),     // top
        Offset(point.dx + size, point.dy),     // right
        Offset(point.dx, point.dy + size),     // bottom
        Offset(point.dx - size, point.dy),     // left
      ],
      style: style,
      tag: item.tag,
    );
  }

  @override
  bool equalTo(Object other) =>
    other is DiamondShape &&
    hollow == other.hollow &&
    strokeWidth == other.strokeWidth;
}
```

---

## Attributes: Data Available During Rendering

The `Attributes` object passed to shape rendering contains all encoded data for one element:

```dart
class Attributes {
  final int index;                // Tuple index in the original data
  final String? tag;              // Animation correspondence tag
  final List<Offset> position;    // Normalized [0,1] position points
  final Shape shape;              // Shape specification
  final Color? color;             // Encoded color
  final Gradient? gradient;       // Encoded gradient (mutually exclusive with color)
  final double? elevation;        // Encoded shadow elevation
  final Label? label;             // Encoded label (text + style)
  final double? size;             // Encoded size (null = use Shape.defaultSize)
}
```

**Position Points**:
- Always in normalized coordinates `[0, 1]` for both x and y
- Must be converted to canvas pixels via `coord.convert(point)`
- Number of points depends on mark type:
  - IntervalMark: 2 points — `[0]` is baseline, `[1]` is value
  - PointMark: 1 point — the data point
  - LineMark/AreaMark: all points in the connected series
  - Custom with blend (`+`): multiple values on same dimension

---

## Coordinate Conversion (CoordConv)

All custom shapes must handle coordinate conversion properly.

### RectCoordConv (Cartesian)

```dart
// Convert normalized [0,1] to canvas pixels
final canvasPoint = coord.convert(Offset(normalizedX, normalizedY));

// Inverse: canvas pixels to normalized
final normalized = coord.invert(canvasPoint);

// Convert a canvas distance to normalized distance
final normalizedDist = coord.invertDistance(pixelDistance, Dim.x);

// Access coordinate region
final Rect region = coord.region;

// Check transposition
if (coord.transposed) { /* x and y are swapped */ }
```

### PolarCoordConv (Polar/Radial)

```dart
if (coord is PolarCoordConv) {
  final polarCoord = coord as PolarCoordConv;

  // Center point of the polar coordinate
  final Offset center = polarCoord.center;

  // Convert abstract angle/radius to canvas values
  final canvasAngle = polarCoord.convertAngle(abstractAngle);
  final canvasRadius = polarCoord.convertRadius(abstractRadius);

  // Convert angle+radius to canvas offset
  final point = polarCoord.polarToOffset(canvasAngle, canvasRadius);

  // Angle range in radians
  final startAngle = polarCoord.startAngle;
  final endAngle = polarCoord.endAngle;
}
```

### Coordinate-Aware Custom Shapes

Some shapes need different rendering for different coordinate systems:

```dart
@override
List<MarkElement> drawGroupPrimitives(
  List<Attributes> group, CoordConv coord, Offset origin,
) {
  if (coord is RectCoordConv) {
    return _drawCartesian(group, coord);
  } else if (coord is PolarCoordConv) {
    return _drawPolar(group, coord);
  }
  throw UnsupportedError('Unsupported coordinate type');
}
```

---

## MarkElement Drawing Primitives

These are the building blocks available for rendering custom shapes:

### Geometric Primitives (PrimitiveElement)

All accept `PaintStyle style`, optional `double? rotation`, `Offset? rotationAxis`, `String? tag`.

| Element | Constructor | Use Case |
|---------|------------|----------|
| `RectElement` | `(rect: Rect, borderRadius: BorderRadius?)` | Rectangles, rounded bars |
| `CircleElement` | `(center: Offset, radius: double)` | Circles, dots |
| `OvalElement` | `(oval: Rect)` | Ellipses |
| `PolygonElement` | `(points: List<Offset>)` | Arbitrary polygons, triangles, diamonds |
| `PolylineElement` | `(points: List<Offset>)` | Connected line segments |
| `ArcElement` | `(oval: Rect, startAngle: double, endAngle: double)` | Arc segments |
| `SectorElement` | `(center: Offset, startRadius: double, endRadius: double, startAngle: double, endAngle: double, borderRadius: BorderRadius?)` | Pie/donut sectors |
| `SplineElement` | `(start: Offset, cubics: List<List<Offset>>)` | Smooth bezier curves |
| `PathElement` | `(segments: List<Segment>)` | Complex paths from segments |

### Path Segments (for PathElement)

| Segment | Parameters | Description |
|---------|------------|-------------|
| `MoveSegment` | `(end: Offset)` | Move to point (must be first) |
| `LineSegment` | `(end: Offset)` | Line to point |
| `CubicSegment` | `(control1: Offset, control2: Offset, end: Offset)` | Cubic bezier curve |
| `QuadraticSegment` | `(control: Offset, end: Offset)` | Quadratic bezier curve |
| `ArcSegment` | `(oval: Rect, startAngle: double, endAngle: double)` | Arc segment |
| `CloseSegment` | `()` | Close the path |

### Text Element

| Element | Constructor | Use Case |
|---------|------------|----------|
| `LabelElement` | `(text: String, anchor: Offset, style: LabelStyle, defaultAlign: Alignment?)` | Text labels |

### Grouping

| Element | Constructor | Use Case |
|---------|------------|----------|
| `GroupElement` | `(elements: List<MarkElement>)` | Group multiple elements as one unit |

### Example: Complex Custom Shape

```dart
// Lollipop shape: a line with a circle at the top
class LollipopShape extends IntervalShape {
  LollipopShape({this.radius = 6, this.stemWidth = 2});
  final double radius;
  final double stemWidth;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group, CoordConv coord, Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (var item in group) {
      if (item.position.any((p) => !p.dy.isFinite)) continue;

      final baseStyle = getPaintStyle(item, false, 0, null, null);
      final base = coord.convert(item.position[0]);
      final tip = coord.convert(item.position[1]);

      // Stem (line)
      rst.add(PolylineElement(
        points: [base, tip],
        style: PaintStyle(
          strokeColor: baseStyle.fillColor ?? baseStyle.strokeColor,
          strokeWidth: stemWidth,
        ),
        tag: item.tag != null ? '${item.tag}_stem' : null,
      ));

      // Head (circle)
      rst.add(CircleElement(
        center: tip,
        radius: radius,
        style: baseStyle,
        tag: item.tag != null ? '${item.tag}_head' : null,
      ));
    }
    return rst;
  }

  @override
  bool equalTo(Object other) =>
    other is LollipopShape && radius == other.radius && stemWidth == other.stemWidth;
}
```

---

## getPaintStyle Utility

The `getPaintStyle` helper extracts `PaintStyle` from an `Attributes` object:

```dart
PaintStyle getPaintStyle(
  Attributes attributes,
  bool hollow,           // true: stroke only; false: filled
  double strokeWidth,    // stroke width when hollow
  Rect? gradientBounds,  // bounds for gradient shader
  List<double>? dash,    // dash pattern
)
```

- When `hollow = false`: uses `fillColor`/`fillGradient` from attributes
- When `hollow = true`: uses `strokeColor`/`strokeGradient` from attributes
- Handles gradient-to-shader conversion with bounds
- Applies elevation/shadow from attributes

---

## Custom Tooltip Renderer

Replace the default tooltip with completely custom rendering:

```dart
typedef TooltipRenderer = List<MarkElement> Function(
  Size size,                        // Chart widget size
  Offset anchor,                    // Tooltip anchor position
  Map<int, Tuple> selectedTuples,   // Selected data indexed by tuple index
);
```

### Example: Custom Rich Tooltip

```dart
List<MarkElement> myTooltipRenderer(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
) {
  if (selectedTuples.isEmpty) return [];

  final tuple = selectedTuples.values.first;
  final name = tuple['name'].toString();
  final value = tuple['value'].toString();

  // Background card
  final bgRect = Rect.fromLTWH(
    anchor.dx - 60, anchor.dy - 50, 120, 40,
  );

  return [
    // Shadow
    RectElement(
      rect: bgRect,
      borderRadius: BorderRadius.circular(8),
      style: PaintStyle(
        fillColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
    ),
    // Title
    LabelElement(
      text: name,
      anchor: Offset(bgRect.left + 10, bgRect.top + 6),
      style: LabelStyle(
        textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    ),
    // Value
    LabelElement(
      text: value,
      anchor: Offset(bgRect.left + 10, bgRect.top + 22),
      style: LabelStyle(
        textStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    ),
  ];
}

// Use it
tooltip: TooltipGuide(renderer: myTooltipRenderer)
```

---

## Custom Annotation Renderer

Draw any custom graphics at a data position or absolute anchor:

```dart
CustomAnnotation(
  renderer: (Offset anchor, Size chartSize) {
    return [
      // Draw a target marker
      CircleElement(
        center: anchor,
        radius: 15,
        style: PaintStyle(strokeColor: Colors.red, strokeWidth: 2),
      ),
      CircleElement(
        center: anchor,
        radius: 5,
        style: PaintStyle(fillColor: Colors.red),
      ),
      LabelElement(
        text: 'Target',
        anchor: Offset(anchor.dx, anchor.dy - 22),
        style: LabelStyle(
          textStyle: TextStyle(color: Colors.red, fontSize: 10),
          align: Alignment.bottomCenter,
        ),
      ),
    ];
  },
  variables: ['date', 'value'],
  values: [DateTime(2024, 6, 15), 75],
)
```

### Absolute Positioning

Use `anchor` instead of `variables`/`values` for position relative to chart size:

```dart
CustomAnnotation(
  renderer: (Offset anchor, Size chartSize) {
    return [
      LabelElement(
        text: 'Chart Title',
        anchor: anchor,
        style: LabelStyle(
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  },
  anchor: (size) => Offset(size.width / 2, 20),  // Top center
)
```

---

## Custom Encoder Functions

Every encode channel supports custom encoder functions for maximum flexibility:

```dart
// Conditional coloring
color: ColorEncode(encoder: (tuple) {
  final value = tuple['value'] as num;
  if (value > 100) return Colors.red;
  if (value > 50) return Colors.orange;
  return Colors.green;
}),

// Computed size
size: SizeEncode(encoder: (tuple) {
  return (tuple['weight'] as num).toDouble().clamp(2, 30);
}),

// Dynamic shape
shape: ShapeEncode<PointShape>(encoder: (tuple) {
  return tuple['type'] == 'high'
    ? CircleShape()
    : SquareShape(hollow: true);
}),

// Gradient based on data
gradient: GradientEncode(encoder: (tuple) {
  final ratio = (tuple['ratio'] as num).toDouble();
  return LinearGradient(
    colors: [Colors.blue, Colors.red],
    stops: [0, ratio],
  );
}),

// Rich label with custom styling
label: LabelEncode(encoder: (tuple) {
  final value = tuple['value'] as num;
  return Label(
    '${value.toStringAsFixed(1)}%',
    LabelStyle(
      textStyle: TextStyle(
        fontSize: value > 50 ? 14 : 10,
        fontWeight: value > 50 ? FontWeight.bold : FontWeight.normal,
        color: value > 50 ? Colors.red : Colors.grey,
      ),
      offset: Offset(0, -12),
    ),
  );
}),
```

---

## Custom Modifiers

Create custom collision-handling logic by extending `Modifier`:

```dart
abstract class Modifier extends CustomizableSpec {
  AttributesGroups modify(
    AttributesGroups groups,        // List<List<Attributes>>
    Map<String, ScaleConv> scales,  // Active scales
    AlgForm form,                   // Position algebra form
    CoordConv coord,                // Coordinate converter
    Offset origin,                  // Canvas origin
  );
}
```

`AttributesGroups` is `List<List<Attributes>>` — groups of attributes organized by the nest variable.

---

## Built-in Example: CandlestickShape

The library includes `CandlestickShape` as a reference implementation for complex custom shapes:

```dart
// Source: lib/src/shape/custom.dart
// Uses 4 position points: [start, end, max, min]
// Creates a candle body (RectElement) + wicks (PolylineElement)
// Handles up/down coloring via custom getPaintStyle logic
```

Usage:
```dart
Chart(
  data: ohlcData,
  variables: {
    'date': Variable(accessor: (m) => m['date'] as String),
    'start': Variable(accessor: (m) => m['open'] as num),
    'end': Variable(accessor: (m) => m['close'] as num),
    'max': Variable(accessor: (m) => m['high'] as num),
    'min': Variable(accessor: (m) => m['low'] as num),
  },
  marks: [
    CustomMark(
      position: Varset('date') *
        (Varset('start') + Varset('end') + Varset('max') + Varset('min')),
      shape: ShapeEncode(value: CandlestickShape()),
      color: ColorEncode(
        encoder: (tuple) => (tuple['end'] as num) >= (tuple['start'] as num)
          ? Colors.green
          : Colors.red,
      ),
    ),
  ],
)
```

---

## Best Practices for Custom Development

1. **Always preserve `tag`**: Pass `item.tag` to every `MarkElement` you create — this enables transition animations.

2. **Handle NaN/Infinity**: Check `item.position` for finite values before converting coordinates. Invalid data can produce NaN positions.

3. **Use `getPaintStyle()`**: Don't manually extract colors from `Attributes` — use the helper to correctly handle fills, strokes, gradients, and elevation.

4. **Respect `coord.transposed`**: If your shape calculates positions manually, check whether coordinates are transposed.

5. **Implement `equalTo()` properly**: Compare all properties that affect rendering. The reactive system uses this to detect changes.

6. **Use `GroupElement` for compound shapes**: When a single data point renders as multiple primitives (e.g., lollipop = line + circle), wrap them in a `GroupElement` for proper animation.

7. **Check coordinate type**: If your shape only works in Cartesian coordinates, assert with `assert(coord is RectCoordConv)`.

8. **Source code as documentation**: The library's source code has extensive comments. Read the built-in shapes in `lib/src/shape/` as reference implementations.
