# Variable Transforms Reference

Transforms modify the data tuples after variable extraction but before encoding.

## Filter

Filters tuples based on a predicate function.

```dart
Filter({
  required bool Function(Tuple) predicate,
})
```

**Example**:
```dart
transforms: [
  Filter(predicate: (tuple) => tuple['value'] > 10),
]
```

## Sort

Sorts tuples using a comparator function.

```dart
Sort({
  required Comparator<Tuple> compare,
})
```

`Comparator<Tuple>` is `int Function(Tuple, Tuple)`.

**Example**:
```dart
transforms: [
  Sort(compare: (a, b) => (a['value'] as num).compareTo(b['value'] as num)),
]
```

## MapTrans

Maps/transforms tuple fields.

```dart
MapTrans({
  required Tuple Function(Tuple) mapper,
})
```

**Example**:
```dart
transforms: [
  MapTrans(mapper: (tuple) {
    final newTuple = Map<String, dynamic>.from(tuple);
    newTuple['normalized'] = tuple['value'] / 100;
    return newTuple;
  }),
]
```

## Proportion

Calculates proportional values within groups. Essential for pie charts.

```dart
Proportion({
  required String variable,
  Varset? nest,
  required String as,
  Scale? scale,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `variable` | `String` | **Required** | Variable to calculate proportion of |
| `nest` | `Varset?` | `null` | Grouping variable for nested proportions |
| `as` | `String` | **Required** | Name of the new proportion variable |
| `scale` | `Scale?` | `LinearScale(min: 0, max: 1)` | Scale for the proportion variable |

**Examples**:
```dart
// Basic proportion for pie chart
transforms: [
  Proportion(variable: 'sold', as: 'percent'),
]

// Then use in mark position:
marks: [
  IntervalMark(
    position: Varset('percent') / Varset('genre'),
    // ...
  ),
],
coord: PolarCoord(transposed: true, dimCount: 1),
```

## Transform Order

Transforms are applied in the order they appear in the list:

```dart
transforms: [
  Filter(predicate: (t) => t['active'] == true),  // First: filter
  Sort(compare: (a, b) => ...),                     // Then: sort
  Proportion(variable: 'value', as: 'pct'),         // Finally: calculate proportions
]
```
