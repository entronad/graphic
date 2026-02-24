# Coordinates Reference

Coordinate systems define how abstract positions map to canvas positions.

## RectCoord

Cartesian (rectangular) coordinate system. This is the default.

```dart
RectCoord({
  List<double>? horizontalRange,
  EventUpdater<List<double>>? horizontalRangeUpdater,
  List<double>? verticalRange,
  EventUpdater<List<double>>? verticalRangeUpdater,
  int? dimCount,
  double? dimFill,
  bool? transposed,
  Color? color,
  Gradient? gradient,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `horizontalRange` | `List<double>?` | `[0, 1]` | Visible horizontal range as proportions |
| `verticalRange` | `List<double>?` | `[0, 1]` | Visible vertical range as proportions |
| `horizontalRangeUpdater` | `EventUpdater<List<double>>?` | `null` | Update horizontal range on events |
| `verticalRangeUpdater` | `EventUpdater<List<double>>?` | `null` | Update vertical range on events |
| `dimCount` | `int?` | `2` | Number of dimensions (1 or 2) |
| `dimFill` | `double?` | `0.5` | Fill value when dimCount=1 (0-1) |
| `transposed` | `bool?` | `false` | Swap x and y dimensions |
| `color` | `Color?` | `null` | Background color of the coordinate region |
| `gradient` | `Gradient?` | `null` | Background gradient of the coordinate region |

**Examples**:
```dart
// Default Cartesian
RectCoord()

// Horizontal bar chart (transposed)
RectCoord(transposed: true)

// Zoomed in to show 30% of data
RectCoord(horizontalRange: [0.3, 0.6])

// With background
RectCoord(color: Colors.grey.withAlpha(20))
```

### Range Updaters for Zooming/Panning

Use range updaters with `IntervalSelection` for zoom/pan:

```dart
coord: RectCoord(
  horizontalRangeUpdater: (initialRange, preRange, event) {
    // Return new range based on gesture
    return newRange;
  },
),
```

## PolarCoord

Polar (radial) coordinate system for pie charts, radar charts, and rose charts.

```dart
PolarCoord({
  double? startAngle,
  double? endAngle,
  double? startRadius,
  double? endRadius,
  List<double>? angleRange,
  EventUpdater<List<double>>? angleRangeUpdater,
  List<double>? radiusRange,
  EventUpdater<List<double>>? radiusRangeUpdater,
  int? dimCount,
  double? dimFill,
  bool? transposed,
  Color? color,
  Gradient? gradient,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `startAngle` | `double?` | `-pi/2` | Start angle in radians (12 o'clock) |
| `endAngle` | `double?` | `3*pi/2` | End angle in radians (full circle) |
| `startRadius` | `double?` | `0` | Inner radius as proportion (0 = center) |
| `endRadius` | `double?` | `1` | Outer radius as proportion (1 = edge) |
| `angleRange` | `List<double>?` | `[0, 1]` | Visible angle range as proportions |
| `radiusRange` | `List<double>?` | `[0, 1]` | Visible radius range as proportions |
| `angleRangeUpdater` | `EventUpdater<List<double>>?` | `null` | Update angle range on events |
| `radiusRangeUpdater` | `EventUpdater<List<double>>?` | `null` | Update radius range on events |
| `dimCount` | `int?` | `2` | Number of dimensions |
| `dimFill` | `double?` | `0.5` | Fill value when dimCount=1 |
| `transposed` | `bool?` | `false` | Swap angle and radius dimensions |
| `color` | `Color?` | `null` | Background color |
| `gradient` | `Gradient?` | `null` | Background gradient |

### Common PolarCoord Recipes

**Pie Chart**:
```dart
PolarCoord(transposed: true, dimCount: 1)
```
- `transposed: true` — maps values to angle (not radius)
- `dimCount: 1` — single dimension (no radius variation)

**Donut Chart**:
```dart
PolarCoord(transposed: true, dimCount: 1, dimFill: 1.05)
// or with explicit inner radius
PolarCoord(transposed: true, startRadius: 0.4)
```

**Rose Chart**:
```dart
PolarCoord(startRadius: 0.15)
```

**Half Pie / Gauge**:
```dart
PolarCoord(
  transposed: true,
  dimCount: 1,
  startAngle: -pi,
  endAngle: 0,
)
```

**Radar Chart**:
```dart
PolarCoord()  // Default polar without transposing
```

## EventUpdater Type

```dart
typedef EventUpdater<V> = V Function(V initialValue, V preValue, Event event);
```

- `initialValue`: The original value when the chart was first rendered
- `preValue`: The value before this event
- `event`: The event that triggered the update (gesture, resize, or data change)
