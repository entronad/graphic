# Guides Reference

Guides are visual aids that help users read the chart: axes, tooltips, and crosshairs.

## AxisGuide

Configures axis lines, tick marks, labels, and grid lines.

```dart
AxisGuide({
  Dim? dim,
  String? variable,
  double? position,
  bool? flip,
  PaintStyle? line,
  TickLine? tickLine,
  TickLineMapper? tickLineMapper,
  LabelStyle? label,
  LabelMapper? labelMapper,
  PaintStyle? grid,
  GridMapper? gridMapper,
  PaintStyle? labelBackground,
  LabelBackgroundMapper? labelBackgroundMapper,
  int? layer,
  int? gridZIndex,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dim` | `Dim?` | Auto | Axis dimension (`Dim.x` or `Dim.y`) |
| `variable` | `String?` | `null` | Bind to a specific variable |
| `position` | `double?` | `0` | Position on the cross dimension (0-1). 0=bottom/left, 1=top/right |
| `flip` | `bool?` | `false` | Flip tick lines and labels to the other side |
| `line` | `PaintStyle?` | `null` | Axis line style |
| `tickLine` | `TickLine?` | `null` | Tick mark configuration |
| `tickLineMapper` | `TickLineMapper?` | `null` | Dynamic tick line per tick |
| `label` | `LabelStyle?` | `null` | Label text style |
| `labelMapper` | `LabelMapper?` | `null` | Dynamic label style per tick |
| `grid` | `PaintStyle?` | `null` | Grid line style |
| `gridMapper` | `GridMapper?` | `null` | Dynamic grid style per tick |
| `labelBackground` | `PaintStyle?` | `null` | Label background style |
| `labelBackgroundMapper` | `LabelBackgroundMapper?` | `null` | Dynamic label background per tick |
| `layer` | `int?` | `null` | Rendering layer |
| `gridZIndex` | `int?` | `null` | Grid z-index |

### TickLine

```dart
TickLine({
  PaintStyle? style,  // Default: Defaults.strokeStyle
  double length = 5,  // Tick line length in pixels
})
```

### Mapper Functions

```dart
typedef TickLineMapper = TickLine? Function(String? text, int index, int total);
typedef LabelMapper = LabelStyle? Function(String? text, int index, int total);
typedef GridMapper = PaintStyle? Function(String? text, int index, int total);
typedef LabelBackgroundMapper = PaintStyle? Function(String? text, int index, int total);
```

Parameters: `text` is the tick label, `index` is the tick index, `total` is the total tick count.

### Default Axes

Use `Defaults` for quick axis setup:

```dart
axes: [
  Defaults.horizontalAxis,  // Bottom x-axis with labels, ticks, and grid
  Defaults.verticalAxis,    // Left y-axis with labels, ticks, and grid
]
```

For polar coordinates:
```dart
axes: [
  Defaults.circularAxis,    // Angular axis
  Defaults.radialAxis,      // Radial axis
]
```

### Custom Axis Example

```dart
AxisGuide(
  dim: Dim.y,
  position: 0,
  label: LabelStyle(
    textStyle: TextStyle(fontSize: 10, color: Colors.grey),
    offset: Offset(-5, 0),
  ),
  tickLine: TickLine(length: 3),
  grid: PaintStyle(strokeColor: Colors.grey.withAlpha(50)),
  line: PaintStyle(strokeColor: Colors.grey),
)
```

### Multiple Axes

```dart
axes: [
  Defaults.horizontalAxis,
  Defaults.verticalAxis,
  // Second y-axis on the right
  AxisGuide(
    dim: Dim.y,
    position: 1,       // Right side
    flip: true,         // Labels on the right
    variable: 'price',  // Bound to specific variable
  ),
]
```

---

## TooltipGuide

Shows data details on interaction.

