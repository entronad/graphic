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

marks和shape到底哪个叫哪个似乎应该再斟酌一下，参考 observable plot，似乎现代库都很喜欢用marks代表图表图形

svg的支持应该再考虑一下

参考库：vega/vega-lite, d3, echarts, plot, tableau, G2

术语：

GeomElement -> Mark：表示抽象的一个系列，今后将不再做区分，不再引入Series的概念

Shape -> Shape：表示图形渲染器，不变，该词常见，放在这里也合适，且保留一些GG的味道

Figure -> MarkElement(ElementStyle)    基类的前缀Mark表示它的作用，使得引擎和图表更融为一体

​         BlockElement(BlockStyle)                                                           ShapeElement(ShapeStyle)

​     LabelElement(LabelStyle)    ImageElement(ImageStyle)           

Aesthetic -> Encode

signal -> event

channel -> stream，controller太泛，先这样，把stream替换channel的观念换掉，细节后面处理

Variable 这一块先不动

figure相关的改造时再考虑，annot系列属于辅助，现在原则上不动

**当发生命名冲突时，第一解决方法是给基类加前缀，因为基类不会被用到，且不影响变量名、子类、相关类用简单的词根，这也是Dart最常用的方式**

**命名原则常见性第一位，避免使用生僻字，长度第二位，除非非常常见短写尽量写全**

**不同层级的不同概念不使用同一个词**

**配套类之间可以不用一样的关键词，比如 PrimitiveElement 配套PaintStyle**

**尽量不用缩写，宁可换用简单的词，同时遵循越常用用越简单的词**

是否使用缩写的依据是，chatgpt能不能从缩写反向推导出原意，比如coord就可以，annot就不可以，内部类可以用缩写







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

lerp的原则是必须都不为null，数组长度一样，所有补全工作都在aes里做 **注意补全要递归的包含GroupElement的子元素**

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

**segments打tag的原则**：complement: 1 shorter 本来就少，所以每个都要用上，必须确保shoter的tag集合是longger的子集，且没有重复，且顺序一致，

现在算法的原则是优先在前面加，但确实会出现用完了的情况（表现为shorterIndex溢出）此时需在后面加

画path且能正常动画的规则（否则动作可能诡异）：

1. 第一个是move
2. tag 不能重复，顺序一致，shorter是longer的子集
3. 需保证对应的tag在对应的contour（指move分隔的gegment组）中，
4. close的出现位置要对应好，否则那一笔直接变为to的，close尽量只负责收尾（没有实际长度）否则容易出问题。

并没有每个segment应用不同style的需求

~~visualMap用clip实现，这就要求element可以clip。scene和element的clip就用shapeelement，不过当shape element被当做clip时，clip、style无效~~

blendmode是需要的，在某些图形重叠时，先就用默认的那种类型，比较符合预期，需要不叠加时自行修改

canvas的分段着色，是通过同一点的不同color实现的。

哪怕是做颜色分界线，也是用 paintingGradient 配合 gradientBoundary 方便

shape 的 stroke和fill再提供上shader，以便图片背景，shader不能lerp

再给shape和image加上个blendMode，因为确实实用，其他的就不加了，影响lerp效率，确实太多了且没用

图表对图形引擎的需求有其特殊性：

1. line 和 smooth line 是大数据的常见图形，可以单独拎出来避免大量segment从而提升性能
2. 由于断点的存在，不会要polyline直接close，line和area都不是这么实现的

因此分出 polygon polyline curve 三种图形，不用close开关将他们合并

盒装约束一律称为bounds，是学的google/charts的

late赋值真香，能避免隐晦的变量覆盖问题

ArcSegment 必须手动保证它的起始点正确

scene.set的函数可以不用命名参数，因为实际使用时都是传入的变量，含义已经体现在变量名上了：

```
scene.set(shapes, coordRegion);
```

由于element有做clip这样的作用，所以还是设个默认的黑线style，所有图形都能看见，image等一般也可不设，所以都加上default的。

之前的shape中图形和label放在一起，然后在element中遍历挑出来，现在改为约定 first group是图形，last group 是label

shape中的图形和标签分别称为 basicElements和 labelElements

原则上尽量避免使用一个Element里面多段（中间出现Move）的情况

由于在mark op里要统一取label，所以强制要求每个shape都要有basic 和label

StrokeStyle 移除，换成更全面的PaintStyle。

先暂时这样：只做elements为null时的填补，不一样长就先不animate。

渐入类型：x, y, xy, size, alpha

