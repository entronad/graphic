# 校准

**f2**

2020-05-07 53015838e13575236aaba3be1b0ad2ef1e83b4b7

**scale**

f2的scale版本定格在了 0.1.x版本

branch v0.1.x

2020-03-12 f6830e0d8f63cbd1329afec2082596d65e4851ac

**adust**

tag 0.1.0

2019-02-11 047fb21014b8f1abbbfd648b034d53ff430540c0





总原则：以 f2 和 easth 为标准和基础尽快实现

任何想优化现在的Attrs和Cfg的想法都是失败的

chart 的构造函数函数中option字段传入的东西，都是以 XXCfg 的类型，其本身的参数直接以命名参数传入



改造 TypedMapMixin 不在乎初始化时的性能，可能是个伪命题，保证 [] 是不会添加多余的value为null的，其构造函数与成员可不对应，构造函数优先满足用户使用，所有defaulCfg中的内容都放cfg里，但不一定放构造函数里



统一一下，destroyed 一律称为 destroyed; 需要用到的地方以 cfg 里为准



Cfg划分与继承的颗粒度，以用户使用方便为准，比如scale就用统一的cfg

api设计原则勿增实体，比如 Range 就不要单独建个类型，就用数组，取其first和last

不过枚举还是尽量用枚举，除了用户可自定义注册的



由于图表组件类不再对外暴露，名字可以详细点



原则上字段都应该放在 cfg 中，只有 外界不会用到、与cfg中的字段重复的才会作为对象字段（比如 _dateFormat)，并定义为内部变量



原则上 api 中明确表达坐标或位移的，用Offset，其它表示两个点的直接用 List<double>



xxCreators 可尽量放到基类做静态成员

xxNum xxStr 这样的变量名一般用户类型强转，取值一般用 xxValue 这样



TypedMapMixin时候具有null覆盖默认值的功能？好像是具有的，这就实现了某些参数有非null的默认值，但显式的设为null表示没有



将 engin 中的类也按所有字段都放到cfg中的原则处理，除了内部工具变量，且移除cfg的构造函数中不必要的。chart中新添加的需要用的字段也放在 cfg 中



关于 event、animate、plugin的理解：plugin是f2的重要机制，event、animate的拓展都依赖于它。



内部的 XXCfg 尽量用级联的构造函数，确保所有字段统一。



TypedMapMixin 需要一个与Map连接的方法，此方法只可以set，不可以mix，只有TypedMapMixin可以mix，先不加，但感觉会需要用到



# Attrs, Cfg

将paintCfg和TextCfg单独出来搞

deepMix 只处理

## Element

f2 中只有 text 用到 _afterAttrsSet 我们不需要这个

只有 paint 和 repaint用paint 关键字，其它还叫drawXX

'canFill'  'canStroke' 我们不要

如果按照我们现在处理path 和paint 的方式，也不需要 resetCanvas

f2 中在cfg中也有个x，y，是专供moveTo形变用的

f2 的 clip 处理没看明白，还是单独搞个类似g的方法吧，感觉这样更干净些

clip的transform的应用存疑

element 是没有 context 之类的东西的，其与上下文唯一的联系是canvas

destroy 方法中把 cfg 重置为 null



## Shape <- Element

考虑到扩展性，type用字符串

shape似乎需要 isClip 和 endState 这两个外挂的成员变量

自定义直接传 path

## Text <- Shape

兼顾富文本和穷文本形式，出现 textSpan 为富文本，text 和 textStyle 为穷文本，富文本优先级高于穷文本

## Container <- Element

在 element.setClip 中会保护 cfg 为null 的情况，但 container.addShape中没有保护

add 方法仅作添加一个使用的，故不需要做数组的处理了。



## Renderer <- Container

还是改名叫 renderer 吧，语义更明确一些，不与实际的 canvas 混淆



## Animator

缓动函数采用 curve

f2的动画分为群组动画和精细动画，我们只需要精细动画

f2中是通过原型链为chart 和 shape 等添加 animate 方法的，

动画机制觉得还是采用g中的比较好，进行一定的简化去除暂停功能

f2中动画的onStart, onUpdate, onEnd 感觉比较比较多余，还是和g一样仅保留onFinish

全局对象Animate类似于Shape是一个用来



## Geom

geom 是图表组件，每个geom对应同名的 shapeFactory

包含关系是

area --> area, smooth

interval --> pyramid, funnel

line --> line, smooth, dash

point --> rect, circle

polygon --> polygon

schema --> candle custom



## Base

为避免构造函数中传参给父类发生丢失的问题，默认配置最好以 defaultCfg 的形式配置

还是采用一个非常抽象的Base类的方案，所有的都从其继承，f2中base的功能分摊给chart和geom各自

## Scale

auto 中的功能先依原来的

linear 的泛型是 double

几个工具函数参数类型的处理同 aesth ，translate 返回值类型为 num，子类根据实际选择 int,double

TODO: 我感觉由于scale限制了传入类型，这里面的几个工具方便不需要这么复杂，先按 aesth 的做，今后考虑简化

关于 timeCatScale 的mask问题，目前看来只能 规定不能直接修改 cfg.make 来处理



## Attr

所有的 field 仅支持乘法不支持数组

一个 attr 可能对应多个 field，所以没有 F 泛型

color的线性化只可使用默认的配置

TODO: attr 的 linear 和 scale 的 linear 之间的关系要再好好理一理，

目前来看ColorAttr已经具有根据scale类型判断是否线性化了，并且是通过 Color.lerp 进行渐变的，无需定制和指示

改造统一的 getLinearValue函数，支持stops

TODO: mapping 方法的输入和返回类型还要再看看。mapping 方法中的params是原始数据项中的值组成的数组，可能为不同类型，返回值应该是List<V>, 不过在position中可能为List<V>也可能为 List<List<V>>

从 geom 的描述中看，mapping 的返回值只有在position中是嵌套数组，其它都是一维数组



## Coord

在aesth 之后，coord 添加了 scale 的功能，也不太常用，先用个List<double>吧

直角坐标系统一用 Rect 关键字，不用 Cartesian



## Adjust

用户仅需指定类型，故 cfg 无构造函数

antv/util 中的 merge 就是单层 flattern

processAdjust 不需要返回值，直接就着原数组改

aesth 的 dodge 中 的 Range 用 List<num>代替

## Geom.Shape

container 就是指的 engine.Container

draw 方法中的 cfg 就是用来传入 attr的

ShapeCfg 仅内部使用，无需构造函数

目前来看，这个style 就是 engine.Attrs

shapeFactoryBase 中的 getShapePoints 方法中，无法做到通过是否有函数判断，改为都运行一遍以结果是否为null判断

因为 涉及到 _coord ，ShapeBase 和 ShapeBaseFactory 必须是可实例化的，由查询到的 creator 决定实例化成什么子类的实例，每个实例是平等的（重复的），其实例方法根据传入的 cfg 绘图

本质上ShapeBase 和 ShapeBaseFactory的实例是一个个在子类间重复平等的构造器

drawShape里要记得加个默认的全局颜色

在 g2 中，ShapeFactory也是多实例的，它是通过geom中获取后再clone来实现的，factory需保存coord

一个 geom 对应一个单独的 ShapeFactory 实例，该实例有个内部 shapes 列表存放 shape 的实例，getShape方法没有就创建

我们还按照原来的思路来，全局单例中的键都是creator geom中使用的factory和shape都建自己独立的实例。

coord 要供子类等使用，不能设为内部

engine.shape 只负责提供 paint 方法，geom.shape 的draw 方法通过 addShape 添加 engin.shape 并触发重绘，其返回值是添加的Shape

drawShape 系列是要可add并返回多个shape的

TODO: 需要考虑 addShape 等触发的重绘的合并

dart 不具备直接运行脚本的功能，要重新理一下

在graphic 中用户最直观操作的是 Chart 类，且最先被执行的是 Chart 的构造函数，~~因此这样Shape不再是全局单例，而是每个Chart配一个，这样用户通过继承Chart重写 extraShapeFactories 和 extraShapes 进行注册，其值依然是 creator 实际的 factory和shape实例由geom持有~~，Shape依旧保持全局单例，但是注册的过程不是放在脚本上，而是每个Chart（或者其State）的构造函数上

area 中的 createPath 中将topPoints 和bottomPoints合了又分主要是为了

TODO: geom.shape.drawShape中的逻辑很奇怪

geom.shape 里的数据结构是这样：x: double , y: List<double> 这里面暗含了函数一个 x可对应多个 y 

splitPoints 就是用来将这样的一个 x/y 对转换为 List<Offset> 的

但是好像 x 也可能是数组，还是先都用数组吧

geom.shape.line 中的points结构比较奇怪，我感觉它里面其实不是用的points，而是 直接用的data类型，但我还是假设有处理好了points

isInCircle 的意思好像是在极坐标系下

geom.shape.point 绘制图形是 attrs.r 即为 shapeCfg.size

geom.shape.point 中的drawShape里似乎不要循环，取x/y 的 first 就行了

目前来看，其实并不鼓励用户 registerFactory ，geom 的 factory 通过type 确定， shape 通过shape 确定，不过factory类型还是先用字符串，假装用户会注册自定义 factory 那样

GeomCfg 中的attrs，attrOptions分别是Attr和AttrCfg的映射表，不过在GeomCfg的构造方法中是直接通过 position, color 等参数进行设置的，类型是 AttrCfg

感觉Geom的类型和ShapeFactory的类型是一一对应的，且不可扩展的，还是把它定为枚举吧，并且GeomCfg 的 type 和 shapeType 都归并到一个type

