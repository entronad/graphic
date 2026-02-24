# Scales Reference

Scales map data values (domain) to visual values (range). They are specified on `Variable` definitions.

## Scale Inference

If no scale is specified on a variable, Graphic infers the scale type from the data:
- `String` → `OrdinalScale`
- `num` → `LinearScale`
- `DateTime` → `TimeScale`

## LinearScale

For continuous numeric data.

```dart
LinearScale({
  num? min,
  num? max,
  double? marginMin,
  double? marginMax,
  String? title,
  String? Function(num)? formatter,
  List<num>? ticks,
  int? tickCount,
  bool? niceRange,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `min` | `num?` | Auto | Minimum domain value |
| `max` | `num?` | Auto | Maximum domain value |
| `marginMin` | `double?` | `null` | Extra margin below min as ratio of range |
| `marginMax` | `double?` | `null` | Extra margin above max as ratio of range |
| `title` | `String?` | `null` | Scale title (used in tooltips) |
| `formatter` | `String? Function(num)?` | `null` | Format values for display |
| `ticks` | `List<num>?` | `null` | Explicit tick values |
| `tickCount` | `int?` | `null` | Desired number of ticks (hint) |
| `niceRange` | `bool?` | `null` | Round domain to nice numbers |

**Examples**:
```dart
// Fixed range
LinearScale(min: 0, max: 100)

// With formatting
LinearScale(
  formatter: (v) => '\$${v.toStringAsFixed(0)}',
)

// Nice range with margin
LinearScale(niceRange: true, marginMax: 0.1)

// Custom ticks
LinearScale(ticks: [0, 25, 50, 75, 100])
```

## OrdinalScale

For discrete/categorical data (strings).

```dart
OrdinalScale({
  List<String>? values,
  bool? inflate,
  double? align,
  String? title,
  String? Function(String)? formatter,
  List<String>? ticks,
  int? tickCount,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `values` | `List<String>?` | Auto | Explicit ordered category values |
| `inflate` | `bool?` | `null` | Add padding at start/end of axis |
| `align` | `double?` | `null` | Alignment within each category band (0-1) |
| `title` | `String?` | `null` | Scale title |
| `formatter` | `String? Function(String)?` | `null` | Format category labels |
| `ticks` | `List<String>?` | `null` | Explicit tick labels |
| `tickCount` | `int?` | `null` | Desired number of ticks |

**Examples**:
```dart
// Explicit category order
OrdinalScale(values: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])

// Inflated for line charts (adds padding at edges)
OrdinalScale(inflate: true)
```

## TimeScale

For temporal data (DateTime).

```dart
TimeScale({
  DateTime? min,
  DateTime? max,
  double? marginMin,
  double? marginMax,
  String? title,
  String? Function(DateTime)? formatter,
  List<DateTime>? ticks,
  int? tickCount,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `min` | `DateTime?` | Auto | Minimum date |
| `max` | `DateTime?` | Auto | Maximum date |
| `marginMin` | `double?` | `null` | Extra margin before min |
| `marginMax` | `double?` | `null` | Extra margin after max |
| `title` | `String?` | `null` | Scale title |
| `formatter` | `String? Function(DateTime)?` | `null` | Format dates for display |
| `ticks` | `List<DateTime>?` | `null` | Explicit tick positions |
| `tickCount` | `int?` | `null` | Desired number of ticks |

**Examples**:
```dart
// With date formatting
TimeScale(
  formatter: (date) => DateFormat.MMMd().format(date),
)

// Fixed time range
TimeScale(
  min: DateTime(2024, 1, 1),
  max: DateTime(2024, 12, 31),
)
```

## Scale on Variable vs Encode

- **Scale on Variable**: Controls the data domain mapping (value → normalized position)
- **Values on Encode**: Controls the visual range (normalized position → color/size/etc.)

```dart
variables: {
  'price': Variable(
    accessor: (d) => d.price,
    scale: LinearScale(min: 0, max: 1000, formatter: (v) => '\$$v'),
  ),
},
marks: [
  PointMark(
    color: ColorEncode(
      variable: 'price',
      values: [Colors.blue, Colors.red],  // Visual output range
    ),
  ),
]
```
