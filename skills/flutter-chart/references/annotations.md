# Annotations Reference

Annotations are static visual elements overlaid on the chart.

## Common Base

All annotations have:
- `layer: int?` — Rendering layer (default: 0)

## LineAnnotation

Draws a reference line at a specific value.

```dart
LineAnnotation({
  Dim? dim,
  String? variable,
  required dynamic value,
  PaintStyle? style,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dim` | `Dim?` | `Dim.x` | Which dimension the line is on |
| `variable` | `String?` | `null` | Which variable to use for positioning |
| `value` | `dynamic` | **Required** | The value at which to draw the line |
| `style` | `PaintStyle?` | `null` | Line style |

**Examples**:
```dart
// Horizontal reference line at y=50
LineAnnotation(
  dim: Dim.y,
  variable: 'value',
  value: 50,
  style: PaintStyle(strokeColor: Colors.red, dash: [4, 2]),
)

// Vertical line at a date
LineAnnotation(
  dim: Dim.x,
  variable: 'date',
  value: DateTime(2024, 6, 1),
  style: PaintStyle(strokeColor: Colors.grey),
)
```

## RegionAnnotation

Highlights a rectangular region between two values.

```dart
RegionAnnotation({
  Dim? dim,
  String? variable,
  required List values,
  Color? color,
  Gradient? gradient,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dim` | `Dim?` | `Dim.x` | Which dimension |
| `variable` | `String?` | `null` | Which variable |
| `values` | `List` | **Required** | Two values: [start, end] |
| `color` | `Color?` | `null` | Fill color |
| `gradient` | `Gradient?` | `null` | Fill gradient (mutually exclusive with color) |

**Example**:
```dart
RegionAnnotation(
  dim: Dim.x,
  variable: 'date',
  values: [DateTime(2024, 3, 1), DateTime(2024, 6, 1)],
  color: Colors.blue.withAlpha(30),
)
```

## TagAnnotation

Places a text label at a specific position.

```dart
TagAnnotation({
  required Label label,
  List<String>? variables,
  List? values,
  Offset Function(Size)? anchor,
  bool? clip,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `label` | `Label` | **Required** | The label to display |
| `variables` | `List<String>?` | `null` | Variables for positioning |
| `values` | `List?` | `null` | Values for positioning (corresponding to variables) |
| `anchor` | `Offset Function(Size)?` | `null` | Direct position function (alternative to variables/values) |
| `clip` | `bool?` | `null` | Clip to coordinate region |

**Example**:
```dart
TagAnnotation(
  label: Label(
    'Target',
    LabelStyle(textStyle: TextStyle(color: Colors.red, fontSize: 12)),
  ),
  variables: ['date', 'value'],
  values: [DateTime(2024, 6, 1), 75],
)
```

## CustomAnnotation

Renders custom graphics at a specific position.

```dart
CustomAnnotation({
  required List<MarkElement> Function(Offset, Size) renderer,
  List<String>? variables,
  List? values,
  Offset Function(Size)? anchor,
  bool? clip,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `renderer` | `List<MarkElement> Function(Offset, Size)` | **Required** | Custom rendering function |
| `variables` | `List<String>?` | `null` | Variables for positioning |
| `values` | `List?` | `null` | Values for positioning |
| `anchor` | `Offset Function(Size)?` | `null` | Direct position function |
| `clip` | `bool?` | `null` | Clip to coordinate region |

The `renderer` receives the `Offset` anchor position and the chart `Size`, and returns a list of `MarkElement` objects to render.