将path类型和line类型合并

## Geom

container 先就用 Container类型，f2中暗示是Canvas类型

**addShape, addGroup, group.addShape 触发重绘的机制都是通过触发事件，renderer监听事件实现的，因此只要是container的方法都可以触发重绘**

将 styleOptions 的类名和字段名都改为styleOption，且其中持有字符串形式的 field字段

从geom开始要注意要添加配置式的设置

按现在Base中Cfg的泛型，原来的destroy方法比较难弄，干脆就把cfg搞成null

类似G2，在内部依旧叫colDefs，只是在初始化图表时的字段叫scales

似乎 Datum.origin是只包含数据Map的，先按这个理解来

Datum还是不要搞成类为好，就用Map<String, Object> 处理，配合一些强转，

为什么用Map<String, Object>而不用Record是因为我们最希望兼容的是用户输入的Map<String, Object>

_processData() 最后的 self.emit('afterprocessdata', { dataArray }); 十分妖，目前看没什么意义，~~先不管~~，反正现在有了 innerEvents, 把它先添加上。

f2 中的 paint 方法为避讳，改为draw方法，原来的draw方法改为drawData

getCallbackCfg 有一段如果style中某值是函数就调用算出值的逻辑，我们不这样

getCallbackCfg、getDrawCfg 一系方法，最终都是为了得到shapeFactory.drawShape方法中的Cfg，它是个ShapeCfg，因此以此为目标进行考虑

在 drawShape 中关于给engin.shape 的 engin.cfg 添加 origin 的事先不整这事，如果真的需要的话添加个 extra 的Map<String, Object>字段放这些东西。Area Geom 中的drawData方法中也意思要ShapeCfg中有origin，也先不整这事

这样处理，在geom中传递的，是名为data的Map<String, Object>结构，不仅仅是原始数据，还包括所有丰富的内容，需要思考的是怎么传进去以及怎么获取出来交给 ShapeCfg

_normalizeValues 中对单一值和数组的处理似乎就是x y类型的根源，这里我们统一以数组处理，根据数组元素个数判断

一个geom看来是只能设置一个 adjust 的

line中的drawData在获取points时需要用到splitePoints的艺能

在 _createAttr方法中，geom将scales传给了它的attr

## Axis

结合guide来看，top还是单独做一个参数好

getTextAlignInfo先只管textAlign这一个属性

将 grid 中的type移到 AxisCfg 中，用 AxisType 代替

abstract 中的好几个函数都要传参，但感觉不应该需要传参，直接用 cfg 里的，后面看看为什么

还是把这个 top 加入到 PaintCfg中吧，不过不需要mix到attrs中

createAxis方法中循环的时候new Axis但不返回好像是因为 Axis的构造函数里有draw()，但在我们的架构下这样行不行？

## ChartController

感觉plot就是个Rect，不需要单独的类

plot,rangePlot 指的是Rect

fontPlot，middlePlot，backPlot 指的是感觉应该都是Group

感觉plot和rangePlot 一样的，先统一成一个plot

独立的 chart.[geomType]方法改为合并到 addGeom中

chart.coord()方法仅有cfg参数，type包含在其中

render(), repaint() 似乎是给外部用户用的，回头需要看看合理性

DataFilter参数不加index了，dart中针对list的参数一般不带index

## Theme

采用 Theme 为可实例化的类，Global为其实例的形式

scales好像没用，先不搞

padding 为null时是auto，zero为0

shapes、sizes等是作为默认的Attr的

TODO: 要处理好Cfg中非null默认值的问题

## ScaleController

综合使用和性能来看，chart.scale方法的参数为Map<String, ScaleCfg>

_getScaleCfg 这个方法里的的某些条件判断似乎是为了不同形参表准备的，可能存在问题

## AxisController

由于涉及到 circle 的问题，axis position 就先用字符串类型

dimType 似乎只在 AxisController 内部使用，先用字符串类型

TODO: f2中常常强调textAlign 和 textBaseline，要看一看这个 textBaseline 怎么处理

## Chart, ChartState, ChartController, Renderer

一个 ChartState持有一个 chartController，chartController在initRenderer方法中新建一个Renderer，state、controller、renderer三者是一一对应的关系

在参数设置上，将Widget本身就作为一个Cfg

chart的animate可以仅用一个bool，具体的动画具体配置

ChartCfg中的参数名先也用缩写。

绝大部分情况不需要repaint，repaint需要一个标志判断是否触发，这个称为 mounted ,方法mount

ChartCfg 与 ChartControllerCfg 需相互独立开，但需校验一下保证字段对应一致

先按必须手动输入 width，height 的方式来，changeSize系列也回头再研究

renderer的drawInner，bbox可以和group一起合并到container中，paint主要通过drawInner实现

ChartController 作为中间桥梁，renderer

renderer中第一次赋值 _painter 先放到 mount 中

所有主动修改的方法都为 renderer.repaint()

ChartController的构造函数也传入ChartCfg



## API

api 中的类使用段名字，实体类加后缀

笛卡尔坐标系用 Cartesian

数据感觉还是要采用List<Datum>的形式，并需要 fieldMapper

允许用户输入的数值泛型应当是 num, 然后内部需要double的时候用 num.toDouble

!!!: 泛型是很重要的，但要用好





f2的element中的attrs的初始化不太好，感觉就用最朴素的方法的就可以了



1. 引擎和controller分离
2. paint 和 addShape 分离
3. component 持有关系需厘清



采用"同位参数"的方式解决参数类型的灵活性：

目前好像就一个地方：padding 和 autoPadding 的地方，内部 assert 不能同时存在以提示使用

插件注册通过同位参数传入 creator的方式处理

有限改造内容：

1.实体名称：XXX, XXXComponent

2.坐标 Rect 改为 Cartesian

3.参数泛型

4.同位参数

5.shape的register机制改为传入creator的同位参数

6.Component和Renderer职责分离

7.theme放到chart参数中

8.Datum的读取

package:meta/meta.dart 中的 protected, required 注解很有用 



命名改动：绘图引擎称为 engine ，因为它既是一个与chart业务无关，又是抽象的不是flutter渲染机制的东西，它提供实际的 painter , repaint 函数

所有的东西称为 XXXComponent，XXXProps，XXXCfg，chart中XXXCfg 直接称为XXX 为方便用户使用，

Chart本身的参数直接用命名参数，不打包成对象，主要是为了接口更简洁更符合常例

engine中尽量使用Renderer的词汇，（painter容易与系统混淆），chart中尽量使用Component，Controller的词汇

cfg，props，delegate可能要分开，感觉delegate名字比renderer好，因为不是所有的都要render，比如attr，coord，scale



通过CustomXXXChildLayout 和 XXXChildLayoutDelegate 可以设置和获取子元素的位置、大小，解决自动布局问题，chart不再有width、height参数，通过父元素限制，也一定是autoFit

chart和controller的沟通应该不应该保留renderer

方位使用 Alignment 表示

事件分为Gesture、LifeCicle，分别管理

需要研究一下是否需要props，从为什么要props的角度考虑（构造函数可以不用参数，是否需要clone？遍历props）

必须要props的理由：

存在大量“仅保存props”，“追加混入props”的需求

严格区分props和cfg，cfg是immutable的

engine中的attrs方法依然叫这个吧，因为主流引擎都叫这个

engine中的shape改名为RenderShape

所有element都需要attrs，因为有clip，matrix等container也需要

engine中destroy方法的作用：1. 从父节点上移除自身，2.解除对当前props的引用，改为一个只有destroyed = true的props。

我觉得我们没有必要有此 destroy方法和destroyed 类，只要有remove就行了，此外renderer要有一个一定会被执行的dipose方法，在widget的dipose中调用，处理ticker等东西

暂时不觉得element里需要renderer

凡是构建RenderShape的函数，都只需要Attrs，并以Attrs的类型确定RenderShape类型

给component设置访问器需审慎，尽量直接通过props操作

对于matrix不搞transaction这一套东西了

变形还是用回Matrix4吧

所有方法要有意识的确定是归于“设置”还是“执行”

关于remove方法，就是简单的解除在父元素中的引用，因此element中就是从parent.children中remove，而container的clear方法就是children.clear()

将group和container合并，称为group

diff感觉仅仅cfg需要用到

clip我感觉仅需要path就行了，顶多设置的时候可以以Attrs为参数，而且它的形变应该和它本身的形变一致，这样Element 也不需要额外的setClip方法了，clip设置直接也用attr()方法

由于dart中的构造函数不可继承，所以感觉对于仅给参数赋值的构造函数，并不需要在抽象类中实现

所有有可实例化子类的Component的type也在props里，RenderShape的类型是由Attrs决定的，故要增添个加到props里的方法

对于子类普遍需要实现的方法，应该父类方法抽象，特殊的子类去空实现。防止误写super.xxx()

所有props中的集合类型成员的处理有两种原则：一是初始化时就默认有个空数组，使用时无需判断null，还有一种是默认为null，仅在添加第一个元素是没有就创建，使用时无需判断null。我们采用第一种，因为f2总体也用的第一种，需要用null的几种情况感觉也主要是attrs和cfg需要

flutter/painting 中似乎又有dart:ui又有vector_math,不过我们现在还是仅在小范围使用

判断1矩阵还用 == 吧，比较直观，不差那点性能

canvas的transform是应用到绘制完的图形上的，而path的transform仅作用到路径上，即path的变形不会影响线宽等表现。

我总的来讲还是使用canvas的变形，bbox的计算粗略一点。

给本文件内的类使用的函数，命名为内部函数

smooth的时候constraint为什么是1,1？

