**animation**

动画主要有三种方式：

1. 类似CSS那种将动画指令直接接在代码后面（重点是定义是直接改变动画值）

2. 定义某个变换transformation，它告诉如何将一个状态过渡到另一个状态（D3，重点是transformation是包含结束状态的）
3. 定义初始和结束状态，以及其中的过渡transition，因此这个 transition 可以更简洁，不用像transformation那样包含结束状态，而且状态和过渡可以更好的分离

data change 只作用于mark，它的机制基于 D3 data join

---

Adobe AE 动画思路

AE 分为贝塞尔曲线和属性图形，两者不可兼容

基本思路还是关键帧之间的属性变化

总的要求必须是帧之间同类型、一一对应，数值变化

出现和消失也只是属性的改变

图形类型：矩形、圆角矩形、椭圆、多边形、星形

基本图形可以转变为贝塞尔，但是不能再转回去，贝塞尔可增加或删除点

---

有一个基本思路，就是图形都可以转变为贝塞尔曲线，少的补完到多的，通过贝塞尔曲线之间变换

贝塞尔曲线也不能拟合一切，比如圆弧，还是存在误差，角度越大误差越大，要不就用穷举法



## TODO

area gradient 超出coord region的问题

Label还是LabelAttr 支持null

整合errorlog，需处理：throw, assert, list.single，singleIntersection

后续两大方向：

animation

树状等其它数据结构，实现treemap、桑基图等类型





感觉针对数组的可定制回调函数参数还是应该带上index，这个需求挺实际的，不要信了dart的鬼

原则：减少概念，增加flexibility，无论从理论到实践，都应该把flexibility、extensive作为首要目标

思考declaration和transformation的关系，D3认为专注transformation有助于提升性能。D3在底层的transformation上还有declarative的helper

d3这种称为 embedded domain-specifific language

从实践的角度讲，ticks很重要，特别是在缩放情况下



是不是可以把 shape提取出来，和geom合并？



似乎 selection updater 也应该改为和signal updater类似的多参数的

SignalUpdateOp 值得好好看看，似乎很多问题藏在其中。现在的想法是当initialValue和signal两个op都没有触发时，它也应该没被触发，还保留前值。



一个很重要的问题是定制，采用注册还是传入处理实例的问题，例如 modifier 的定制。全可定制是否应当用全部继承组合的方式



感觉还是应该区分 null 和 NaN的

Echarts式的encoding似乎挺需求的。



图形由顶点（vertice）和线段（segment）构成？见atlas论文



一个重要问题：用的人越多，可配置性就变的越重要（比如阴影细节，线条交点细节），人多到一定程度甚至成为第一重要（或者说可配置性好用的人才多？D3？）



感觉还是必须是一个“图表库”，像d3那样底层不现实，不过要强化基础能力，以便提供更丰富的配置，和定制化可能性



现在的工作采取渐进式，先添加动画功能，再尝试树和图，最后优化语法



一个基本的感觉，一些实验性的东西，主要是为了数据科学家（author）做 prototype exploring，对于开发者似乎不那么重要（还是说方便需求切换？）



从issue看，多数据源似乎是真实需求，vega也具有，似乎应该实现



region => viewport ?

signal ? event ? 在vega中它们有着不同的含义

自变量范围称为domain，因变量范围称为range

曲线称为easing



为图形（annotation等）增加事件挂载，它独立于selection的数据检测体系







## 论文

与gg的区别：shape

interaction 和 animation

flutter的图形系统是成立的基础（见d3论文）

d3论文强调符合标准的作用，网络效应，考虑图形引擎的基础以canvas图形标准来

d3也强调 declarative 的好处，是能与实现分离，各管各的

d3的精髓就是将数据映射为dom

data join 的目的是，如果保持不变的参数在enter设置，动态的在update更新，所有变化都可以设置动画

d3也承认 don't get it original, get it right 的原则，虽然核心很精简，但要能处理常见任务，解决的办法是modules

图元：graphical primitive

d3 中通过各种layout来定义各种布局类型

benchmark还是要对比不同的，比如d3就对比了flash

利用 dart canvas 其实是一个和d3一致的优点

tidy data 论文中有对数据名词的解释，以及常分为number和string

avl 中将动画分为功能更强大的stream和更简洁的encode，分开应对不同需求，值得借鉴

vega的selection也是用的转换坐标在数据空间搜索的方法



## Transition

两段贝塞尔曲线结合，如果前者的后控制点与后者的前控制点关于结合点对称，则是光滑的