对于同一个Mark，应当所有label在所有basic之上，包括不同item和不同group，但不需要所有marks的label在所有marks之上，因为mark是可以进行层级设定的。综合考虑引擎的通用性，最合理的方式应该是分为两个scene渲染，分别通过MarkRenderOp 和 MarkLabelRenderOp，同时shape的渲染函数也分开，这样label的alpha也方便处理，不放在同一个elements里是因为不利于动画diff，不在scene里设置两个elements是因为那样会使scene的判断动画逻辑非常复杂，而且也不够通用。

drawGroupLabels先不限制仅LabelElement，防止需要图标什么的

elements空和null应当相同处理，这个放在RenderOp中，以便与补头一起

还是应该吧primitive和label放在不同的函数中，应当鼓励这样，放在一起处理并不会给性能带来多大提升，好多也是基于过去的思路才写成这样的。

对于 mark-group-item 提醒，primitive对于同一个mark先平铺，因为假如不对齐了，分了也没有意义

graffiti diff 时的规则这样：set不限制是否传null，有任一为null或者不一样长的判断放在_animateElements中，update 的时候，兼容不一样长的情况，normalizeList进行判断，如果不一样长，就返回to

mark entrance 还是不要放在transition里而，因为它是一个完全绑定 mark encode 的概念。就用entrance吧，与ppt一致，而且避免与数据enter冲突

ui.Shader 也和函数一样，不作相等校验，它没有重写等号

函数参数是必填还是有默认的原则应当是：是否有情况是确实不需要（而不是恰好是默认值）

- 故mark的style是必填，没有不需要的，clip是一种特殊情况

- arcToPoint的参数都是必填，因为其实都是要决定的，不存在“没有”

- mark rotation选填，因为确实有不需要的，它与arcToPoint的rotation不同

- defaultAlign 选填，因为有“设了align”这种情况是不需要的

scene的clip不需要entrance

可以用has，它区别于其他动词，其他动词相当于祈使句，它和is一样

要dipose的：stream listen时产生的discription（streamController不要管），animationController

尝试做可视化叙事时的启示：

1. elements diff 时需要有tag进行对应

2. 需要有类似vega signal的东西热更新op参数

segments 和 elements 的tag逻辑是不一样的：

- segments 是前后关联的，顺序和连接关系很重要，elements彼此无关，顺序仅与覆盖有关
- segments的最终结果必须是有序一一对应的，elements可以派生重叠

elements个数不一样的情况太复杂，数据个数不一样时tag也往往都不一样，tag先仅做排序

**elements打tag的原则**：pre和current的tag集合要一致，这样每一个current元素总能找到自己的对应项

tagEncode 先不要搞默认值了，变量情况复杂不要弄巧成拙，只有在手动改变了data顺序对应被打乱了才要

内部工具函数，尽量保留位置参数或必选参数，哪怕填null，减少错误

dart似乎有这样一个规定：当import一般lib（import “library: ... 或文件)时，类名不能冲突。但一个是基础库（例如ui）一个是一般lib时没关系，以一般lib优先。ui.Gradient 和 painting.Gradient 是这种情况，ui.Scene 和 graphic.Scene 是这种情况。原则：凡是和官方库（ui，flutter，painting）冲突的命名都要避免，因此这里也要避免。主要采用增加前缀的方法。因此 View 改为 ChartView，Scene改为MarkScene。至于引擎里的Mark一词是否准确，现在先不想了，这里如果要变体系要变，后面3.0再说吧，这里就这样

Tuple value 应该还是不接受null：1.这是dart null-safety 倡导的原则，2.已经有了accessor这个处理环节

现在这种修改式的 Modifier 实现是不行的，非幂等，https://github.com/entronad/graphic/issues/206 就是非幂等引起的。整个dataflow op的原则必须是函数式的，幂等的。其它倒不是原则性问题，要求幂等正是为了避免其它问题。

类方法的参数，与类成员名字冲突时，将类方法的参数用缩写，特别是含义明确的 withXX，参考Color.withAlpha

至少目前，参数定义的原则涉及多个维度的还是以list定义为主，而不是分开 aaX, aaY这样，比如 CrosshairCuide, list 成员可以为null，以达到一个设置一个不设置的效果，不要搞单独元素指代两个相同这种，取数用 [0] [1]。

之前 scaleEnd 和 longPressEnd 是不含 localMoveStart 的，可能是因为当时为了和flutter的习惯一致。现在的原则是参数尽量给到，而且这里也似乎确实有用。但是它的类目太多太杂，也不用都加上，就update和end加上。