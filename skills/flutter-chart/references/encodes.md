# Encodes Reference

Encodes map data values to visual properties (aesthetics). They are the bridge between data and visual representation.

## Common Encode Pattern

All channel encodes (`ColorEncode`, `SizeEncode`, `GradientEncode`, `ElevationEncode`) share the same parameter structure:

```dart
ChannelEncode<V>({
  V? value,                                              // Fixed value for all elements
  String? variable,                                      // Map from a variable
  List<V>? values,                                       // Output range/palette
  List<double>? stops,                                   // Control points for continuous mapping
  V Function(Tuple)? encoder,                            // Custom encoding function
  Map<String, Map<bool, SelectionUpdater<V>>>? updaters, // Selection-driven updates
})
```

### Three Encoding Modes

1. **Fixed value** — Same value for all elements:
   ```dart
   ColorEncode(value: Colors.blue)
   ```

2. **Variable mapping** — Map data values to visual values:
   ```dart
   ColorEncode(variable: 'type', values: Defaults.colors10)
   ```
   - For **discrete** variables (String/ordinal): `values` items map 1:1 to categories
   - For **continuous** variables (num): `values` defines a gradient range, optionally with `stops`

3. **Custom function** — Full control via a function:
   ```dart
   ColorEncode(encoder: (tuple) => tuple['value'] > 100 ? Colors.red : Colors.green)
   ```

### Selection Updaters

`updaters` change encode values based on selection state:

```dart
updaters: {
  'selectionName': {
    true: (value) => updatedValue,   // When element IS selected
    false: (value) => updatedValue,  // When element is NOT selected
  },
}
```

The `SelectionUpdater<V>` type is `V Function(V)`.

You can provide only `true`, only `false`, or both:
```dart
// Only dim non-selected elements
updaters: {
  'tap': {false: (color) => color.withAlpha(70)},
}
```

## ColorEncode

Maps to the fill/stroke color of mark elements.

```dart
ColorEncode({
  Color? value,
  String? variable,
  List<Color>? values,
  List<double>? stops,
  Color Function(Tuple)? encoder,
  Map<String, Map<bool, SelectionUpdater<Color>>>? updaters,
})
```

**Examples**:
```dart
// Single color
ColorEncode(value: Defaults.primaryColor)

// Categorical colors
ColorEncode(variable: 'category', values: Defaults.colors10)

// Continuous color gradient
ColorEncode(
  variable: 'temperature',
  values: [Colors.blue, Colors.yellow, Colors.red],
)

// With selection interaction
ColorEncode(
  value: Colors.blue,
  updaters: {
    'tap': {false: (c) => c.withAlpha(70)},
  },
)
```

**Note**: `color` and `gradient` on the same mark are mutually exclusive.

## SizeEncode

Maps to the size of mark elements (point radius, line width, bar width).

```dart
SizeEncode({
  double? value,
  String? variable,
  List<double>? values,
  List<double>? stops,
  double Function(Tuple)? encoder,
  Map<String, Map<bool, SelectionUpdater<double>>>? updaters,
})
```

**Examples**:
```dart
// Fixed size
SizeEncode(value: 5)

// Bubble chart: size mapped to a variable
SizeEncode(variable: 'population', values: [2, 20])
```

## GradientEncode

Maps to a `Gradient` fill (Flutter's `LinearGradient`, `RadialGradient`, etc.).

```dart
GradientEncode({
  Gradient? value,
  String? variable,
  List<Gradient>? values,
  List<double>? stops,
  Gradient Function(Tuple)? encoder,
  Map<String, Map<bool, SelectionUpdater<Gradient>>>? updaters,
})
```

**Note**: Mutually exclusive with `ColorEncode` on the same mark.

## ElevationEncode

Maps to the shadow elevation of mark elements.

```dart
ElevationEncode({
  double? value,
  String? variable,
  List<double>? values,
  List<double>? stops,
  double Function(Tuple)? encoder,
  Map<String, Map<bool, SelectionUpdater<double>>>? updaters,
})
```

**Example**:
```dart
ElevationEncode(value: 5)  // Material-style shadow
```

## ShapeEncode

Maps to the shape renderer used for mark elements. Unlike channel encodes, `ShapeEncode` only supports discrete variable mapping (no continuous interpolation).

```dart
ShapeEncode<S extends Shape>({
  S? value,
  String? variable,
  List<S>? values,           // Discrete only
  S Function(Tuple)? encoder,
  Map<String, Map<bool, SelectionUpdater<S>>>? updaters,
})
```

**Examples**:
```dart
// Fixed shape
ShapeEncode(value: BasicLineShape(smooth: true))

// Variable-mapped shapes
ShapeEncode(
  variable: 'type',
  values: [CircleShape(), SquareShape(hollow: true)],
)
```

## LabelEncode

Maps to text labels on mark elements. Unlike other encodes, `LabelEncode` **requires** an `encoder` function — there is no `value` or `variable` mode.

```dart
LabelEncode({
  required Label Function(Tuple) encoder,
  Map<String, Map<bool, SelectionUpdater<Label>>>? updaters,
})
```

**Examples**:
```dart
// Show value as label
LabelEncode(encoder: (tuple) => Label(tuple['value'].toString()))

// Styled label
LabelEncode(
  encoder: (tuple) => Label(
    tuple['value'].toString(),
    LabelStyle(textStyle: TextStyle(fontSize: 12, color: Colors.white)),
  ),
)
```

## Tuple

The `Tuple` type used in encoder functions is essentially `Map<String, dynamic>`. You access variable values by their defined names:

```dart
encoder: (tuple) {
  final value = tuple['myVariable'];  // Access by variable name
  return ...;
}
```