命名可适当使用多音节词，原则上不过早优化，先用简单的词，直到遇到冲突了再决定改哪个

PathSegment -> PathMark -> Mark -> Serise(Shape)



现在图形设置的原则，先以实用为主，反正这个也不是最终的。

两种arc定义方法，一个适合mark，一个适合segment

以path的分类为准，添加 line， cricle，sector，（polyline就是polygon没有close）

rXX 和 XX 合并

除了text和image的称为primitive

两个大原则，一是不过早优化

二是自行根据需要设计，不以参考dart本身API为原则，因为它本身就是很自用的，而且dart api本身很乱不一定好。

由于需要使图元具有shadow 和 dash，以及之前的graffiti机制已经论证了每个图元一个path还行，因此图元采用基于path的。

oval还是需要的，因为你必须保证path的addXX都能实现，基本图形的设置原则保证path的所有功能都能实现

polygon 和 polyline 还是不区分吧，因为强调一个必须性和简洁性结合，同理rect和rrect。

shadow 的 transparentOccluder （都是true就行了，防止是透明的）和 dash 的offset感觉没什么用，为简洁先不要了，特别是dash那个还要定义个类。以后要了再加

选择分支，优先将简单的写在前面，标识值也尽量以此原则设置

绘制时实际path的边数与toBezier等计算无关

sector的参数，还是要用start-end的形式（end和sweep就是一个简单的加减关系），与我们整个体系相统一，不受dart约束。不应该设置clockwise，它永远为true，同时为统一，arc也采用这种定义

由于现在radius的start和end也是对等的了，所以no inner也不用特殊处理了，也不用过度优化这种情况。

现在text已经满足不了动画的需求了，需要类似label的功能

从issues来看，自动shadow颜色还是比较成功的，border倒是有需求

我们现在需要一个功能很强大的图形引擎，将现在总结的一些经验固话下来，因此相对渐变定义、边框等都需要放到mark中了，

功能全部往强大了整，比如shadowColor不设置就自动计算，也可设置，dashOffset也可设置，borderGradient也可设置，gradientBounds也可设置

添加自定义的MarkStyle，文字还是搞一套text层级的东西，text和label不是一个层级的，最大的区别是label要和anchor和align合起来才能绘制

ShapeStyle中，由于是简单图形，那一大堆渲染的东西都不需要了，都默认，不过描线相关的还是要的

由于叫shape了，相当于默认是fill，是否有stroke的标识是strokeColor或strokeGradient，是否有shadow的标识是elevation，是否要dash的标识是dash。

Mark及相关属性的差值方法都是为动画准备的，也叫lerp，它的特点一是不接受null，而是以后一个为准

图形的形变保留一个rotation，因为其它的不需要，可通过位置或长宽来定义，旋转在一些场合比如极坐标里还是挺有用的。因为shape里可能有其他轴，所以这里叫rotationAxis

paint 一般表示被调用的，draw一般表示实现，是保护类型

mark的style还是采用继承加泛型的这种体系，文字用label，采用较高层级的这种形式，更实用一些，没必要再分两层

由于mark体系都是final的，text的layout可以放在构造函数里，避免每次paint都要layout

rotation到底是否是style比较复杂，既可以理解为是也可以理解为不是，但是 rotation axis 与绝对位置有关，不能直接放在style里。如果统一rotation放style里，axis放mark里，有点蠢不便于理解。如果都放在外面，lebel的设定就白费了。这本质上是高级api和低级api的矛盾，高级api是采用achor, offset, center, align的体系。

我们原则上尽量采用高级api，兼顾功能全面性和简明性。

实事求是的将，对于图形，rotation和axis放在外面又简洁又灵活，对于label，将rotation的设置并入style最好，就采用这种方案了。image模型和label一样(主要指与左上角offset相关，采用anchor体系)，它俩合称box

style的参数尽量采用可选加默认值的方式

paintPoint需要复杂的初始化，在构造函数中初始化，设置成late

boxstyle的align可以为空，mark需要可设置defaultAlign

boxmark 永远有rotation axis，它是anchor + offset，它表示实际偏移后的anchor，不仅用于旋转。

image长宽像素比那先做个放着后面做实验

scene 的clip先只支持rect

scene 似乎完全不要子类，只要将sublayer 作为参数传入就行了

---

**Dart 新 feature**

需要缩小实现函数参数的范围，用covariant 关键字，它既可以放在父类也可以放在子类或都写，最好父类写了子类自动有，都有。还可以修饰访问器

枚举类可以带参数了

