# Chart Widget Reference

The `Chart<D>` widget is the only public widget in the Graphic library. All chart configuration is declarative via constructor parameters.

## Constructor

```dart
Chart<D>({
  Key? key,
  required List<D> data,
  bool? changeData,
  required Map<String, Variable<D, dynamic>> variables,
  List<VariableTransform>? transforms,
  required List<Mark> marks,
  Coord? coord,
  EdgeInsets Function(Size)? padding,
  List<AxisGuide>? axes,
  TooltipGuide? tooltip,
  CrosshairGuide? crosshair,
  List<Annotation>? annotations,
  Map<String, Selection>? selections,
  bool? rebuild,
  StreamController<GestureEvent>? gestureStream,
  StreamController<ResizeEvent>? resizeStream,
  StreamController<ChangeDataEvent<D>>? changeDataStream,
})
```

## Parameters

### `data` (required)
- Type: `List<D>`
- The data list to visualize. Can be any type — `List<Map>`, `List<MyClass>`, etc.
- When data changes (via `setState`), the chart re-renders automatically.

### `variables` (required)
- Type: `Map<String, Variable<D, dynamic>>`
- Maps variable names to `Variable` definitions. Variable names are used throughout the chart configuration to reference data fields.

```dart
variables: {
  'date': Variable(
    accessor: (Record r) => r.date,
    scale: TimeScale(),
  ),
  'value': Variable(
    accessor: (Record r) => r.value,
    scale: LinearScale(min: 0),
  ),
}
```

### `marks` (required)
- Type: `List<Mark>`
- The geometry marks to render. Multiple marks can be layered.

```dart
marks: [
  LineMark(),
  PointMark(size: SizeEncode(value: 3)),
]
```

### `coord`
- Type: `Coord?`
- Default: `RectCoord()`
- The coordinate system. Either `RectCoord` (Cartesian) or `PolarCoord` (polar/radial).

### `axes`
- Type: `List<AxisGuide>?`
- Axis specifications. Use `Defaults.horizontalAxis` and `Defaults.verticalAxis` for quick setup.

### `tooltip`
- Type: `TooltipGuide?`
- Tooltip configuration. Pass `TooltipGuide()` for default tooltip behavior.

### `crosshair`
- Type: `CrosshairGuide?`
- Crosshair line configuration.

### `annotations`
- Type: `List<Annotation>?`
- Static annotations like reference lines, regions, or custom drawings.

### `selections`
- Type: `Map<String, Selection>?`
- Named selection behaviors. Selection names are referenced in encode `updaters`.

```dart
selections: {
  'tap': PointSelection(dim: Dim.x),
  'zoom': IntervalSelection(),
}
```

### `transforms`
- Type: `List<VariableTransform>?`
- Data transforms applied before encoding: `Filter`, `Sort`, `MapTrans`, `Proportion`.

### `padding`
- Type: `EdgeInsets Function(Size)?`
- Padding from the coordinate region to the widget border. Receives the widget size.

```dart
padding: (_) => const EdgeInsets.fromLTRB(40, 5, 10, 40),
```

### `changeData`
- Type: `bool?`
- Controls behavior when data changes. Defaults to auto-detection.

### `rebuild`
- Type: `bool?`
- Controls rebuild behavior when the widget updates.

### `gestureStream`
- Type: `StreamController<GestureEvent>?`
- Stream for sending/receiving gesture events externally. Useful for coupling multiple charts.

### `resizeStream`
- Type: `StreamController<ResizeEvent>?`
- Stream for resize events.

### `changeDataStream`
- Type: `StreamController<ChangeDataEvent<D>>?`
- Stream for data change events.

## Variable

```dart
Variable<D, V>({
  required V Function(D) accessor,
  Scale<V, num>? scale,
})
```

- `accessor`: Function to extract a value of type `V` from a data item of type `D`.
- `scale`: Optional scale specification for this variable. If omitted, the scale is inferred from the data type (String → OrdinalScale, num → LinearScale, DateTime → TimeScale).
