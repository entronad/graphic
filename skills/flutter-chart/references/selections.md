# Selections Reference

Selections define how users interact with chart elements. They work together with encode `updaters` to create interactive visualizations.

## Selection Base

All selections share these parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dim` | `Dim?` | `null` | Constrain selection to a dimension |
| `variable` | `String?` | `null` | Select by variable value (all elements sharing the same value) |
| `on` | `Set<GestureType>?` | Varies | Gestures that trigger selection |
| `clear` | `Set<GestureType>?` | Varies | Gestures that clear selection |
| `devices` | `Set<PointerDeviceKind>?` | `null` | Restrict to specific input devices |
| `layer` | `int?` | `null` | Rendering layer |

## PointSelection

Selects individual data points (discrete selection).

```dart
PointSelection({
  bool? toggle,
  bool? nearest,
  double? testRadius,
  Dim? dim,
  String? variable,
  Set<GestureType>? on,
  Set<GestureType>? clear,
  Set<PointerDeviceKind>? devices,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `toggle` | `bool?` | `false` | Toggle selection on re-tap |
| `nearest` | `bool?` | `true` | Select nearest point (vs exact hit test) |
| `testRadius` | `double?` | `10` | Hit test radius in pixels |
| `on` | `Set<GestureType>?` | `{tap}` | Triggering gestures |
| `clear` | `Set<GestureType>?` | `{doubleTap}` | Clearing gestures |

**Examples**:
```dart
// Basic tap selection
PointSelection(dim: Dim.x)

// Hover selection (desktop)
PointSelection(
  on: {GestureType.hover},
  devices: {PointerDeviceKind.mouse},
)

// Toggle selection
PointSelection(toggle: true)

// Select all elements with same group value
PointSelection(
  on: {GestureType.hover},
  variable: 'groupName',
)

// Long press selection
PointSelection(on: {GestureType.longPress})
```

## IntervalSelection

Selects a range of data (continuous selection). Used for zoom/pan and brush selection.

```dart
IntervalSelection({
  Color? color,
  Dim? dim,
  String? variable,
  Set<GestureType>? clear,
  Set<PointerDeviceKind>? devices,
  int? layer,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `Color?` | `Color(0x10101010)` | Color of the selection overlay |
| `on` | — | Fixed: `{scaleUpdate, scroll}` | Always triggered by scale/scroll gestures |

**Examples**:
```dart
// Basic interval selection
IntervalSelection()

// Horizontal-only zoom
IntervalSelection(dim: Dim.x)

// Custom selection color
IntervalSelection(color: Colors.blue.withAlpha(30))
```

## GestureType

Available gesture types:

| GestureType | Description |
|-------------|-------------|
| `GestureType.tap` | Single tap |
| `GestureType.doubleTap` | Double tap |
| `GestureType.longPress` | Long press |
| `GestureType.longPressEnd` | Long press end |
| `GestureType.scaleStart` | Pinch/pan start |
| `GestureType.scaleUpdate` | Pinch/pan update |
| `GestureType.scaleEnd` | Pinch/pan end |
| `GestureType.scroll` | Mouse scroll |
| `GestureType.hover` | Mouse hover |
| `GestureType.mouseEnter` | Mouse enter |
| `GestureType.mouseExit` | Mouse exit |

## Using Selections with Encodes

Define named selections on the chart, then reference them in encode `updaters`:

```dart
Chart(
  // ...
  selections: {
    'highlight': PointSelection(dim: Dim.x),
    'zoom': IntervalSelection(dim: Dim.x),
  },
  marks: [
    IntervalMark(
      color: ColorEncode(
        value: Colors.blue,
        updaters: {
          'highlight': {
            true: (c) => c,                    // Selected: keep original
            false: (c) => c.withAlpha(70),     // Not selected: dim
          },
        },
      ),
      size: SizeEncode(
        value: 10,
        updaters: {
          'highlight': {
            true: (s) => s * 1.2,  // Selected: enlarge
          },
        },
      ),
    ),
  ],
)
```

## Programmatic Selection

Use `selectionStream` on marks to set selections programmatically:

```dart
final selectionController = StreamController<Selected?>.broadcast();

// In the chart
IntervalMark(
  selectionStream: selectionController,
  selected: {'mySelection': {0, 1}},  // Initial selection
)

// Programmatically select
selectionController.add({'mySelection': {2, 3}});

// Clear selection
selectionController.add(null);
```

## Selection Patterns

### Highlight on tap
```dart
selections: {'tap': PointSelection(dim: Dim.x)},
// In encode updaters:
updaters: {'tap': {false: (c) => c.withAlpha(70)}}
```

### Highlight series on hover
```dart
selections: {
  'hover': PointSelection(
    on: {GestureType.hover},
    variable: 'series',  // Highlights all points in the same series
    devices: {PointerDeviceKind.mouse},
  ),
},
```

### Tooltip on touch move
```dart
selections: {
  'touch': PointSelection(
    on: {GestureType.scaleUpdate, GestureType.longPress},
    clear: {GestureType.scaleEnd},
  ),
},
tooltip: TooltipGuide(selections: {'touch'}),
```
