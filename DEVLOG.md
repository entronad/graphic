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



由于目前engine不支持null节点，所以invald y的图元不添加null，先改为不添加，图元不一定与record一一对应