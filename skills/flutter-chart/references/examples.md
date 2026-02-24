# Chart Examples

Complete, runnable chart examples using the Graphic library.

## Basic Bar Chart

```dart
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

class BarChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Chart(
        data: const [
          {'genre': 'Sports', 'sold': 275},
          {'genre': 'Strategy', 'sold': 115},
          {'genre': 'Action', 'sold': 120},
          {'genre': 'Shooter', 'sold': 350},
          {'genre': 'Other', 'sold': 150},
        ],
        variables: {
          'genre': Variable(
            accessor: (Map map) => map['genre'] as String,
          ),
          'sold': Variable(
            accessor: (Map map) => map['sold'] as num,
          ),
        },
        marks: [
          IntervalMark(
            label: LabelEncode(
              encoder: (tuple) => Label(tuple['sold'].toString()),
            ),
            color: ColorEncode(value: Defaults.primaryColor),
          ),
        ],
        axes: [
          Defaults.horizontalAxis,
          Defaults.verticalAxis,
        ],
      ),
    );
  }
}
```

## Interactive Bar Chart with Tooltip

```dart
Chart(
  data: salesData,
  variables: {
    'month': Variable(accessor: (Map m) => m['month'] as String),
    'revenue': Variable(
      accessor: (Map m) => m['revenue'] as num,
      scale: LinearScale(min: 0, formatter: (v) => '\$${v.toInt()}'),
    ),
  },
  marks: [
    IntervalMark(
      color: ColorEncode(
        value: Defaults.primaryColor,
        updaters: {
          'tap': {false: (color) => color.withAlpha(100)},
        },
      ),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
  selections: {'tap': PointSelection(dim: Dim.x)},
  tooltip: TooltipGuide(),
  crosshair: CrosshairGuide(),
)
```

## Grouped Bar Chart

