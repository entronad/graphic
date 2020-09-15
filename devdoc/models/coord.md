## CoordState with TypedMap

**entries**

`Rect plot`

坐标绘制区域，决定坐标系特别是直角坐标的最主要状态

`bool transposed`

x、y是否颠倒

## Coord

## CoordComponent

**notes**

- coord的主要作用是提供 convertPoint 和 invertPoint 两个函数，其中convertPoint输入是抽象坐标（范围0-1)，输出是绘图坐标，invertPoint相反

**methods**

`List<double> get rangeX`

x的抽象值的范围

`List<double> get rangeY`

y的抽象值的范围

`Offset convertPoint(Offset point)`

将抽象点转为绘制点

`Offset invertPoint(Offset point)`

将绘制点转为抽象点

`void setPlot(Rect plot)`

`void onSetPlot()`

## PolarCoordState

**entries**

`double radius`

范围0-1表示外圈占plot短边的比例。注意polar coord的坐标范围归根到底还是plot决定的，radius只表示占用plot的多少

`double innerRadius`

`startAngle`

`endAngle`

## PolarCoordComponent extends CoordComponent<PolarCoordState>

**deriveds**

`double _radiusLength`

实际圆圈的半径，方便其他组件使用

`Offset _center`

坐标圆心，为plot的中心，只有上半圆这一种特殊情况取plot的下边中点。