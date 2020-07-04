主要的业务类分为 component, props, cfg 三种，三者之间的联系通过泛型

**component**

- 作用是对props内的数据进行操作，通过props 这个成员持有props
- 仅包含方法，和内部变量
- 在 engine 中直接命名，在其它添加 component 后缀

**props**

- 作用是持有数据
- 混入 TypedMap
- 命名添加 Props 后缀
- 原则上一个component类对应自己的props类，继承关系相同
- 所有props都只有默认无参的构造函数

**cfg**

- 作用是为用户接口使用
- 混入 TypedMap
- 不可变，通过meta.immutable 注解实现
- 本身没有作用，通过混入props起作用，一般用于component的构造函数、creator、addXX(), 如没有这些需求可没有cfg
- 命名上以用户使用直观为准
- 具备树状diff的功能