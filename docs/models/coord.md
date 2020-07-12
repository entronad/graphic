## CoordProps

**entries**

`Rect plot`

这一个属性包含了 start（固定左下角）、end（固定右上角），center

`bool transposed`



## Coord

## CoordComponent

**notes**

- coord的主要作用是提供 convertPoint 和 invertPoint 两个函数，其中convertPoint输入是抽象坐标（范围0-1)，输出是绘图坐标，invertPoint相反
- 所有的属性没有联动修改需求，暂时不需要劫持设置访问器
- 对于PolarCoordComponent，plot只决定圆心位置，半径由radius决定

**constructor**

如果有plot，就取plot的左下到右上两点，没有就取直接设置值

**methods**

`List<double> get rangeX`

`List<double> get rangeY`

`Offset convertPoint(Offset point)`

`Offset invertPoint(Offset point)`

## PolarCoordComponent

cfg中的radius和innerRadius都是比例，实际的值用 radiusLength 表示