主要的业务类分为 component, state, props 三种，三者之间的联系通过泛型

**component**

- 作用是对props内的数据进行操作，通过state 这个成员持有state
- 基本架构采用响应式变更
- 哪些字段作为state的原则是单一数据源原则，由state计算得到的变量称为关联变量，作为类的成员，通过setter/onSet机制进行更新和缓存，setter/onSet按需定义
- 关联变量设为内部变量，获取通过getter，防止修改
- 不涉及关联变量的state可直接修改
- 在 engine 中直接命名，在其它添加 component 后缀
- component的方法分为绘制和配置，绘制只管根据state实现paint()，配置负责所有操作

**state**

- 作用是持有数据
- 混入 TypedMap
- 命名添加 state 后缀
- 原则上一个component类对应自己的state类，没有新增字段的可直接用父类的state，继承关系相同
- 所有state都只有默认无参的构造函数

**props**

- 作用是为用户接口使用
- 混入 TypedMap
- 包含type字段，并以其类型作为泛型
- 需要可变，因为从用户输入的props到实际灌注给component，中间可能要有些修改，不宜放在component中，比如scale中values，在component中视为必须的，用户不传时在scaleController中根据data生成
- 本身没有作用，通过混入props起作用，一般用于component的构造函数、creator、addXX(), 如没有这些需求可没有props
- 命名上以用户使用直观为准
- 具备树状diff的功能