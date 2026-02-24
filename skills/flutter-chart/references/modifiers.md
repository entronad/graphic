# Modifiers Reference

Modifiers handle collision and arrangement of geometry marks when multiple elements share the same position.

## StackModifier

Stacks elements on top of each other. Used for stacked bar charts, stacked area charts.

```dart
StackModifier()
```

No parameters. Stacking accumulates values along the y-axis (or angle axis in polar coords).

**Requirements**: Must use the nest (`/`) operator to define groups.

**Examples**:
```dart
// Stacked bar chart
IntervalMark(
  position: Varset('category') * Varset('value') / Varset('type'),
  color: ColorEncode(variable: 'type', values: Defaults.colors10),
  modifiers: [StackModifier()],
)

// Stacked area chart
AreaMark(
  position: Varset('date') * Varset('value') / Varset('type'),
  color: ColorEncode(variable: 'type', values: Defaults.colors10),
  modifiers: [StackModifier()],
)
```

## DodgeModifier

Places elements side by side (dodges). Used for grouped bar charts.

```dart
DodgeModifier({
  double? ratio,
  bool? symmetric,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ratio` | `double?` | `1 / group_count` | Width ratio of each element within the category band |
| `symmetric` | `bool?` | `true` | Whether to center the group |

**Examples**:
```dart
// Grouped bar chart
IntervalMark(
  position: Varset('category') * Varset('value') / Varset('group'),
  color: ColorEncode(variable: 'group', values: Defaults.colors10),
  modifiers: [DodgeModifier()],
)

// Custom dodge ratio
DodgeModifier(ratio: 0.8)
```

## JitterModifier

Adds random displacement to elements. Used for strip plots and avoiding overplotting in scatter plots.

```dart
JitterModifier({
  double? ratio,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `ratio` | `double?` | `0.5` | Proportion of the local neighborhood for jittering |

**Example**:
```dart
// Jittered scatter plot
PointMark(
  modifiers: [JitterModifier(ratio: 0.3)],
)
```

## SymmetricModifier

Centers elements symmetrically around the midpoint. Used for stream graphs (ThemeRiver).

```dart
SymmetricModifier()
```

No parameters.

**Example**:
```dart
// Stream graph (stacked + symmetric area)
AreaMark(
  position: Varset('date') * Varset('value') / Varset('type'),
  shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
  color: ColorEncode(variable: 'type', values: Defaults.colors10),
  modifiers: [StackModifier(), SymmetricModifier()],
)
```

## Combining Modifiers

Modifiers are applied in order. Common combinations:

| Combination | Effect | Use Case |
|-------------|--------|----------|
| `[StackModifier()]` | Stack | Stacked bar/area |
| `[DodgeModifier()]` | Side by side | Grouped bar |
| `[StackModifier(), SymmetricModifier()]` | Stack + center | Stream graph |
| `[JitterModifier()]` | Random scatter | Strip plot |