```dart
TooltipGuide({
  Set<String>? selections,
  List<bool>? followPointer,
  Offset Function(Size)? anchor,
  int? layer,
  int? mark,
  Alignment? align,
  Offset? offset,
  EdgeInsets? padding,
  Color? backgroundColor,
  Radius? radius,
  double? elevation,
  TextStyle? textStyle,
  bool? multiTuples,
  List<String>? variables,
  bool? constrained,
  TooltipRenderer? renderer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selections` | `Set<String>?` | All selections | Which selections trigger the tooltip |
| `followPointer` | `List<bool>?` | `[false, false]` | Follow pointer position per dimension [x, y] |
| `anchor` | `Offset Function(Size)?` | `null` | Fixed anchor position (overrides followPointer) |
| `mark` | `int?` | `0` | Which mark (by index) to show tooltip for |
| `align` | `Alignment?` | `Alignment.center` | Tooltip alignment relative to anchor |
| `offset` | `Offset?` | `null` | Offset from anchor |
| `padding` | `EdgeInsets?` | `null` | Content padding |
| `backgroundColor` | `Color?` | `null` | Background color |
| `radius` | `Radius?` | `null` | Border radius |
| `elevation` | `double?` | `null` | Shadow elevation |
| `textStyle` | `TextStyle?` | `null` | Text style |
| `multiTuples` | `bool?` | `null` | Show data for multiple points |
| `variables` | `List<String>?` | `null` | Which variables to display |
| `constrained` | `bool?` | `null` | Keep tooltip within chart bounds |
| `renderer` | `TooltipRenderer?` | `null` | Custom tooltip renderer |

### TooltipRenderer

```dart
typedef TooltipRenderer = List<MarkElement> Function(
  Size size,
  Offset anchor,
  Map<int, Tuple> selectedTuples,
);
```

### Examples

```dart
// Basic tooltip
TooltipGuide()

// Follow pointer horizontally
TooltipGuide(followPointer: [true, true])

// Show specific variables
TooltipGuide(variables: ['name', 'value'])

// Styled tooltip
TooltipGuide(
  backgroundColor: Colors.black87,
  textStyle: TextStyle(color: Colors.white, fontSize: 12),
  radius: Radius.circular(4),
  elevation: 4,
)
```

---

## CrosshairGuide

Shows crosshair lines that follow the pointer or snap to data points.

```dart
CrosshairGuide({
  Set<String>? selections,
  List<PaintStyle?>? styles,
  List<LabelStyle?>? labelStyles,
  List<PaintStyle?>? labelBackgroundStyles,
  List<double>? labelPaddings,
  List<bool>? showLabel,
  List<String? Function(dynamic)?>? formatter,
  List<bool>? followPointer,
  int? layer,
  int? mark,
  List<bool>? expandEdges,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `selections` | `Set<String>?` | All selections | Triggering selections |
| `styles` | `List<PaintStyle?>?` | `null` | Line style per dimension [x, y] |
| `labelStyles` | `List<LabelStyle?>?` | `null` | Label style per dimension |
| `labelBackgroundStyles` | `List<PaintStyle?>?` | `null` | Label background per dimension |
| `labelPaddings` | `List<double>?` | `null` | Label padding per dimension |
| `showLabel` | `List<bool>?` | `[false, false]` | Show label on each dimension |
| `formatter` | `List<String? Function(dynamic)?>?` | `null` | Value formatter per dimension |
| `followPointer` | `List<bool>?` | `[false, false]` | Follow pointer per dimension |
| `mark` | `int?` | `0` | Which mark to follow |
| `expandEdges` | `List<bool>?` | `[false, false, false, false]` | Extend lines to edges [left, top, right, bottom] |

### Examples

```dart
// Basic crosshair
CrosshairGuide()

// With axis labels
CrosshairGuide(
  showLabel: [true, true],
  followPointer: [true, true],
)

// Horizontal crosshair only
CrosshairGuide(
  styles: [PaintStyle(strokeColor: Colors.blue), null],
)
```
