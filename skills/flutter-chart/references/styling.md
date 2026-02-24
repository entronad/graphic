# Styling Reference

## PaintStyle

Controls fill and stroke appearance for chart elements like axis lines, grid lines, annotation lines, and custom shapes.

```dart
PaintStyle({
  Color? fillColor,
  Gradient? fillGradient,
  Shader? fillShader,
  Color? strokeColor,
  Gradient? strokeGradient,
  Shader? strokeShader,
  Rect? gradientBounds,
  BlendMode? blendMode,
  double? strokeWidth,
  StrokeCap? strokeCap,
  StrokeJoin? strokeJoin,
  double? strokeMiterLimit,
  double? elevation,
  Color? shadowColor,
  List<double>? dash,
  DashOffset? dashOffset,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `fillColor` | `Color?` | Solid fill color |
| `fillGradient` | `Gradient?` | Gradient fill |
| `strokeColor` | `Color?` | Stroke/outline color |
| `strokeWidth` | `double?` | Stroke width |
| `strokeCap` | `StrokeCap?` | Line end cap style |
| `strokeJoin` | `StrokeJoin?` | Line join style |
| `elevation` | `double?` | Shadow elevation |
| `shadowColor` | `Color?` | Shadow color |
| `dash` | `List<double>?` | Dash pattern (e.g., `[5, 3]`) |
| `blendMode` | `BlendMode?` | Blend mode |

**Examples**:
```dart
// Solid stroke
PaintStyle(strokeColor: Colors.grey, strokeWidth: 1)

// Dashed line
PaintStyle(strokeColor: Colors.red, dash: [4, 2])

// Filled with shadow
PaintStyle(fillColor: Colors.blue, elevation: 4, shadowColor: Colors.black26)

// Gradient fill
PaintStyle(fillGradient: LinearGradient(colors: [Colors.blue, Colors.red]))
```

## LabelStyle

Controls text rendering for axis labels, tick labels, and data labels.

```dart
LabelStyle({
  TextStyle? textStyle,
  InlineSpan Function(String)? span,
  TextAlign? textAlign,
  TextDirection? textDirection,
  TextScaler? textScaler,
  int? maxLines,
  String? ellipsis,
  Locale? locale,
  StrutStyle? strutStyle,
  TextWidthBasis? textWidthBasis,
  TextHeightBehavior? textHeightBehavior,
  double? minWidth,
  double? maxWidth,
  Offset? offset,
  double? rotation,
  Alignment? align,
})
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `textStyle` | `TextStyle?` | Flutter TextStyle for the label |
| `span` | `InlineSpan Function(String)?` | Custom rich text span builder |
| `textAlign` | `TextAlign?` | Text alignment |
| `maxLines` | `int?` | Maximum lines |
| `ellipsis` | `String?` | Overflow text |
| `maxWidth` | `double?` | Maximum width constraint |
| `offset` | `Offset?` | Position offset |
| `rotation` | `double?` | Rotation angle in radians |
| `align` | `Alignment?` | Alignment relative to anchor |

**Examples**:
```dart
// Basic label style
LabelStyle(
  textStyle: TextStyle(fontSize: 12, color: Colors.grey),
)

// Rotated axis labels
LabelStyle(
  textStyle: TextStyle(fontSize: 10),
  rotation: -pi / 4,  // 45 degrees
  align: Alignment.centerRight,
)

// Offset label
LabelStyle(
  textStyle: TextStyle(fontSize: 11),
  offset: Offset(0, -10),
)
```

## Label

The data type for label values in `LabelEncode`.

```dart
Label(
  String? text,
  [LabelStyle style = const LabelStyle()],
)
```

**Examples**:
```dart
// Simple text label
Label('Hello')

// Styled label
Label(
  '42%',
  LabelStyle(
    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    align: Alignment.center,
  ),
)
```

## Defaults

The `Defaults` class provides built-in presets for colors, styles, and axes.

### Colors

```dart
Defaults.primaryColor     // Color(0xff1890ff) — default blue
Defaults.strokeColor      // Color(0xffe8e8e8) — light grey for lines
Defaults.textColor        // Color(0xff808080) — medium grey for text
Defaults.colors10         // List<Color> — 10-color categorical palette
Defaults.colors20         // List<Color> — 20-color categorical palette
```

### Styles

```dart
Defaults.strokeStyle      // PaintStyle for auxiliary lines
Defaults.textStyle        // TextStyle for regular text
Defaults.runeStyle        // TextStyle for text on colored surfaces (white)
```

### Preset Axes

```dart
Defaults.horizontalAxis   // Bottom x-axis with labels, ticks, grid
Defaults.verticalAxis     // Left y-axis with labels, ticks, grid
Defaults.circularAxis     // Angular axis for polar coords
Defaults.radialAxis       // Radial axis for polar coords
```

### Usage

```dart
Chart(
  // ...
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
  marks: [
    IntervalMark(
      color: ColorEncode(
        variable: 'category',
        values: Defaults.colors10,
      ),
    ),
  ],
)
```
