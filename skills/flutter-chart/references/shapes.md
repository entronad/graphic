# Shapes Reference

Each mark type has compatible shape implementations that control how data is visually rendered.

## IntervalShape (for IntervalMark)

### RectShape

Rectangle or sector shape for bar charts and pie charts.

```dart
RectShape({
  bool histogram = false,
  double labelPosition = 1,
  BorderRadius? borderRadius,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `histogram` | `bool` | `false` | When true, bars fill the full category width with no gap |
| `labelPosition` | `double` | `1` | Label position along the bar (0=base, 1=top) |
| `borderRadius` | `BorderRadius?` | `null` | Rounded corners for bars |

**Examples**:
```dart
// Rounded bars
RectShape(borderRadius: BorderRadius.all(Radius.circular(5)))

// Histogram (no gaps between bars)
RectShape(histogram: true)
```

### FunnelShape

Funnel or pyramid chart shape.

```dart
FunnelShape({
  double labelPosition = 0.5,
  bool pyramid = false,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `labelPosition` | `double` | `0.5` | Label position |
| `pyramid` | `bool` | `false` | When true, renders as pyramid instead of funnel |

## LineShape (for LineMark)

### BasicLineShape

```dart
BasicLineShape({
  bool smooth = false,
  bool loop = false,
  bool stepped = false,
  List<double>? dash,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `smooth` | `bool` | `false` | Smooth curves (cubic bezier interpolation) |
| `loop` | `bool` | `false` | Connect last point back to first |
| `stepped` | `bool` | `false` | Step/staircase line |
| `dash` | `List<double>?` | `null` | Dash pattern (e.g., `[5, 2]` for 5px dash, 2px gap) |

**Examples**:
```dart
// Smooth line
BasicLineShape(smooth: true)

// Dashed line
BasicLineShape(dash: [5, 2])

// Stepped line (staircase)
BasicLineShape(stepped: true)

// Smooth + dashed
BasicLineShape(smooth: true, dash: [8, 4])
```

## AreaShape (for AreaMark)

### BasicAreaShape

```dart
BasicAreaShape({
  bool smooth = false,
  bool loop = false,
  bool stepped = false,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `smooth` | `bool` | `false` | Smooth curves |
| `loop` | `bool` | `false` | Close the area path |
| `stepped` | `bool` | `false` | Step/staircase area |

## PointShape (for PointMark)

### CircleShape

```dart
CircleShape({
  bool hollow = false,
  double strokeWidth = 1,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `hollow` | `bool` | `false` | Render as ring (stroke only) instead of filled circle |
| `strokeWidth` | `double` | `1` | Stroke width when hollow |

### SquareShape

```dart
SquareShape({
  bool hollow = false,
  double strokeWidth = 1,
})
```

Same parameters as `CircleShape`.

## PolygonShape (for PolygonMark)

### HeatmapShape

```dart
HeatmapShape({
  bool sector = false,
  BorderRadius? borderRadius,
  List<int?>? tileCounts,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sector` | `bool` | `false` | Render as sector (for polar coordinates) |
| `borderRadius` | `BorderRadius?` | `null` | Rounded corners |
| `tileCounts` | `List<int?>?` | `null` | Explicit tile counts per dimension |

## Custom Shapes (for CustomMark)

### CandlestickShape

Built-in candlestick (OHLC) chart shape. Located in `lib/src/shape/custom.dart`.

### Creating Custom Shapes

Extend the appropriate shape base class and implement the rendering method:

```dart
class MyShape extends IntervalShape {
  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (var item in group) {
      final style = getPaintStyle(item, false, 0, null, null);
      final start = coord.convert(item.position[0]);
      final end = coord.convert(item.position[1]);
      // Create custom MarkElement geometry...
      rst.add(PolygonElement(points: [...], style: style));
    }
    return rst;
  }

  @override
  bool equalTo(Object other) => other is MyShape;
}
```

Custom shapes must:
1. Extend the appropriate shape class for the mark type
2. Implement `drawGroupPrimitives()` or relevant render method
3. Implement `equalTo()` for equality comparison
