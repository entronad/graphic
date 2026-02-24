# Varset Algebra Reference

`Varset` (Variable Set) uses algebraic operators to define how variables map to visual position dimensions.

## Creating a Varset

```dart
Varset('variableName')   // From a variable name
Varset.unity()           // Unity element (identity)
```

## Operators

### Cross (`*`) — Assign to different dimensions

Maps variables to different position dimensions (x and y):

```dart
Varset('date') * Varset('value')
// date → x-axis, value → y-axis
```

This is the most common operation. The first variable maps to the first dimension (x), the second to the second dimension (y).

### Blend (`+`) — Combine on same dimension

Combines multiple variables on the same dimension:

```dart
Varset('open') + Varset('close')
// Both open and close map to the same dimension
```

Used for range-based marks like candlestick charts where a single dimension needs multiple values.

### Nest (`/`) — Group by variable

Groups data by a variable's values, creating separate series:

```dart
Varset('date') * Varset('value') / Varset('series')
// date → x, value → y, grouped by series
```

**Nest is required for**:
- Multi-series line/area charts
- Stacked bar/area charts
- Grouped (dodged) bar charts
- Any chart with color/shape mapped to a categorical variable

## Common Patterns

### Single series chart
```dart
// No explicit position needed — auto: first var → x, second var → y
IntervalMark()  // Uses variable order from the map
```

### Multi-series line chart
```dart
position: Varset('date') * Varset('value') / Varset('name')
```

### Stacked bar chart
```dart
position: Varset('category') * Varset('amount') / Varset('type')
modifiers: [StackModifier()]
```

### Grouped bar chart
```dart
position: Varset('category') * Varset('amount') / Varset('type')
modifiers: [DodgeModifier()]
```

### Pie chart
```dart
// After Proportion transform creates 'percent'
position: Varset('percent') / Varset('category')
modifiers: [StackModifier()]
coord: PolarCoord(transposed: true, dimCount: 1)
```

### Candlestick chart
```dart
position: Varset('date') * (Varset('open') + Varset('close'))
// date → x, open+close → y range
```

## Position Auto-inference

When no explicit `position` is set on a mark, Graphic infers it from the variable definitions:
- Variables are assigned to dimensions in the order they appear in the `variables` map
- The first variable → x-axis, the second → y-axis

## Important Notes

- The nest (`/`) operator does NOT create a new dimension — it creates groups within the existing dimensions
- Nest is always applied last in the algebra expression
- The variable used in nest should typically also be used in a `ColorEncode(variable: ...)` to visually distinguish groups
- Without nest, all data points are treated as a single series