由于TextSpan, TextStyle, StrutStyle 都定义了等号，可不拆开来，拆开来太麻烦了

同位参数的检查仅在构造函数中使用，原则上只防外部使用者

引擎的基本架构思路是，以attrs为渲染的基础，用attr()方法会触发重算，需要重算的放在onAttr中

~~尽量避免父类中出现空的方法体，这是为了避免是否需要调用super.xx()父类方法时困扰，同时实现时起到提醒的作用，不过这样做如果父类的方法要实现了，记得思考下子类要不要加super.xx()~~

原则上有返回值的函数，父类不要有空的函数体（返回null）；没有返回值的函数可以有空的方法体，子类加上super.xx()

zIndex 和什么时候排序需要再研究一下。

不想为空的属性尽量通过在构造函数中的required规约，减少不必要的默认值赋值，仅规约用户的行为

通过path.getBounds 计算bbox，在弧线设置了startAngle的时候、贝塞尔曲线段数多了之后会有误差

polyline中是否需要filterPoints 存疑？

smooth方法中，points的很多点要重复用到，先转换好避免重复转换

coord的scale貌似从来没有被用到，先不管

区分x、y两个维度变量的命名采用 xxX, xxY

更新的本质是有一些props关联依赖于另一个的props，而又不希望每次取用时重新计算，类似于缓存，只有当props改变时通知重新计算，这类要注意一点就是props要是比较“基本的”，不是很引用的变了不会通知到，比如children。

取消attrs，只要props，

取名props，state，component更接近react

不需要作为state的要么做成内部变量，关联变量，要么做成getter

外界要想触发重算，需通过setState，或add等方法

内部全部或某个方法需要改变的，用

state的标准：外部要设置/访问，持久化存储，不可由其他state推导出

type一律在子类中写死getter，不属于state，props中有

输入参数的校验尽量在props中用required，但如果必须参数不出现在props中，则在component的构造函数校验，构造函数的输入都为任意typedMap，不与props有类型上的联系

update 内部使用和外部使用还需要考虑一下

所有cache尽量用内部变量加getter的方式获取，防止修改

~~可能还是要vector2表示点，vector3没必要，vector4没有左乘操作。所有具象的旋转等只针对matrix，根据Vector2变换的需要选择合理的vector。~~

注意vector_math中的postMultiply是旋转的逆，而应用到矩阵就是正常的乘号，m4可乘以v3，故矩阵一律使用m4，点用v3

m4的angleToSigned的计算结果与z轴的正负向有关。Dart中的三维坐标是左手坐标系（与标准的右手坐标系不同），即z轴正向指向纸面

注意vector_math本身的angleToSigned只能计算 -pi 到 pi，因此需要包装工具类

要把vector、matrix等是否为0，单位矩阵都写在工具里，按需写

所有的setter/onSet全部一事一议，包括构造函数中是否调用，没有关联变量的直接可设置不需要setter/onSet

element的变形的更新还有优化的空间

给所有中间变量赋值的函数称之为 assign() ,如果出现一般构造函数中需要调用

coord的plot一律设置，不好通过构造函数设置，构造函数传入props

可实例化的component要注意一下构造函数的要求

私有成员不应当被测试，因为测试不关心实现

需要有一个Accessor，获取值，值的类型泛型用V表示，数据项的泛型用D表示：

field 指字段的字符串标识，String

value指通过Accessor从Datum中获取的值，V

scaled指scale计算结果，0-1，double

text值value在坐标轴label上展示的文字，String

V的类型只许两种，String（cat， identity）和num（linear）其它的在 accessor中转换。这样是合理的因为：可视化只接受可表示的数据即String，linear用num是利用了其线性计算，并且可方便的转换为String，对于scale的算法无需区分double和int，time_cat相当于添加了些日期操作的工具函数。

scale 中tick都是指的value，要用到的tickObject中的其它信息通过scale就地获取

参数比较多的内部函数为表达清晰，尽量使用命名参数

scale中numberAutoTicks 中的maxLimit, minLimit 好像是完全不需要的

IdentityScale的作用是处理未设置的字段

LinearScale中的snapArray好像不需要

对于数字类型的，在判断端可能出现三种情况，null, infinity, finity, 原则上在计算时，只判断是否为null，防止程序异常，只有在绘制图形时，才对infinity进行处理，原则上当为null时也返回null

对于所有的scale，是无法限制传入的值的（null, 不在类目中，不合法的时间字符串，nan）所有这一切都返回null，在消费处处理，invert认为传入的scaled都是合法的，不判断null

所有的层级的state要有自己的类，哪怕不增加新内容了，也要定义个空的子类，比如 CartesianCoordState

运算符命名：逻辑用动词加介词，运算直接用动词

由于不能保证formatter中用户的行为，所以干脆 scale.getText() 不保证非null

autoTicks方法要抽取出来，放在可实例化的子类中实现

state中的项是可更改的。onSet中的处理，一定要坚持其处理仅根据当前state，而不依赖于传入props的特征的原则，因此当需要根据某项值是否为null进行处理时，set前要清除，否则mix后还是原来的值

shapeAttr中的shape指的是geom.shape ，我们也用枚举，同时

shapeAttr先不做，等到geom确定下来再说

数组range型的需要判断一下长度

各个类型的props还是要定义一个统一的，方便用户接口定义

fields感觉还是需要attr持有的，这也正是geom唯一需要用到的地方，或者说field唯一的用处

accessor可以合并到scale中，这样一是减少概念类别，而是可以规约V的类型，这样在定义时，D通过chart的泛型规约，V通过scale的泛型规约，这样缺点就是scale需要增加个D的泛型了

在chart中控制renderer的配置的相关方法使用render关键词，实际的绘制方法使用paint、draw关键词

表示绘制范围的用 region 表示，绘制的group用plot表示

Paint类型的样式，变量名就用style

包裹多个键值对的类（为了类型）称为Record

RenderShape也应该遵循props最简的命名原则，因为addShape()和Shape中的使用也是配置式的，而node、group、renderer由于没有props就不改了

当Paint属性中style为fill时，strokeWidth就无效了，不会填充到边界

为确保视觉的一致，stroke类的图形size要把线宽减掉

y0的处理：不放在AttrValueRecord中，保持其纯净，以数组形式给出

Shape函数由于需要暴露给用户定义，尽量保证传进来的是好值无需内部处理

y0 用 startPositions 来代替，因为意义更合理方便扩展，而且很可能是取的另一组geom的postions，

Attr中的position是抽象的概念，coord.convertPoint应该放在shape中

极坐标系下的interval这样处理：南丁格尔：所有data均分坐标总角度，半径正常处理，饼图：将x的scaledValue加权分配角度，半径统一。南丁格尔图可堆叠，饼图不可堆叠

funnel 和 pyramid 的唯一区别是一个最后收到0，一个最后保持柱状

他们其实是和柱状图原理一样，但要注意图形填充在坐标之间，最后的效果依赖于坐标轴翻转、对称调整，确保数据层次嵌套

funnel系列也和柱状图一样的处理，position的x位于图形的中间

对坐标系有限定的用assert判断

在目前的思路下，坐标区域的region并不一定就是绘图区域的region，到时候可能需要用bbox之类的东西根据实际确定

为方便，极坐标下的rect也先按直线绘制（和f2一样）

pyramid、rectPolygon等position传进来时，需保证已按顺序排好

position 返回一组Offset，默认的是将前两个scaledValues转变为一个Offset，如需特别的（比如SchemaGeom中）需在formatter中自定义

position中的点与startValues没有关系

schema的特点是在一个图元上显示多个数据

geom 中data是单独的setter/onSet

f2 中geom中区分data的group的标准是：定义了某个非position的attr，这个attr的某些scale是cat类型

因此分group的fields就是：出现在其它attr中并且不在position中（accessor、scale是有默认值的），先只支持一维，先按shape，后按color，后按size

field的根本依据是attr的定义式中的标定，不过最好在scales中有定义，accessor有默认值根据字符串键取Map，根据取到的值的num、String、DataTime不同，确定默认的scale



Props应当仅起到构造函数和setter传入参数的作用，所有实际持有的应该是state，包括一些附带的东西，比如attr中的fields、scale中的accessor也应该存放在state中

对于Component中间变量的修改，尽量直接修改无返回值型的

先按全部重新计算，不搞中间变量的方式进行计算

adjust比较麻烦，因为对于Datum, 我们没有办法去set它，也没有办法去复制新建它，把它放到不是处理data，而是处理position好像就比较好了

感觉不需要y0了，y0的功能，一部分应该由adjust完成（point，line，area，box），一部分应该由position数组承担（interval），

每个shape传入的position已经是按要求组好的，如何组position的规则根据geom类型不同，由defaultPositionMapper决定，优先级低于 PositionAttr.mapper

box、candle等图形的特殊性完全通过PositionAttr进行处理，传入多个field，如何组织points通过callback定义

interval的定义就是有两端的，分别用数组的start和end

dataGroup的同一组data必须是具有相同的shape，shape的传入参数也是一整条data的records

slopedInterval用多次的方式，因为一般数据数组不会太长。

adjust还是要做成Component的模式，因为在props中设置

在f2中传递给shape的size比较乱，interval中是归一化的，point中是绝对值。用户设置的values是绝对值，因此我们认为传入的也为绝对值，如需转换为相对值则在shape中结合coord处理。

Adjust调整应该仅与归一化后的position有关，因此仅保留dodgeRatio参数，默认均分

XXX的总数（int）一半用 totalXXX命名

送进adjust中的group里每个list长度要一致，x要对应