late关键字还能起到懒加载的作用，在定义式前面加个late，只有在用到时才会初始化

用 [0, ...?list] 处理可能为null的情况

集合添加现在可以用 if 和 for了：

```dart
var nav = ['Home', 'Furniture', 'Plants', if (promoActive) 'Outlet'];
```

```dart
var listOfStrings = ['#0', for (var i in listOfInts) '#$i'];
```

Symbol：#bar

同一个个实例的成员方法相等，不同实例的成员方法不相等。函数、静态方法相等

对于二元运算符，符号调用的是左边那个的

---

PathMark中的segment用id来标识主要，没有id的就是次要

sector 除了segments外还是保留原始信息吧，lerp也用原始信息，因为原则就是这样

polygon的定位，还是以多边形为主，复杂的line还是需要Path里的segment，所以规定至少两个点，差值先采用一个简单的尾部追加。

close命令是关闭到最后一个subpath

决定segment 仅支持absolute，relative没什么意义，可自行增加原点。而且非常麻烦

conic 有理贝塞尔曲线的近似，别管是不是，用端点连线的中点与控制点来确定权重移动点，转换为二阶贝塞尔曲线

一种号称最高效的浮点数精度问题处理：() * 10 ** 9) >> 0) / 10 ** 9) 右移0是去除小数

动画：

~~line和area的图形也分item似乎是关键~~

~~出现消失单独处理~~

~~采用树状的 group-child似乎是关键，可以采用类似custompaint, textspan那种的嵌套？~~

~~考虑用树的目的是避免用id检索时的算法复杂度，可以直接递归，但是不够的还是要补全的。~~



~~规则：~~

1. ~~采用类似textspan的那种树，考虑用树的目的是避免用id检索时的算法复杂度，可以直接递归~~
2. ~~区分出现、消失、过渡动画，引擎仅负责处理过渡，出现消失在外面数据层面处理，根据“x, y, xy, size, alpha”的规则创建影子~~
3. ~~过渡补齐，给定画布坐标系的x、y、xy，alpha，size变换方法，其中size的限制比较大~~



感觉初始化和消失放在aes里处理比较好

树状结构，但是不混用，group是单独的

lerp的原则是必须都不为null，数组长度一样，所有补全工作都在aes里做

复杂图形，到底是一个group里多个mark还是pathmark中多个segment，一个重要的依据是style是否相同

group lerp的时候，必须保证子元素也同构，转换的过程在toFrame中。这样toFrame似乎应当对集合的以便递归。

实在难匹配的就直接到to或者中间插个透明帧

目前scene的mark和clip都是出现在同一个地方的，可以在update中要求一起更新

可以animate的前提是view不能rebuild，所以只有事件会触发动画（changeData，resize，gesture）

有原来的view向上通知widget repaint，改为view通知graffiti，graffiti 通知各个scene开始动画，scnene中的函数调用 widget 进行animate

flutter setState之后并不会调用didUpdateWidget，因此不用区分animate，直接都是repaint

上下游动作术语：修改scene叫set，因为它并不会触发任何动作，update会误解。算完之后view通知graffiti再通知scene的函数叫update，scene执行update进行更新或执行动画之后调用上层传入的函数叫repaint

async 函数返回值 Future<void> 和void的区别是void不能跟在await后面，所以尽量用Future<void>。

animationController的stop好像是暂停，重置要用reset，一般只add一次listener

不需要delay了，interval能起到这个作用

setState 在一次同步中多次调用好像是没事的，所以每个scene里都没有动画时都调用repaint是可以的。

pathMark lerp的时候必须是已经nomalize过的。

segments 统一化的规则：

1. 目的是尽可能多的tag对上
2. 先按move分成多组，组的补充是在后面简单的加
3. segments的规则是少的补到多的，以多的按序索引，类型相同

segments 必须以mov开头

还是不要把end作为segments的统一属性吧，因为close这里会存在误导，正确性大于优雅性，搞个getEnd()方法，正好arc的也不需要在构造函数里每次算。

complement: 1 shorter 本来就少，所以每个都要用上，必须确保shoter的tag集合是longger的子集，且没有重复，且顺序一致，

画path且能正常动画的规则（否则动作可能诡异）：

1. 第一个是move
2. tag 不能重复，顺序一致，shorter是longer的子集
3. 需保证对应的tag在对应的contour（指move分隔的gegment组）中，
4. close的出现位置要对应好，否则那一笔直接变为to的，close尽量只负责收尾（没有实际长度）否则容易出问题。