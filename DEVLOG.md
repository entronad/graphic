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