感觉reversed不应该作为stack的独特的选项，而是group顺序是按照groupfield的scale的values（如果有）的顺序来的

values的原则是，如果有，则顺序、数量都按照它来，如果没有则按照数据里出现的数量、顺序

stack的关键是要正负分别分组，用第0个point的y作为标志

adjust的规则：将position中的所有均匀分布在y轴两侧，如果只有一个点就前面加个0（这时只有分布的band有意义）

只有一个点的position称为single，有多个点的称为multi，注意area一般是single，经过symmetric之后是multi

对于geom的更新，自身属性引起的更新通过setter中调用render，外部（chart）变化引起的通过外部调用render。先搞个只要变化就全量更新

geom在render后要将持有的renderShape保存，便于下次清除

大型component（包括renderer, geom, chart）持有其他component，且通过传入props构建，何时变更渲染需要精细控制，故不通过构造函数传入props，setter一般只负责更新state和中间变量，不负责render

目前感觉geom中还是传入整个chart，以保证chart的参数变化后的关联性



props缺失的情况：

attr没有：chart中每种类型由对应的默认attr，position必须设置

attr没有field：singleLinear返回values的第一个，position必须设置

attrs没有values：color取theme的默认值，shape，size每个geom有默认值

scales没有对应field：任何在attr中定义了的field都必须要有scale，因为需要accessor

categoryScale没有values：必须要有~~（scale是与data无关的，不建议从data中获取）~~ values缺失的还是要从data中取的

好像已经都在geom中处理了，chart中无需额外处理



props的继承链还是需要完整的，但是可以不用依赖构造函数的继承链

Attr有两种形态，一种是处理用map处理，一种是返回固定值（values的第一个值），通过是否有fields区别，

colorAttr中的默认values长度，要与对应feild的scale的values的长度进行联动

geom中的defaultSize应该是一个固定值，某些interval不需要size或size需要根据step定，则返回null，然后在shape中处理

SingleLinearAttr一般是和values数组顺次对应的，还有一种gradient是在中间取间值的

要有一个变量表示values是补间的，不过处理是在geom中是否将attr的values补到和scale一样

每种shape可分为仅可绘制cat，仅可绘制linear，和兼容cat和linear

cartisien坐标系下cat类型不靠在边上，是通过默认是通过range，目前scale本身就有这个功能



目前遇到一个state中两个字段默认值相互联动的问题，主要是scale中的ticks和scaledRange，不仅构造函数中要弄，改变字段时也要弄。感觉对于 setProps用全部清0法比较好

catScale在两边留白的问题：还是必须在scale中处理，因为scaledValues需要与ticks配套，即scale的结果就已经包含了留白，

留白策略由scaledRange控制，values、scaledRange在scale创建时在外面进行检验初始化，cat，cartesian是 [ 1 / count / 2, 1 - 1 / count / 2 ]，polar是[0, 1-1/n]。凡是cat默认会留白，但是用户也可以手动设置scaledRange使其不留白

props和state哪个可以更改还需要再考虑考虑

理论上某个field或scale是无法确知自己在positionAttr中被设为x还是y，

xFields, yFields 由chart持有，主要作用是给axis用，它由所有的geom的对应值合成，每个geom的对应值存放在positionAttr中，每个geom有对应的默认初始化方法，当mapper为null时进行初始化

TypedMap有一个很重要的作用是复写 == 号

有定制style需求的地方：shape、axis的line/tickLine/grid、

每个axis默认的position也需要Controller控制

transpose后那个轴垂直哪个轴水平也由Controller控制，Axis只管视图

Axis中所有的初始值都在Controller中设置

label的位移通过transformLabel方法实现，注意初始位移的公式要考虑文字方向，offset和rotation为null时不位移

极坐标没有tickLine

radiusAxis没有蜘蛛网，不太合逻辑

circularAxis的offset如果需要根据角度自行调整，需要设置callback，初始调整根据象限



chartComponent的作用

根据组件宽高确定 coord region

初始化 scales，重要的是确定values

初始化 axis



先不要controller了，后续再总结提取

Widget的更新顺序是：执行build方法，获取size，执行paint方法，所以chartComponent对外暴露一个update方法，其中会调用 _render() 方法，更新renderer上的组件，然后在paint时执行，因此将设置size，update的过程放在paint中

每个scale必须手动指定，因为不知道Datum的结构，scale中accessor也是必须指定的，要做的是确定values或（min，max），确定类目轴的 scaledRange，（dateTime）特殊



确实要考虑好data、geoms为空的情况

一个指导思想：在Datum为有类型的类的大背景下，获取field是一个必须被定义的行为，因此 scales，position和position中的field是必须的（因为认为scales中的field是无序的）

chart管理axes的模式是，首先根据coord、geom确定xy各一个默认的axis，以及检索props对应的field确定是否需要创建和mix，然后再创建其它设定的axes

AxisComponent需要添加一个 mixProps的方法，这是AxisComponent的特殊性决定的，它没有关联变量，一切计算依赖render方法，使用时确实有mix的需求

Axis要有就要指明，没有默认

一个field可能既作为x，又作为y axis

linearScale 中的 max 和min 是必须的

size/margin/padding 属性包含在coord region信息中，chart不持有

所有state清零的地方，要重新init，合成一个 resetState() 方法

adjust 之后的scale先手动调整

同一个geom中的不同records，原则上是越在前面的越易显示，故添加RenderShape时倒过来



对于adjust 和 symmetric的理解：

adjust之后，将改变scaledValues中的position，但是要用到对应的值（如tooltip中）时需用原始数据

adjust应该是支持串联的，但有顺序要求，先不做

symmetric仅支持相对于原点轴，它会使原records的所有y变为一半，并生成一个新的records，与变化后的原records对称

对于某些需要起点的图形，采取这样的方案：每一个scale有一个原点origin字段，每个geom的originPoint由xy的第一个scale的origin构成，传递给shape

stack堆叠的量是前值position中所有点最高（距离原点最远）的

关于绘制对称图（河流面积，漏斗）有两种对称方案，一种是adjust的时候，position一点变为两点两半同时绘制，还有一种是shape中只绘制一般，adjust中会复制出另一半的records，我们采用后者，因为这样同一种geom的position结构不会变化，架构更稳定清晰，adjust更抽象

chart的三个plot的作用

back：盛放axis，范围是整个组件

middle：盛放geom，范围是coord region

可控制scaledRange前后值的大小，控制坐标轴方向

注意group只可依据category scale

scaledRange是个比较常用的参数，还是改回叫range吧

标签的旋转要以中心，否则会歪，高度自己通过offset调整

CatScale要判断一下，如果不用在position中就还是 0-1

Component 中的 setXXX 要做到所有需要依赖的东西都作为参数传入，不能直接内部获取，方便在setProps中统一管理顺序

axis的top应该放整体，否则又麻烦又没意义，变成肉夹馍

props的混入时的null处理，比较复杂

~~从机制上讲，可能要把“构造函数中显式的设为null表示没有，没有显式的设置就用default”这种机制取消掉，因为函数传参时是无法分辨显式设置null还是没有设置的~~

~~所以原则应该是：对于必须存在的东西，比如coord，catScale.values, scale.range，设有默认值，没有就是默认值，~~

~~对于可有可无的东西，必须设置了才会有，不设置就没有，取值可到defaultTheme中去找，然后同 ..的方式修改，这就要求props也要有getter/setter~~

对于默认配置的问题，先在 Axis上试点默认值法（函数传参时是无法分辨显式设置null还是没有设置的）

~~axes为null时，默认取xFieds、yFieds的第一个设置默认axis~~

axes为Map时，根据键设置axis，必须要有会有对应的axis

Axis类里的每个成员采用默认值法，这样设为null就是没有，Axis表示默认的

~~用占位符作为默认参数区分null，占位符类型用P（Pseudo）做前缀，这应该只是Axis这个因为coord不同配置不同的特殊情况中使用~~

目前唯一可行的办法是用默认值修改法，不过当axes为null时添加个默认值

~~interval和area的stack还是要采用分段的形式，否则有透明度的颜色会重影，这就要求他们的position是包含起始点的，这就要求~~

PositionAttr.map计算中，不能引入origin，

重影挺好的，stack就是这个味！

catScale默认range会有个小的留白调整，但是这就导致了在colorAttr上的不准确，现在的处理方法是当它仅作为position时才留白，但有些field是既作为positionAttr又作为color的，改为从stops上做文章

linearScale的max，min的默认值，当全为正时min取0，当全为负时max取0

smooth中的constraint是有必要的，但感觉不应该像f2用[0, 1], 而应该就是点本身

在图形语法的书中对identity有这样的描写：对于归一的scale，不应有tick marks 和scale values，unity的值在scale的中间

在图形语法的书中scale章节的最后，明确表示了bar是两个值间的距离，底部的值不一定是0



---

# 0.2

Intercal等属于 geometric graphing operation

具体的图形gpl中称为element，vega，chart-parts中称为mark



处理配置的复杂性可否这样：参数结构是原旨的gg，但将除data、variable之外的配置打包成presets，可直接用，也可通过级联运算符修改

g2的语法其实是对的，只是没有statistics，statistics自行处理



scale和accessor的关系还按现在这样处理，因为不仅 antv 是这样，vega也是这样



必须要做的：

scale 的类型改为三种，CatScale, NumScale, TimeScale, 分别对应 String, Num, DateTime泛型，其中Num有个参数可以决定它是 linear/log/exp等（这似乎是gg中比较推崇的分法，它有专门一章将time）

shape变成类，为了提供 getcenter、getTouch等方法

