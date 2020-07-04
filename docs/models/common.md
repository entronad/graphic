## TypedMap

*mixin*

**notes**

- copy系列的方法并不需要，可通过 `a.mix(b)` 实现

- 关键是_map中成员的覆盖关系: 

  1.不得出现值为null的记录，这点通过 setter、 构造函数、赋值运算符进行确保

  2.b中出现的记录覆盖a中的记录（不管a有没有），b中未出现的和a一致

**members**

`Map<String, Object> _map`

**methods**

`TypedMapMixin mix(TypedMapMixin src)`

`TypedMapMixin deepMix(TypedMapMixin src)`

`Iterable<String> get keys`

`Object operator [](String k)`

`void operator []=(String k, Object v)`

## Component<P extends TypedMap, C extends TypedMap>

*abstract*

**note**

- 所有的Component都从此类继承，包括engine.Element
- 所有需要持久化存储的成员都放到props中，本身仅包含访问器和内部成员

**members**

`P props`

**constructors**

`Component([C cfg])`

将defaultProps赋值给props，并混入cfg，cfg为可选的

**methods**

`P get defaultProps`

