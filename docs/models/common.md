## TypedMap

*mixin*

**notes**

- copy系列的方法并不需要，可通过 `a.mix(b)` 实现

- 关键是_map中成员的覆盖关系: 

  1.不得出现值为null的记录，这点通过 setter、 构造函数、赋值运算符进行确保

  2.b中出现的记录覆盖a中的记录（不管a有没有），b中未出现的和a一致
  
- deepMix的定义：其它直接mix，map和TypedMap混入

- typedMap.deepMix 和 map_util.deepMix 都有可能含有混入值的引用

**members**

`Map<String, Object> _map`

**methods**

`TypedMapMixin mix(TypedMapMixin src)`

`TypedMapMixin deepMix(TypedMapMixin src)`

`Iterable<String> get keys`

`Object operator [](String k)`

`void operator []=(String k, Object v)`

`bool operator ==(Object other)`

这其实就是diff方法，规则，遇到Map和Iterable就遍历

## Component<S extends TypedMap>

*abstract*

**members**

`S state`

**constructors**

`Component([TypedMap props])`

将originalState赋值给state，混入默认state，混入props

构造函数是否需要传入props根据实际情况而定

**methods**

`S get originalState`

*protected*

子类需要实例化具体的state类型，通过重写此方法实现

`void initDefaultState() {}`

*protected*

混入默认值，一般在此方法中保证那些需要的state不为null