绘图时的主体为Case对象，取代AttrValueRecord对象，添加原始datum等信息

stack改为真的一个一个堆叠

添加null值处理

~~interval的shape要整理一下，分为 bar 和 historigom两大类~~

考虑chart参数的类型，添加基本图表的preset

~~geom按照 function、partition、network进行分类，先暂时移除schema类型~~

我们现在常画的“热力图”并不是真的热力图，只是一种特殊类型的point，这样移除 polygon和schema，仅保留function的geom

pie和rose都可以通过单独的shape来处理，geom只负责映射到坐标点，这样pie省了summary.proportion的过程能保留原值，vega似乎也是这种方式，饼图是一种非常特殊的图形，它是唯一的一维图形

~~或者pie和rose都是极坐标下的historigom~~







叫 LinearScale 不叫 NumScale，与g2一致，今后有新的的代数型直接在其上继承

TimeScale目前采用：计算采用LinearScale的方法，tick计算采用cat的方法

以 LinearScale 为基础，进行如下改造：移除nice相关东西，先不要有stringMax等便利功能，现在仅支持tickCount不支持interval，简单算一下

时间计算基于微秒

label不适合作为attr，作为guide，antv也是这样

先不做动画，1.需要动画的图表不多，就算有需求也千变万化，具体到图形上又与图形类型关联

2.动画最好在渲染更新机制优化后再说

3.事件已经能提供一定的动态体验了



geom分为两类：一体式和分块式，不在类型上体现，一体式是line，area

一体式要进行null值截断，这是一个很合理的需求



交互机制，还是基于shape，只是返回的区域可由shape类进行定义。区域都是bbox（Rect）

如无分组，返回与数据点一样多的对象，如有分组，返回与每组数据一样多的对象。

不管怎样都要带着具体的数据点、点组，以便定义事件，带着实际的 RenderShape 以便处理样式





事件主体分为 chart 和 geom 两个级别，

```
Interaction(
  trigger: TriggerType.element,
  geasture: PointEvent.longPress,
  callback: (datum, datumGroup, shape) {},
)
```



在geom中引入 element 的概念，介于datum 和 renderShape 之间

通过 ElementRecord中携带了原始datum和各个scale，adjust就可以随意修改了，依然采用现在修改 attrValue的方式



在gg中，schema是一个统计意义上的概念，仅指数据密度的分布，schema一词源自箱型统计，图形上通过 point 和interval 实现，而在antv中 schema 是用来处理一个x对应多个y的自定义图形的。

我们决定按照antv的定义保留schema，并默认提供candleStick和box两种shape

对于null值的处理，目前在attr中进行归0

对于断开法：仅在line和area中使用，实现太麻烦

对于插值法：仅适用于line和area，其它不合理



interval的图形分类还是尽量依照现在

position只有一个field时，认为它是y，这种情况目前只出现在pie中。此时x表现为一个输出0.5,origin 为0的类似identity scale的特性（不单独定义）



~~pie目前采取的方法（由于没有stat）不管是否stack，都均分其interval~~

由于scale可能倒过来，或者设置不为0,1的起止点，所以连续宽度的也不能直接依赖0和1的值



scale.origin 的真实含义：是表示value意义上的0，在scale之后转换为scaledValue意义上的刻度是多少，主要是为了因对数字轴最小刻度不为0的情况，分别定义如下：

cat：规定value意义上的0就是轴的最小刻度对应的值，故直接返回0

linear：即数字0在scale之后的值

time：定义value意义上的0为最小值（设置的或数据的最小值），其scale结果一定是0，故直接返回0



pie在没有 summary.proportion() 的情况下不可能按照gg的思路来，只能采取传统的方式即x是类目，y是值，不需要stack



# google/charts

可能颜色是需要一个palette的，以处理默认的选中行为

它其中居于核心地位的 series 也有一部分属性是通过类似于TypedMap的 TypedRegistry保存的

选择分为两种，是否byDomain，scatter等适合通过图形选择

事件分为 gesture 和 lifecycle

生命周期分为：

onData

onPreprocess

onPostprocess

onAxisConfigured

onPostrender

onAnimationComplete

只有当series list或者其他configuration变化时，触发了_chartState.configurationChanged，才会 reprocess series, 否则只会要求 repainting

召唤重绘分为：

requestRedraw  好像没什么用

requestAnimation

requestRebuild   它的触发方式是setState(() {});

requestPaint   通过markNeedsPaint实现，它好像是一个很好的机制，似乎会重绘图形，但不会导致重绘组件，现在graphic的更新是依靠setState和每次生成新painter来的，今后可能可以通过重写RenderObject来优化

其中requestRebuild似乎与其中内置的widget有关，比如legend；为处理渲染生命周期，使用了 SchedulerBinding



# 0.3

规定style的类型：

PaintStyle：geom，background，tooltip/legend symbol, anno-region

LineStyle: tickline, tick, grid, anno-line

TextStyle: ticktext, tooltip/legengd text

其中要添加“相对渐变属性”

需用通过drawShadow添加阴影属性

图形元素可添加style，它的指定优先级高于attr，因为它的指定更具体、特殊



需要确定一个生命周期

处理过程：

diff: 当组件更新时，比对参数是否发生变化，参数分为data和spec，data只要不是原来的实例就认为变化了，spec会进行diff

process: 从data、spec计算ElementRecord等重要中间状态，一般由外部变化引起，内部变化不会导致，是主要的计算负担。内部事件导致的某些中间状态重新计算也属于此过程，但不会导致全部重新执行process

render: 从重要中间状态获取或修改RenderShape，

paint: painter执行paint过程中调用 renderer树中各节点的paint函数

draw：指RenderShape的paint函数中调用的具体绘制方法



selection 状态只会影响 style ，style的环节应该在process之后，render之前，即 selection 交互不会 reProcess



null值处理

注意null值处理仅针对作为position的值，用作分组、其它attr的值为null可能导致异常

分组不做额外的null值处理

scale输入为null返回null

所有attr中除了position不做额外的null值处理

position中也不做额外的处理，~~遇到为null的值，对应的point的x或y会为null~~ 注意由于Offset 的xy不能为null，因此将y元素为null的情况暂用nan代替，这样似乎也不要isValid了

adjust中的null视为处于origin

shape绘制中进行判断，area、line中进行切断分组，其它中对应的图元不画

注意null值处理仅针对值域（measure）不针对定义域（domain）

还要处理nan的情况，统称为 invalid，通过 null 和 isFinit 判断，就不额外写函数了

处理invalid的类型枚举称为 invalidFix

计算机特别是图形学中lerp更常用，dart语言中也是用的lerp

注意对nan的情况只有在adjust和shape中才开始用到

目前暂定，为方便序号对应，每个record对应一个shape，invalid的时候放入一个null或高为0的shape

zero和lerp两种情况就不放在shape中做了，用户自己或将来的static中做



line/area重排序

基于性能考虑，line/area不进行重排，用户需自己保证x顺序正确

K线图比较复杂，就先暂时不搞了



由于目前engine不支持null节点，~~所以invald y的图元不添加null，先改为不添加，图元不一定与record一一对应~~ 在getRenderShape中null是要占位的，只是在geom的“render”过程中判断不是null才挂到engine上



f2中pan和pinch移动图表好像是靠影响scale来处理的

高效的渲染引擎点击事件似乎可以采取点击的坐标从renderPoint 转换为abstractPoint，然后通过其中的 scaledValue进行对比的方式，即点击的定义和判断，完全在scaledValue这个抽象层面进行，scaledValue是整个系统最重要的中枢。



注意state自身调用setState引起的更新，只会调用 build 而不会调用 didUpdateWidget，而 chartComponent 是持久化的，因此可将 didUpdateWidget，作为输出参数变化的判断入口调用diff，而 setState 作为内部引起的repaint 触发器，不会引起 diff，chart widget 整体作为“图表配置对象”



绘制大数据点图时，有没有变化的 color、size时间差别不大，说明attr的计算不是主要瓶颈，可能是因为每次addShape都要sort引起的？但是数据影响又不大



缩减 engine的作用，使其仅提供paint方法，将 Painter系列的东西放到chart中，repaint交给ChartComponent

感觉 GestureArena已经起到了EventEmmiter的作用，不需要再加一层了

可能逐渐考虑将一些不是状态的、一一对应的东西不放在State中了



全用canvas的好处，可获得所见即所得的位图



因为 scale、pan涉及到动scale，所以还是要 reprocess 的，

过程分为两个

_setProps

_process

对外暴露

initProps

setProps

reprocess

repaint



需要把所有setProps的地方统一搞一下，由于state是否重置等问题比较复杂，对于这类问题，将原先的state拷贝一遍再行修改，先搞个 updateState函数处理一下



关于scale，由于ScaleUpdateDetai中的值都是带有绝对值的，所以当有两指时哪个减哪个并不重要，依然将focal定义为不动的那个手指，则一定有动focal和move两个手指，定义他们的差为offset



还是要有一个render的过程的，用来生成、更新、挂载RenderShape，对应的使用场景就是 geom 的 selection，process和render之间的桥梁就是RenderShapeProps

这样各个可render组件还能保存个中间变量（们）供今后参考使用

这样事件操作的就是RenderShapeProps而不是RenderShapeComponent，selection插在render的过程中



graffity 可能的一种优化方式是 elementRecord 保存 path 和paint，就相当于现在的 RenderShapeProps，然后graffity 直接引用这些信息，避免构建过多对象？不过要先测试一下构建对象是不是瓶颈

目前主要的后腿是_sort，移除它可以极大提升效率，是的几万个shape都可轻松画出。仔细查看后，引擎中还是有一些类似计算bbox等的冗余可优化

