# Marks Reference

Marks are the geometric elements that visually represent data. All marks share a common set of parameters inherited from the `Mark` base class.

## Common Mark Parameters

Every mark type accepts these parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `position` | `Varset?` | Position algebra expression |
| `color` | `ColorEncode?` | Color aesthetic encoding |
| `size` | `SizeEncode?` | Size aesthetic encoding |
| `shape` | `ShapeEncode<S>?` | Shape aesthetic encoding |
| `label` | `LabelEncode?` | Label encoding |
| `gradient` | `GradientEncode?` | Gradient encoding (mutually exclusive with `color`) |
| `elevation` | `ElevationEncode?` | Shadow elevation encoding |
| `modifiers` | `List<Modifier>?` | Geometry modifiers (Stack, Dodge, Jitter, Symmetric) |
| `layer` | `int?` | Rendering layer order |
| `selected` | `Selected?` | Initial selected tuple indices |
| `selectionStream` | `StreamController<Selected?>?` | Programmatic selection control |
| `transition` | `Transition?` | Transition animation spec |
| `entrance` | `Set<MarkEntrance>?` | Entrance animation strategy |
| `tag` | `String? Function(Tuple)?` | Element tag for transition matching |

### MarkEntrance enum

Controls how elements animate on first appearance:

- `MarkEntrance.x` — Animate from x=0
- `MarkEntrance.y` — Animate from y=0
- `MarkEntrance.size` — Animate from size=0
- `MarkEntrance.opacity` — Animate from opacity=0

### Selected type

`Selected` is `Map<String, Set<int>>` — maps selection names to sets of tuple indices.

## IntervalMark

Bar charts, histograms, pie charts (with PolarCoord).

```dart
IntervalMark(
  // All common parameters apply
  shape: ShapeEncode<IntervalShape>?,  // RectShape or FunnelShape
)
```

**Compatible shapes**: `RectShape`, `FunnelShape`

**Common uses**:
- Bar chart: Default configuration
- Horizontal bar: Use `RectCoord(transposed: true)`
- Pie chart: Use `PolarCoord(transposed: true, dimCount: 1)` + `Proportion` transform
- Rose chart: Use `PolarCoord(startRadius: 0.15)`
- Histogram: Use `RectShape(histogram: true)`

## LineMark

Line charts, sparklines.

```dart
LineMark(
  // All common parameters apply
  shape: ShapeEncode<LineShape>?,  // BasicLineShape
)
```

**Compatible shapes**: `BasicLineShape`

**Notes**:
- Line connects all points in a group
- Use `/` (nest) operator in position to create multi-series lines
- Size controls line stroke width

## AreaMark

Area charts, stream graphs.

```dart
AreaMark(
  // All common parameters apply
  shape: ShapeEncode<AreaShape>?,  // BasicAreaShape
)
```

**Compatible shapes**: `BasicAreaShape`

**Notes**:
- Area fills between the line and the axis
- Use `StackModifier()` + `SymmetricModifier()` for stream graphs

## PointMark

Scatter plots, bubble charts.

```dart
PointMark(
  // All common parameters apply
  shape: ShapeEncode<PointShape>?,  // CircleShape or SquareShape
)
```

**Compatible shapes**: `CircleShape`, `SquareShape`

**Notes**:
- Each data point renders independently
- Size controls point radius
- Use `SizeEncode(variable: 'field', values: [min, max])` for bubble charts

## PolygonMark

Heatmaps, treemaps.

```dart
PolygonMark(
  // All common parameters apply
  shape: ShapeEncode<PolygonShape>?,  // HeatmapShape
)
```

**Compatible shapes**: `HeatmapShape`

## CustomMark

Custom shapes like candlestick charts.

```dart
CustomMark(
  // All common parameters apply
  shape: ShapeEncode<Shape>?,  // Any Shape subclass
)
```

**Compatible shapes**: Any `Shape` implementation, including `CandlestickShape`.

## Multiple Marks

Multiple marks can be layered in the same chart:

```dart
marks: [
  AreaMark(
    color: ColorEncode(value: Colors.blue.withAlpha(50)),
  ),
  LineMark(
    color: ColorEncode(value: Colors.blue),
  ),
  PointMark(
    size: SizeEncode(value: 3),
    color: ColorEncode(value: Colors.blue),
  ),
]
```