```dart
Chart(
  data: const [
    {'category': 'A', 'group': 'X', 'value': 10},
    {'category': 'A', 'group': 'Y', 'value': 15},
    {'category': 'B', 'group': 'X', 'value': 20},
    {'category': 'B', 'group': 'Y', 'value': 12},
    {'category': 'C', 'group': 'X', 'value': 8},
    {'category': 'C', 'group': 'Y', 'value': 18},
  ],
  variables: {
    'category': Variable(accessor: (Map m) => m['category'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
    'group': Variable(accessor: (Map m) => m['group'] as String),
  },
  marks: [
    IntervalMark(
      position: Varset('category') * Varset('value') / Varset('group'),
      color: ColorEncode(variable: 'group', values: Defaults.colors10),
      modifiers: [DodgeModifier()],
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Stacked Bar Chart

```dart
Chart(
  data: stackedData,
  variables: {
    'category': Variable(accessor: (Map m) => m['category'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
    'type': Variable(accessor: (Map m) => m['type'] as String),
  },
  marks: [
    IntervalMark(
      position: Varset('category') * Varset('value') / Varset('type'),
      color: ColorEncode(variable: 'type', values: Defaults.colors10),
      modifiers: [StackModifier()],
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Horizontal Bar Chart

```dart
Chart(
  data: salesData,
  variables: {
    'name': Variable(accessor: (Map m) => m['name'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [IntervalMark()],
  coord: RectCoord(transposed: true),
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Line Chart

```dart
Chart(
  data: timeData,
  variables: {
    'date': Variable(
      accessor: (Map m) => m['date'] as String,
      scale: OrdinalScale(inflate: true),
    ),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [
    LineMark(
      shape: ShapeEncode(value: BasicLineShape(smooth: true)),
      size: SizeEncode(value: 2),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Multi-Series Line Chart

```dart
Chart(
  data: multiSeriesData,
  variables: {
    'date': Variable(
      accessor: (Map m) => m['date'] as String,
      scale: OrdinalScale(inflate: true),
    ),
    'value': Variable(accessor: (Map m) => m['value'] as num),
    'series': Variable(accessor: (Map m) => m['series'] as String),
  },
  marks: [
    LineMark(
      position: Varset('date') * Varset('value') / Varset('series'),
      color: ColorEncode(
        variable: 'series',
        values: Defaults.colors10,
        updaters: {
          'hoverSeries': {false: (c) => c.withAlpha(100)},
        },
      ),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
  selections: {
    'hoverSeries': PointSelection(
      on: {GestureType.hover},
      variable: 'series',
      devices: {PointerDeviceKind.mouse},
    ),
  },
  tooltip: TooltipGuide(multiTuples: true),
  crosshair: CrosshairGuide(followPointer: [true, false]),
)
```

## Time Series Line Chart

```dart
Chart(
  data: timeSeriesData,
  variables: {
    'time': Variable(
      accessor: (TimeSeries d) => d.time,
      scale: TimeScale(
        formatter: (time) => DateFormat.MMMd().format(time),
      ),
    ),
    'value': Variable(
      accessor: (TimeSeries d) => d.value,
      scale: LinearScale(min: 0),
    ),
  },
  marks: [
    LineMark(
      shape: ShapeEncode(value: BasicLineShape(smooth: true)),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Area Chart

```dart
Chart(
  data: areaData,
  variables: {
    'date': Variable(
      accessor: (Map m) => m['date'] as String,
      scale: OrdinalScale(inflate: true),
    ),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [
    AreaMark(
      shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
      color: ColorEncode(value: Defaults.primaryColor.withAlpha(80)),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Stream Graph (Stacked Area + Symmetric)

```dart
Chart(
  data: streamData,
  variables: {
    'date': Variable(accessor: (Map m) => m['date'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
    'type': Variable(accessor: (Map m) => m['type'] as String),
  },
  marks: [
    AreaMark(
      position: Varset('date') * Varset('value') / Varset('type'),
      shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
      color: ColorEncode(variable: 'type', values: Defaults.colors10),
      modifiers: [StackModifier(), SymmetricModifier()],
    ),
  ],
)
```

## Scatter Plot

```dart
Chart(
  data: scatterData,
  variables: {
    'x': Variable(accessor: (Map m) => m['x'] as num),
    'y': Variable(accessor: (Map m) => m['y'] as num),
    'size': Variable(accessor: (Map m) => m['size'] as num),
    'type': Variable(accessor: (Map m) => m['type'] as String),
  },
  marks: [
    PointMark(
      size: SizeEncode(variable: 'size', values: [5, 20]),
      color: ColorEncode(variable: 'type', values: Defaults.colors10),
      shape: ShapeEncode(value: CircleShape(hollow: true)),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Pie Chart

```dart
Chart(
  data: const [
    {'genre': 'Sports', 'sold': 275},
    {'genre': 'Strategy', 'sold': 115},
    {'genre': 'Action', 'sold': 120},
    {'genre': 'Shooter', 'sold': 350},
    {'genre': 'Other', 'sold': 150},
  ],
  variables: {
    'genre': Variable(accessor: (Map m) => m['genre'] as String),
    'sold': Variable(accessor: (Map m) => m['sold'] as num),
  },
  transforms: [
    Proportion(variable: 'sold', as: 'percent'),
  ],
  marks: [
    IntervalMark(
      position: Varset('percent') / Varset('genre'),
      color: ColorEncode(variable: 'genre', values: Defaults.colors10),
      modifiers: [StackModifier()],
      label: LabelEncode(
        encoder: (tuple) => Label(tuple['genre'].toString()),
      ),
    ),
  ],
  coord: PolarCoord(transposed: true, dimCount: 1),
)
```

## Donut Chart

```dart
Chart(
  // same variables and transforms as pie chart...
  marks: [
    IntervalMark(
      position: Varset('percent') / Varset('genre'),
      color: ColorEncode(variable: 'genre', values: Defaults.colors10),
      modifiers: [StackModifier()],
    ),
  ],
  coord: PolarCoord(
    transposed: true,
    dimCount: 1,
    dimFill: 1.05,      // Slight fill overshoot creates gap
  ),
)
```

## Rose Chart

```dart
Chart(
  data: roseData,
  variables: {
    'name': Variable(accessor: (Map m) => m['name'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [
    IntervalMark(
      shape: ShapeEncode(
        value: RectShape(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      color: ColorEncode(variable: 'name', values: Defaults.colors10),
      elevation: ElevationEncode(value: 5),
    ),
  ],
  coord: PolarCoord(startRadius: 0.15),
)
```

## Heatmap

```dart
Chart(
  data: heatmapData,
  variables: {
    'x': Variable(accessor: (Map m) => m['x'] as String),
    'y': Variable(accessor: (Map m) => m['y'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [
    PolygonMark(
      color: ColorEncode(
        variable: 'value',
        values: [
          Color(0xffbae7ff),
          Color(0xff1890ff),
          Color(0xff0050b3),
        ],
      ),
    ),
  ],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
)
```

## Animated Bar Chart with Dynamic Data

```dart
class AnimatedBarChart extends StatefulWidget {
  @override
  _AnimatedBarChartState createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart> {
  var data = [
    {'genre': 'Sports', 'sold': 275},
    {'genre': 'Strategy', 'sold': 115},
    {'genre': 'Action', 'sold': 120},
  ];

  void randomize() {
    final random = Random();
    setState(() {
      data = data.map((item) {
        return {'genre': item['genre'], 'sold': random.nextInt(400)};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: randomize, child: Text('Randomize')),
        Expanded(
          child: Chart(
            data: data,
            variables: {
              'genre': Variable(accessor: (Map m) => m['genre'] as String),
              'sold': Variable(accessor: (Map m) => m['sold'] as num),
            },
            marks: [
              IntervalMark(
                transition: Transition(duration: Duration(seconds: 1)),
                entrance: {MarkEntrance.y},
                tag: (tuple) => tuple['genre'].toString(),
              ),
            ],
            axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
          ),
        ),
      ],
    );
  }
}
```

## Chart with Annotations

```dart
Chart(
  data: salesData,
  variables: {
    'month': Variable(accessor: (Map m) => m['month'] as String),
    'value': Variable(accessor: (Map m) => m['value'] as num),
  },
  marks: [LineMark()],
  axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
  annotations: [
    // Target line
    LineAnnotation(
      dim: Dim.y,
      variable: 'value',
      value: 200,
      style: PaintStyle(strokeColor: Colors.red, dash: [4, 2]),
    ),
    // Highlight region
    RegionAnnotation(
      dim: Dim.x,
      variable: 'month',
      values: ['Mar', 'Jun'],
      color: Colors.green.withAlpha(30),
    ),
  ],
)
```