tabaleu也使用的术语：mark、domain、measure





# Vega papers

按dataflow的思想，chart参数的变化，包括data的变化，也可以理解为是一个事件：widgetUpdate，

predicate 指的是“判断条件”

居于中间地位的表示mark中datum的vega中称为 scenegraph

流中产生信号称为 propagate 或 pulse

数据tuple每个都有一个id，并且有标签标明被增删改，衍生的tuple通过原型继承与原tuple关联，每个数据项的previous value 也被记录了，

vega在底层会为每种类型的基本事件生成一个 listener 

protovis 是 d3 的前身

我觉得vega最大的问题是它不是typed，它的specification要是能升级为typed就好了

dart team 目前认为：在面向对象语言中，联合类型的功能应该由接口承担，即定义一个接口（类）包裹这两种类型，这样虽然麻烦，但是大家嘴里的联合类型其实有很多掰扯不清的问题

发生变化不会全量更新，而是通过 changeset 来表征这些变化

对于一些处理时要用到整个数据集的，通过 collector

有两种类型的边：一种是连接处理同一个数据的不同算子的，在这样的边上，changeset 是被push的，算子直接处理它们；另一种是连接外部依赖和算子的，由于它连接的是不同数据空间，外部依赖只能连接被依赖者的collector，这时连接上的 changeset 会被标记为 reflow changeset，只有signal到signal的连接由于传递的是标量，不需要collector。

operator 保存value，可以有一个 value update function，它接收 parameter，parameter既可以是直接值，也可以是其它operator（假设原来的称为甲，其它的称为乙），甲动态的pull乙的value，甲是乙的dependency



# FRP

fp强调的是不可变数据和可组合性

rp定义1.基于事件2.对输入做出反应3.视为数据流而非控制流

rx更强调如何串联事件处理器

编程常被分为两种模型：thread：适用于io，event：适用于gui

状态机的定义是：1.输入事件进入系统2.程序根据输入和状态做出决定3.决定会改变状态或做出输出。任何程序都可以等价为状态机。状态机的缺点是不可推导

stream变化会导致状态变化的，cell变化不会，它是被动的。不区分两者的系统一般称他们为signal

事件是否可以同时是个重要的问题，Rx认为事件不可同时

现代编程的瓶颈就是面向冯诺依曼机导致的顺序思维，高度依赖就地状态改变，使得编译器无法推断程序的依赖，进而进行分布式优化。而函数式编程是面向问题的，只声明依赖关系，天然的方便分布式优化。并且由于不是面向具体的机器，为未来机器的优化摆脱了枷锁

对并行的需求迫使我们面向问题而不是机器编程

工程最重要的就是 reductionism ，即可分解组合，这就要求各部分是 compositionality ，即组合不会导致它的特性变化。FRP在数学上被证明是 compositionality 的

OO不是 compositionality 的一个解释是：回调函数的执行结果不仅依赖于处理对象的调用，还依赖于回调函数的挂载顺序，这一般与处理对象的创建顺序有关

Rx最主要是缺少 denotative semantics，这使得在某些领域它不具备 composititionality

Rx中的Observable为使用方便有三种类型 onNext, onError, onCompleted ，而纯FPR认为异常处理是领域问题，不作为基本特性

Rx可以通过 subscription.dispose() 取消订阅，但是Rx主要为发射完即丢的场景设计，所以一般不需要取消订阅

Rx中Observable分两类，subscribe之后立即执行的称为cold，如range，而subscribe之后不立即执行，需要真正事件产生了才会响应的称为hot，如fromEvent。cold仅仅相当于FP中的list，因为Rx有一部分作用是为一些语言提供函数式基础特性，hot才相当于FRP中的stream

Rx不区分stream和cell

由于Rx没有同时事件（Rx中的merge不是处理同时事件），所以产生由于两个流中的事件没有同时变化引起的glitch

FRP能更好的发挥静态类型的作用，最好于静态类型结合

FRP中一般不会主动获取数据，主动获取数据的sample方法主要用于paint()方法进行采样。snapshot也有类似功能（snapshot是map和sample的结合）

动画系统由两部分构成，连续的描述和推进采样系统

---





# Vega

data可以有多个，有不同的name。（g2只可以有一个data，且格式是json，dataset在之前处理并得到此json；echarts不同的series是不同的data，但是dataset只能是一个；charts_flutter 是基于series的，不同series是不同data类似echarts）

transform的感觉g2的更实际些

data、mark的交互规则通常为一个trigger对象，列在 on 字段中，其中的trigger字段是一个signal

vega只有直角坐标系

production rule 指的属性值是一个数组，每个元素（除了最后一个）有个 test 字段，按顺序如果满足test就是这个值。类似webpack中的那种配置，起到 if else 的作用

vega也认为，一般一个mark instance对应一个datum，line和area是特例

mark encode中的enter, update, exit涉及到d3中的一个重要概念：data join，详见这里：https://bost.ocks.org/mike/join/





# GPL

gpl 表达式基本分类为 source, data, scale, guide, element

scale只有在指明包含0时会包含0，scale、guide等有默认值

nest运算符（/）总是会导致分面，在blend时把每个数据集 nest 一个固定值可以强制分面（gg p79)

city\*pop2000\*group 和 city/group\*pop2000 都会以group分面，区别是前者两个分面中所有城市都出现在横轴，而后者横轴中只出现对应分组的城市。即前者中两个分面的横轴是完全复制，它表示二维空间中又第三维又循环到了横向，通过分面表示；而后者两个分面的很轴是通过group划分过了，表示分过组的很轴用分面表示

cross和nest会增加维度，blend不会

注意图形代数只有结合律和分配律，没有交换律

优先级 nest > cross > blend

只有position可以有多个variables，其它的只能有一个，position中在同一个坐标系中的（用于分面的不算）最后一个维度的variable称为 analysis variable，所有统计方法都是针对它的。

应用在analysis variable上的统计方法，和count相关的统计方法是区分的

unit variable 是用来给维度占位的，比如只有jobcat和gender想按gender分类，要写成 jobcat\*1\*gender。对于scale，它表示在scale的中间。unit variable不可用analysis variable的统计方法，但可以用count相关的

user constant 是一个单独的字符串，相当于一个 variable 永远是一个固定值，在cross和nest中常起到强制分面的作用，blend中常起到添加字段的作用

algebra决定维度的代数关系，最终图形怎样还要加入 coordinate 

nest的定义突出“不为空”，而不是纯“分类”，即 city/gourp，一个 city 可以属于多个group，只要有case是同时这个city这个group

gpl中有个dim的概念，通过dim(1, 2, 3), dim(1), dim(2) 标识，coord，scale，guide定义的时候都与它有关

聚合分组通过 coord 中的cluster函数表示，cluster(3)表示聚合第三维。被聚合的维不占用坐标系的维，analysis variable 依然是坐标系的最后一维

stack的实现中，添加color是起到划分分组的作用的

axis也算在guide中

在关联dim时，nest的variable不算一个独立的维度

stack和cluster的语法是不一样的：

```
// stack:
interval.stack(position(summary.sum(jobcat*salary)), color(gender))

// cluster:
COORD: rect(dim(1,2), cluster(3))
interval(position(summary.mean(jobcat*salary*gender)), color(jobcat))
```

注意这个cluster并不是dodge，而是“把两个分面放到同一个坐标系“

视觉通道属性称为 aesthentic，区分 categorical 和 continous

可以有多个 SOURCE， 取不同名字

coordinate 和 transformation 可以相互嵌套，通过由内向外的顺序变换

饼图通过一维的 polar.theta 坐标系实现

一般scale关联的是维度，不需要名字，除非你想给一个维度安多个scale多个axis

scale的类型就为 linear、cat、time 这样平铺的

cat scale 一般是可以不用设置的，说明 cat scale 的values 鼓励从data中获取默认值

linear scale 一般是不用设置的，如果想从0开始要特别指明

GUIDE 有以下几种：axis, form.line, legend, text

line 和 path 的区分符合gg的定义，另外path可以有不同的宽度

schema符合gg的定义，专指boxplot

图形调整称为 Collision Modifier

注意dodge和cluster的区别，dodge只是调整position，而cluster则是改变坐标系，将原来分面的拼接成同一个坐标系

dodge.asymmetric 是专为一维坐标准备的

dodge.symmetric 的精髓是 elements extend in two directions

创建数据的col方法第三个参数表明数据类型，分为unit.continuous, unit.category, unit.time 三种

GPL的部件会不显式的写会有默认配置，如要不显示是在配置中添加一个 null() 函数

坐标系除了可以作用在position上，也可用在其他aes上：polar.theta(aesthetick(color))

坐标轴只可在端点，可通过 opposite 表明在另一端

SOURCE 和 DATA 是在 GRAPH 之外。多个 GRAPH 公用同样的 SOURCE 和 DATA

GRAPH 和分面的区别是分面不会叠在一起，而 GRAPH则可以叠在一起，而且可以精细控制位置大小

GPL在发展过程中也经历过翻天覆地的改版

GPL中的函数大量使用了重载（overload）



# GG

gg中有个重要的概念 frame，algebra主要是针对它的。

gg本身已经很重视动态和交互了。

gg承认自己基于现存常用的统计图表，语法的扩展性和创造性有限

gg从初衷上讲，关注数据创建图形的规则，而不是具体图形的指定，因此理论上讲不会创建无意义的图形

p24流程图中每一步的顺序不可颠倒，比如不可以在scale之后再算statistics

Relation是集合中很重要的概念，它是笛卡尔积的满足某种规则的子集

