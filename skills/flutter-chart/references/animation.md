# Animation Reference

Graphic supports transition animations when chart data changes or elements first appear.

## Transition

Controls the animation between states.

```dart
Transition({
  required Duration duration,
  Curve? curve,
  bool repeat = false,
  bool repeatReverse = false,
})
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `duration` | `Duration` | **Required** | Animation duration |
| `curve` | `Curve?` | `null` | Animation curve (e.g., `Curves.easeOut`) |
| `repeat` | `bool` | `false` | Repeat the animation infinitely |
| `repeatReverse` | `bool` | `false` | Reverse on each repeat cycle |

Set on individual marks, not on the Chart widget:

```dart
IntervalMark(
  transition: Transition(
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOut,
  ),
)
```

## Entrance Animation

Controls how elements animate on their first appearance. Set via the `entrance` parameter on marks:

```dart
IntervalMark(
  entrance: {MarkEntrance.y},  // Bars grow from bottom
)
```

### MarkEntrance Values

| Value | Effect |
|-------|--------|
| `MarkEntrance.x` | Animate from x=0 position |
| `MarkEntrance.y` | Animate from y=0 position |
| `MarkEntrance.size` | Animate from size=0 |
| `MarkEntrance.opacity` | Fade in from transparent |

Multiple entrance effects can be combined:

```dart
entrance: {MarkEntrance.y, MarkEntrance.opacity}  // Grow up + fade in
```

## Tag for Element Matching

The `tag` parameter creates identity correspondence between elements across data changes, enabling smooth morph transitions:

```dart
IntervalMark(
  tag: (tuple) => tuple['id'].toString(),
  transition: Transition(duration: Duration(seconds: 1)),
)
```

When data updates:
- Elements with matching tags **animate** from old position to new position
- Elements with no matching old tag **enter** with entrance animation
- Old elements with no matching new tag **exit** with reverse animation

**Important**: Without `tag`, elements are matched by index, which may not produce the desired animation for reordered data.

## Dynamic Data Updates

Simply update the data via `setState()`. When `transition` and `tag` are set, the chart animates smoothly:

```dart
class _MyChartState extends State<MyChart> {
  var data = [...];

  void updateData() {
    setState(() {
      data = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Chart(
      data: data,
      // ...
      marks: [
        IntervalMark(
          transition: Transition(duration: Duration(milliseconds: 800)),
          entrance: {MarkEntrance.y},
          tag: (tuple) => tuple['genre'].toString(),
        ),
      ],
    );
  }
}
```

## Repeating Animations

For continuous animations (e.g., loading indicators, pulse effects):

```dart
Transition(
  duration: Duration(seconds: 2),
  curve: Curves.easeInOut,
  repeat: true,
  repeatReverse: true,  // Bounce back and forth
)
```

## Common Animation Patterns

### Bar chart entrance
```dart
IntervalMark(
  transition: Transition(duration: Duration(milliseconds: 600)),
  entrance: {MarkEntrance.y},
)
```

### Fade-in scatter plot
```dart
PointMark(
  transition: Transition(duration: Duration(milliseconds: 400)),
  entrance: {MarkEntrance.opacity},
)
```

### Animated data sort
```dart
IntervalMark(
  transition: Transition(duration: Duration(seconds: 1)),
  tag: (tuple) => tuple['category'].toString(),
)
// Then sort data and call setState
```
