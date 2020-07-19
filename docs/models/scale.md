目前看从代数的角度scale应该分成三类：

1. identity：返回固定值，无需定义运算符

2. category：无序类目，定义等号（直接用 = ）
3. ordinal：有序类目，定义大于
4. linear：线性，定义四则运算

这个分类是与类型无关的，我们先每一个找一种代表性的，并将props定义为比较常用名称的。

## ScaleState<V> with TypedMap

**entris**

`String Function(V) formatter`

`List<double> scaledRange`

`String alias`

`int tickCount`

`List<V> ticks`

这个值如未设置将自动重算



## ScaleComponent<S extends ScaleState> extends Component<S>

translate 只有cat中算index要用

当values没有传入时，需要自动计算以下，这个感觉不应该放在scale中，应该放在scaleController中



核心概念：

value指通过Accessor从Datum中获取的值，V

scaled指scale计算结果，cat类型必须是0-1，linear中可为倍数，double

text值value在坐标轴label上展示的文字，String



坐标轴实际需要的ticks的value，对应的scaled、text在使用时即时获取

**methods**

`double scale(V value)`

将value转换为scaled

`V invert(double scaled)`

将scaled转换为value

`String getText(V value)`

计算value的text