函数有定义域（domain）和值域（co-domain）

graph是函数所有的输入和输出的值对构成的集合，和函数是一一对应的关系

函数的串联称为 composition

定义域和值域相同的集合称为 transformation

algebra 是三样东西构成，定义集合，运算符，结合运算符的规则

运算符的操作数和返回结果应该是相同的集合，所以一元运算符是 transformation

variable 指的是从object到value的映射的定义，它的定义域（domain）是object。根据值域的不同，分为 continous 和 categorical 两类

varset 指value到object的映射的定义，它的定义域（domain）是value。主要是为了定义algebra时方便，并且其中的object是bag

尖括号表示bag

frame 是一个value为p维的varset的所有可能的value的集合。它依赖于 algebra 表达式。frame 是计算 aesthetic 的参考框架。它不仅可表示位置，也可表示颜色空间等

可以没有data直接variable

interval的疑虑：上下限两个值应以何种algebra结合？不从0开始的单值interval规则应当如何

coordinate 本质上是一种 transformation。和frame类似，它也可以应用在其它属性上

现在流行原始的 data source 和系统需要的 view 这种模式

数据分为三种类型：empirical data, abstract data, metadata

gg要求 variable 的 mapping function 返回单一值

数据的行列在gg中更多表示为 cases-by-variables

transform 作用在 variable 上，它的作用一是使得variable适用于statistics（transform 和 statistics好像是有明确区别的），二是创建其它 summary（好像 variable，aggravate都属于 summary）

transform 的结果会填满 variable 的每一个 case，哪怕是像 mean 这样的。它会创造新的variable，类型也可能变（比如 rank）。因此要考虑 定义的原始 variable 和 transform产生的匿名 variable的事情

algebra 中的 unity value 对应没有tick mark 或者值，但展示时位于scale的中间

从定义上讲，blend的两者不要求一致，但是一致了才有意义

gg坚定的认为只需要三个运算符，虽然不能证明充要性，但是基于以下几个事实：过去15年所有图表都能表示。曾经还有第四个，但后来证明可以用另两个组合

可能聚合的需要放到 transform 中了

单元元素对应的varset是任意数据都对应到unity

algebra不满足交换律，对于一些特殊图形（比如path）blend 也不具备交换律

symbol或operator组合的多个symbol称为expression

没有 blend 的expression称为 term

没有cross的term称为factor

term数量要结合后看，(A + B) / C 有两个 term

一个term的称为monomial，多个term的称为 polynomial

所有term中factor数量都一样的expression称为algebraic form，这个数量称为它的order

如果想搞清楚一个expression对应的维度，以及variable和维度的对应关系，需要将expression正则化，首先分解blend，然后在每一项右边添加单位元素，直到达到最大的factor数

优先级是 nest > corss > blend

如果variable是categrical的，则会将frame对应的维度按照variable中数据进行分割

cross和nest分面后的图很像，但大为不同。对于同一维度，cross两个不同的分面上是一样的，而nest则是属于不同分类的不同含义

为什么不直接使用类似sql的系统，而要单独搞 graphics algebra ，因为1，两者还是有各自的特性，比如sql中的join、nest满足交换律，但是图形代数中就不满足。2，将图形代数系统置于数据库查询中将丢失掉关于图形对象的信息。3，关系型数据库系统并没有充分考虑动态交互，由于事务的存在，在关系型数据库系统中实现动态交互很麻烦且低效。当然，除了以上不同，sql的关系模型有助于编写 graphics algebra 的程序

graph并不懂algebra，algebra是为了创造管理他们的维度

一个好的图形代数系统应该能够提供接口兼容数据查询语言的函数

图形代数和函数式编程的代数有很多联系

个人觉得，graphics algebra （和很多类似的尝试），目的是为了统一数据的查询和可视化，以期提供智能的“输入查询，输出图形”

scale指的是从 varset 映射到 dimension 的函数

axiomatic scale(nominal, ordinal, interval, ratio) 用在gg上还不够，还需要一些细节，比如同样都是ratio的，但是blend重量和长度显然是没有意义的。从unit measurement中得到启发可以引入类型系统，这样就可以利用类似类型转换处理类似不同类型blend这样的问题了

原教旨的 axiomatic scale 者认为仅凭数据本身可以选择使用何种scale，而gg认为仅凭数据本身不能选择何种scale，需要使用者根据领域知识确定，同样数据可能对应不同scale

虽然 axiomatic scale 理论是毋庸置疑的，但却没有一个绝对的方法确定数据集用哪一种

bar 为什么一般会有个默认原点，这不是geometry决定的，interval 本身与有没有原点无关，事实上 geometry 要求的是两个端点。这是由这一维度是 ratio scale 决定的

transform 可以作用于 variable、scale(dimension)、coordinate，三者严格区分是因为：

variable 和 scale 的需要在 statistics 之前，因为 statistics 一般对它操作的 variable 有一些要求

而 coordinate 的需要在 statistics 之后，它不会改变 statistical properties ，只会改变图形的形状

由于视觉上必须有个顺序，在图形上，nominal 和 oridinal 是一样的

数值型 cat scale 可以挑选自然数作为数值

cat scale 等距划分后两个端点不要对应到 cat 值，这也是和数值型的视觉上的区分

有时候 cat 类型的数值并不需要按数值本身的顺序（它们是 nominal 的）

nice number 的定义是儿童学数时喜欢的数字

不是线性的 scale 也可以有 nice number

nice number 最好包含0

time scale 应该能反映出真实的时间度量，比如二月份的间隔就应该短一些

statistics 应当在 graph 函数管理之下，而不是图表在 statistics 管理之下。这样一是在一个frame上可以展示多种 statistics；二是将 statistics 融入到 graph 函数之中迫使其成为数据的视图而不是数据本身，这样数据项本身和图形就建立了牢固的联系；最后这样会使计算模块化，方便分布式系统使用

有时候从图形是很难倒退 statistics 的，看似相同的图形可能用了不同的 statistics

bin 类型的统计在其它统计之前，它给各个case标上分类的标签，后续统计将仅在同个标签中进行

statistics 中的 summary 类别指的是“基本的”，它的结果是单一的值

region 类型在一个维度上生成两个边界值或在高维上生成顶点

statistics 中的 confi 指的是 confidence

区分 statistics 和 图形展示的原因是两者并没有必然联系，同一种 statistics 可以用不同图形展示，相同的图形可能表示不同的 statistics，这样也能节省代码

注意图 7.1 ，它表明 geom 对和 position 的值的数量没有必然要求，点、线也可接受多个值，

point 等称为 graph type

statistic分为 conditional（条件）和joint（联合）两种，一维上一样的，二维上 conditional 只作用于单一的 x，joint 作用于所有x，三维类似，详见表7.2

grapher 提供 geometric function。不是所有的 graph 都能提供。可以表示为 geometric object 的称为 geometric graph

geometric graph 定义在特定的 bounded region 之内

graph 的分类既考虑 data 又考虑 geometry，因为图形语法处理的是统计图形。分类：function：将value 转为 value或者value的集合；partition 将point的集合分为多个子集；network 连接多个点。

Wilkinson对目前的geom的分类结构很有自信，绝大部分情况都包含在内。但也承认可能需要添加扩展，不过这个添加不会影响大结构和已有的类别

point 的结果是获取一个 n-tuple 的集合，称之为 point graph

一个图元一个对象还是所有图元一个对象各有利弊，取决于要处理的数据量

line 是指 n 到 n+1 维的函数

line 本质上应当是完全的函数映射，但实际上是由 knot 和其中连接的插值。一般插值用直线或样条（spline）

line 要处理无限高度的问题、缺值打洞的问题

可以看出，图形的最终呈现依赖于 OS 的图形系统

三维情况下可用 surface 作为 line 的别名

area 是 line 和 under 这个line的所有点的集合，

interval 产生两个端点，但是bar一般数据只有一点，另一点是 reference point，一般是 zero

histogram 是 interval 和 bin 统计函数结合，bin统计产生的分类使得interval每个bar紧挨着。它能表达一些面积的意味

闭合的path称为 circuit

path和line的区别：line是x的函数，而path是参数方程。由于path可以用参数方程表示，所以算在function中而不是 network 中。另外line所有segment都一样，而path的每一段segment可以不一样

schema 的定义是用来表示数据密度的一组 point 和 interval，计算机程序是从point和interval衍生的，schema 可以有多种形状，也可基于不同的统计规律

partition 的作用是将 dataset 划分为 sebset

polygon 是将平面分为互斥的多边形

注意图 8.20 的写法，只有一个 element，然后用 blend 连接

categorical variable 会划分（split） graph。由于nest需要应用在 categorical variable 上，所以nest也必然划分 graph。

应用在其它 aesthetic 上的 categorical variable 也会划分 graph，比如 `position(sepalwidth*sepallength), color(species)` 会按species 划分 graph

而 continuous variable 则不会划分 graph，它称之为 shade

如果我们想划分图形但不添加 aesthetic，用 split，





# FRP

frp 中最重要的就是两个概念：

behavior: 随时间变化的值，包括时间本身和常量

event: 按照时间序列出现的序列。一个事件变量代表了所有将发生的此事件，而不是一次

其它概念：

operator (combinator): 组合 behavior 和 event 形成其它 behavior 和 event

FRP 程序就是一些相互递归的 behavior 和 event 的集合，每个都是建立自静态的值或其他 behavior/event

比如一个颜色 behavior 初始为红色，左键点击后变为蓝色：

```
color :: Behavior Color
color = red `until` (lbp -=> blue)
```

然后用它去定义一个动画：

```
ball :: Behavior Picture
ball = paint color circ

circ :: Behavior Region
circ = translate (cos time, sin time) (circle 1)
```

有的时候需要分支选择：

```
color2 = red `until`
  (lbp -=> blue) .|. (key -=> yellow)
```

when 能将一个布尔 behavior 转为一个 event ，这个event 在布尔 behavior 转为 true 时发射，这种event称为 predicate event：

```
color3 = red `until`
  (when (time >* 5) -=> blue)
```

将值变为behavior的函数称为 lift

```
lift0 :: a -> Behavior a
lift1 :: (a -> b) -> (Behavior a -> Behavior b)
```

如果函数或运算符不能重载的话，在函数名或运算符后面加个\*表示未提升版本

一个非常有用的操作是behavior对于时间的积分，比如力、质量、位移的关系

```
s, v :: Behavior Real
s = s0 + integral v
v = v0 + integral f
```

FRP 的本质是声明式，FRP 使得用户能够从“建模”的角度思考问题，而不是表达细节。所以往往FRP的声明就是简洁的问题本身。

behavior 语义函数：

```
at : Behavior<a> -> Time -> Time -> a
```

表示给定起始时间和某一时间，得到值。注意起始时间与 FRP 的反应式本质有关，如果一个事件导致了 behavior 的值变化，那起始时间就要从那个事件算起，behavior 是无法获知起始时间之前的事件的。

event 语义函数：

```
occ : Event<a> -> Time -> Time -> [Time * a]
```

表示给定起始时间和某一时间，得到这段时间内的升序排列的所有结构，为时间和值的 tuple。起始时间的规则和behavior类似，且起始时间的不可以有事件（结束时间可以）

基于stream 的FRP实现：

核心类型定义：

```
type Behavior a = [Time] -> [a]
type Event a = [Time] -> [Maybe a]
```

behavior 可认为是一个 stream transformer 函数从一个无穷的时间 stream 映射到无穷的值 stream，event 是可能取到没有值的 behavior。

实现分为两步：1.定义基本的 behavior, event, combinator 作为 stream transformer；2.实现一个运行时系统，翻译上述内容、建立无线的时间 stream，并应用上述内容

时间的定义：

```
time :: Behavior Time
time = \ts -> ts
```

lift 的定义：

```
($*) :: Behavior (a -> b) -> Behavior a -> Behavior b
ff $* fb = \ts -> zipWith ($) (ff ts) (fb ts)

lift0 :: a -> Behavior a
lift0 x = map (const x)

lift1 :: (a -> b) -> (Behavior a -> Behavior b)
lift1 f b1 = lift0 f $* b1

lift2 :: (a -> b -> c) -> (Behavior a -> Behavior b -> Behavior c)
lift2 f b1 b2 = lift1 f b1 $* b2
```

积分的定义：

```
integral :: Behavior Real -> Behavior Real
integral fb =
  \ts@(t:ts') -> 0 : loop t 0 ts' (fb ts)
    where loop t0 acc (t1:ts) (a:as)
      = let acc' = acc + (t1 - t0) * a
        in acc' : loop t1 acc' evs ts as
```

事件映射

```
(==>) :: Event a -> (a -> b) -> Event b
fe ==> f = map (map f) . fe

e -=> b = e ==> \_ -> b
```

merge 同类型事件

```
(.|.) :: Event a -> Event a -> Event a
fe1 .|. fe2 =
  \ts -> zipWith aux (fe1 ts) (fe2 ts)
    where aux Nothing Nothing = Nothing
          aux (Just x) _      = Just x
          aux _ (Just x)      = Just x
```

切换 behavior

```
until :: Behavior a -> Event (Behavior a) -> Behavior a

fb `until` fe =
  \ts -> loop ts (fe ts) (fb ts)
    where loop ts@(_:ts') ~(e:es) (b:bs) =
      b : case e of
          Nothing -> loop ts' es bs
          Just fb' -> tail (fb' ts)
```

snapshot 对 behavior 在某个时刻或事件发生时进行采样

```
snapshot :: Event a -> Behavior b -> Event (a, b)
snapshot fe fb
  = \ts -> zipWith aux (fe ts) (fb ts)
    where aux (Just x) y = Just (x, y)
          aux Nothing _  = Nothing
```

predicate event

```
when :: Behavior Bool -> Event ()
when fb =
  \ts -> zipWith up (True : bs) bs
    where bs = fb ts
          up False True = Just ()
          up _     _    = Nothing
```

外界输入称为 environment （Env）

# E-FRP

在 E-FRP 中，behavior 只有在事件出现时才会改变

在 E-FRP 中，两个事件不能同时发生，防止了事件处理时的复杂相互影响

当事件发生时，程序执行分为两个阶段：一是根据之前的状态执行计算，而是更新状态。E-FRP 运行程序员指定behavior 的变化应该发生在哪个阶段

为简便，event 发生时并不携带值

non-reactive behavior 不会直接被事件更新，可以是变量、常量、或对其它 non-reactive behavior 的函数调用

reactive behavior 具有初始值，当事件发生时变成当前值，

store 将 variable 映射为 value

# Vega

**E-FRP**

E-FRP 中的 stream 可以被组合成 signal，以便建立对 event 响应的表达式

E-FRP 运行时会建立 dataflow graph ，这样当事件发生时会传播到相应的 stream

后续信号会分两个阶段计算：根据依赖的之前值进行计算，再更新依赖

传统 E-FRP 存在浪费重复计算的问题，vega 保留了二阶段更新，但借鉴流数据库，引入了“流分层数据”，可在运行时动态的改变 dataflow graph ，生成新的分支处理嵌套关系

**streaming data**

tuples 被系统观察后，会被标记为 new 或 removed

operator 之间传递 tuple 而不是完整的关系

这样 operator 就能发现哪些tuple更新了

有时仅改变tuple是不够的，比如两个关系的 join，这时用 cache（或称 view，synopse）去固化这种关系，并在依赖的 operator 之间共享

现存的 streaming data 系统只处理flat relation，vega却使其支持 nested data。动态分支解包包含关系，使得下游的 operator不需要知道高层的结构，这样就可以有任意层了

**dataflow visualization**

vega借鉴了比如：对于没变的tuple进行了 pass-by-reference

输出数据只有在需要时才会被存储

vega 提供了 interaction primitive，补充了 stream 的操作性

graphical primitive 可以任意包含

**architecture**

pulse 就是 propagate

graph唯一的sink就是renderer

operator 分为三种类型：输入数据的处理，interaction 处理，构建 scene graph

对每个 dataset 都会建立一个 branch

branch 由输入和输出node组成，node之间通过 data transformation operator 组成的管道连接

输入节点将原始 tuple 作为线性 stream 接受（tree 和 graph 则分别通过父子和临指针支持）。当data source 更新，tuple被标记为 added modified removed 之一，每一个 tuple 都会有一个独特的标识符。数据转换 operator就通过这些标记进行计算或生成新数据。生成的数据通过原型继承与父数据保持联系。这使得operator不用传递无关的上游变化了

有些 op 需要对数据标签状态进行额外的调研。比如求平均数，增减可以在当前tuple值处理，但改则需要除去旧的换上新的。

所以 tuple 有个 previous 参数。对 tuple 的修改将会把原tuple放到 previous 中

针对可视化中每种底层事件，vega都会实例化一个 event listener node，它们通过 event selector 指定到依赖的 signal

组合事件中每个子事件都会关联到一个自动建立的匿名signal；另外还有一个连接它们的匿名signal作为阀门，只会发射最终signal，

signal可以有多个依赖 signal或事件，值的传递遵循 E-FRP 的二阶段









---

Graphic 大的架构为：

- GG 的 specification
- vega的架构
- 轻量渲染引擎 Graffiti

typed(dart) + declarative(vega) + gg(GPL) + E-FRP(vega)

vega-view API 会暴露vega架构中的对象，方便调试

注意 **dimension** 和 **domain** 的区分

字符串、extension 好像不太适合algebra，还是要定义个对象，不如统一用 Key('city')

可不可给element的shape属性注册一个relative symbol的方式来做legend？

维度用什么？1,2,3，‘x', 'y', 'z'，还是Dim.x, Dim.y？

guide 感觉可以拆分为 axis, legend, annotation

data 的 transform：

g2是仅可作用于dataset，结果才会传给图表，

vega是既可作用在data，又可用于mark的channel

gpl是可作用在variable定义或作用于position的algebra只上

可能所有的表达式（predicate）要用函数的形式

感觉scale优化的关键是要区分 continuous 和 discrete，discrete是输出序列，continue是输出[0, 1]

注意“函数”和FRP唾弃的“回调函数”还是有区别的

---

algebra的现状

ggplot2:没有

vega:没有

g2:全部用*表示，本质上没有，就是个数组

chart-part:没有



好的可视化库：

true GG

typed language

declarative specification

FRP

extensive

---

感觉 variable 的函数还是应该叫 mapper

感觉blend好像就起到多点图形的作用了？（blend是有序的，不满足交换律）

blend后到底是分开的图还是同一个图元上的，可以依据是不是同一个case？

注意variable只是data的一个视图

需要区分只有ratio scale 才有原点

感觉在统计学中很多地方还是以从1开始的自然数符合习惯

blend 是否结合可能是判断是多个图元还是同一图元过个关键值的区别 见图7.32

以下内容感觉暂不包括：

facet：移动端不常用，不过 nest 运算先实现

geography：留给专业的

edge：图可视化一般也是专门的

感觉在 fpr 语法中的运算符还是直接用函数形式比较好，可模仿rx，因为这样直观易接受