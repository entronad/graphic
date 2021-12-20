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



graffiti 可能的一种优化方式是 elementRecord 保存 path 和paint，就相当于现在的 RenderShapeProps，然后graffiti 直接引用这些信息，避免构建过多对象？不过要先测试一下构建对象是不是瓶颈

目前主要的后腿是_sort，移除它可以极大提升效率，是的几万个shape都可轻松画出。仔细查看后，引擎中还是有一些类似计算bbox等的冗余可优化

tabaleu也使用的术语：mark、domain、measure



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

~~transform的感觉g2的更实际些~~ 根据gg的概念，区分 trans （trans属于 variable）和 stat

data、mark的交互规则通常为一个trigger对象，列在 on 字段中，其中的trigger字段是一个signal

vega只有直角坐标系

production rule 指的属性值是一个数组，每个元素（除了最后一个）有个 test 字段，按顺序如果满足test就是这个值。类似webpack中的那种配置，起到 if else 的作用

vega也认为，一般一个mark instance对应一个datum，line和area是特例

mark encode中的enter, update, exit涉及到d3中的一个重要概念：data join，详见这里：https://bost.ocks.org/mike/join/ （好像不要用到）





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

坐标系除了可以作用在position上，也可用在其他aes上：polar.theta(aesthetic(color))，（先只考虑 coord就是指空间坐标系，一个图表一个。aes 也只考虑单变量的。即一个通道一个变量，空间一个维度一个通道）

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

使用不同坐标系的原因：1.简化 2关键是区别能更好的被感知 3使得图形与理论或实践一致，比如 0-2pi的值，或表示磁盘分区的数据，适合用极坐标

axes、guide 和 graphic 共用 geometry ，所以它们也会进行同样的变换。但也有特例，比如text的文字方向等就不会

isometry 变换，保持距离不变，包括 translation, rotation, reflection,

similarity 包括 dilation，形状一样大小不同

affine 仿射，只有一个维度变换

project 投影

conformal 保角

coordinate 中的rotation由于是作用于view的而不是 frame，所以文字的位置变了但方向等不会变

transpose是 reflect加rotate，它是沿着对角线翻转

注意 transpose 是不会调换 domain 和 range 的位置的，只改变 domain 和 range 称为 pivot (这是从数据库学来的词汇)

对于有些图形，比如某些point，transpose和pivot是一样的，但是某些统计曲线会有微小的不同

有时我们transpose，仅仅为了让纵轴的文字能够横向排下

对于 dilation，rectangular是(x, y) -> (cx, cy)， polar是 (r,theta) -> (cr,theta)

zoom是dilation的应用，需要区分 graphical zoom 和 data zoom，

graphical zoom会改变所有东西，包括axes和text，它通过 dilation transformation实现，可以想象成光学放大

data zoom 则是改变 frame，通过改变 bounds。frame的物理边界（由axes构成的盒子）以及frame中的其它graphic（points、line、bar）的大小是不会改变的。zoom-in会subset data，而zoom-out会将data放在更大的尺度。

data zoom会对内置的graphic有影响，需要重新计算。而 graphical zoom则不需要重新计算。

stretch改变的是aspect ratio，及物理高度与宽度比。有时会根据屏幕尺寸比定，但这样减少了精确性，一般45度左右的曲线感知起来最精确

polar坐标系中，第一个表 domain，是角度，第二个表range，是半径

polar坐标系主要应用于方向数据、转动数据、天文时间、周期波动数据、占比数据。最常用的是表占比和大量树叶的情况

饼图是 polar.theta坐标中的一维图形，饼图标签不是 axis、scale等guide的一部分，而是一种 aes，

polar.rho是传说中的牛眼图

polar.plus和polar.rho.plus是以单位元为基准再往外增长，防止原点处太拥挤

注意图9.22，由于应用了bin统计方法，polar.rho不再是牛眼

注意图9.26，多环饼图

scale的cycle和polar坐标系结合可以用来展示周期性数据的变化

注意图 9.29 的雷达图写法。area雷达图并不表面积，它的边更类似于edge

极坐标下的inverse是rho变为倒数，theta不变

bend是指对x或y独立的做变换，当然也可以两者同时做变换，因为是独立的与shear是不同的。它的特点是grid和axes的平行性会保留

将高维的数据图形化表示有三种方法：一是投影到二维平面，二是通过函数表示，三是递归分类创造 nested coordinate space

注意图 9.61和图9.26的对比，坐标本质上是变换？可叠加？

类别（Category）从哲学上是否表示事物本质分为两派，因此分为（prototypes）和（exemplars）两派

靠在一起的容易被理解为分为一类，这称为 principle of proximity

注意可以自定义 aesthetic attribute 函数，比如 color.spectrum()

aesthetic attribute function 有两种使用方式：一是接受一维variable（可以 blend）或常量；二是 position 接受二维variable，但是不可以常量

attribute 如何分类这点上心理学家和设计师是有分歧的，目前的分类是一个妥协，具体考虑：1.一个attribute必须能同时兼容 continous 和 categorical 的 variable；2.对于一个 continuous variable，attribute需要沿着一个尺度变化。对于多维的attribute，比如颜色，需要确定沿着某一方向（比如色相或亮度），或多种的结合；3.attribute并不必然意味着是线性的变化，比如hue；4.必须要让感受者直观准确高效的从attribute中读出variable；5.要能区分两个不同attribute代表的不同variable的value；attribute必须关联到实际可以渲染的特性

将 form 与 texture 分开是为了计算机实现

attribute 哪怕是position，size可感知，不一定代表要是视觉的，在不同的设备上或可访问性的需要可以以视觉、声音、触摸的形式表现

continuous variable 对应到 location，categorical variable 对应到 lattice（格子）

有些情况，比如bar的宽度，不适合映射到数据变化。只让一个attribute变化会让精力更集中

shape 指的是对象的外边缘形状。

shape 也是可以有 continuous 变换的，称为 morph

area 只有在它的边缘不被position限制时可以改变 shape attribute，比如 polygon 可以设为 hexgon

颜色的rgb立方不能代表所有的颜色，而且在这个立方中的距离也不代表感知的差异度

rgb 0,1,1被称为 cyan，1,0,1被称为magenta，1,1,0是yellow

在rgb立方上沿不同路径可以得到一些color scale，比如 brightness, heat, ranbow, circular, bipolar

text 也是 aesthetic 的一种，一般用 label() 函数

注意图 10.47 的interval shape

注意图 10.54 中对 string() 的应用，主要为了区分 blend 中的类别，常用于label、color中

在GG中，facet是通过嵌套coord和algebra一起来定义的，不过有些坐标系看来是专为facet用的。antv中直接通过facet指定

在 scale guide 中，axis 是给position 的，legend是给其他的，axis可以认为是position的legend

ViZml的原则是没有设置就是不显示，而不是有个默认值，设置不显示才不显示。一是其实根本不存在约定俗成的默认值，有的默认显示有的默认不显示只会加重心智负担；二是交互时点击的元素能对应到具体的节点更方便些

所以所有可选的节点如果没有设置都是没有，同理所有bool值默认都是false

gg中的文字：geom并没有text类型，每个mark的文字属于label属性，annotation中的text指的是title这样全局性的

facet 的本质是 frames of frames

图解 facet 可以用 tree 或者 table

cross 是一个frame 的一个 aspect，而不是 layout

cross 和nest的区别最好的例子就是性别与婚姻状况和是否怀孕中

代数表达式中引入 unity varset 只会升维，但不会添加新元素

a/b/c 称为 three-way nesting

(a\*b)/c 类似于 a\*b\*c 只不过在根据 c分类时要剔除掉没有的

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

当事件发生时，程序执行分为两个阶段：一是根据之前的状态执行计算，二是更新状态。E-FRP 运行程序员指定behavior 的变化应该发生在哪个阶段

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

**processing input data**

pulse 就是 propagate

graph唯一的sink就是renderer

operator 分为三种类型：输入数据的处理，interaction 处理，构建 scene graph

对每个 dataset 都会建立一个 branch

branch 由输入和输出node组成，node之间通过 data transformation operator 组成的管道连接

输入节点将原始 tuple 作为线性 stream 接受（tree 和 graph 则分别通过父子和临指针支持）。当data source 更新，tuple被标记为 added modified removed 之一，每一个 tuple 都会有一个独特的标识符。数据转换 operator就通过这些标记进行计算或生成新数据。生成的数据通过原型继承与父数据保持联系。这使得operator不用传递无关的上游变化了

有些 op 需要对数据标签状态进行额外的调研。比如求平均数，增减可以在当前tuple值处理，但改则需要除去旧的换上新的。

所以 tuple 有个 previous 参数。对 tuple 的修改将会把原tuple放到 previous 中 （好像没了）

**handling interaction**

针对可视化中每种底层事件，vega都会实例化一个 event listener node，它们通过 event selector 指定到依赖的 signal

组合事件中每个子事件都会关联到一个自动建立的匿名signal；另外还有一个连接它们的匿名signal作为阀门，只会发射最终signal，

signal可以有多个依赖 signal或事件，值的传递遵循 E-FRP 的二阶段

**constructing the scene graph**

scene graph 的建立类似 protovis 的 bind-build-evaluate 流程：

解析完声明后，遍历 mark 树绑定property定义，property被编译为视觉通道（vega中encoding指视觉通）函数

在运行时，为所有的mark 创建build 和 evaluate operator

build operator 执行 data join，为背景 dataset 中的每个tuple创建一个 scene graph element （或叫 mark

evaluate operator 执行恰当的 encoding function

下游的 bounds 操作符计算生成的mark的 bounding box们

运算符的顺序很关键：父mark必须在子mark前build和encode，但是子的bound要在父之前计算

这样 scene graph 就是一个树，父节点是个 sentinel node

生成的 scene graph的元素是 data tuple，可以作为下游的输入

这样的结构称为 reactive geometry ，提高了一些操作的性能，比如加标签，而且由于mark可以进行数据转换，也是的一些高级layout算法得以应用

**changeset and materialization**

不是所有时候所有数据都要传播的，operator 传递的是 changeset

changeset 由被观察的tuple，新的 signal value，事件之后的更新组成。

changeset 的传递起自对 streaming tuple或者用户交互的响应。相应的 input node创建一个新的 changeset,并注入侦测到的update。operator根据它进行相应的计算，并可能通过多种方式加强它。比如filter会去掉一些tuple，cartesian product 会替换掉所有的tuple

虽然changeset仅包含更新了的data，但有些运算符需要全data，就要用到 collector 运算符。他能在一个分支中 materialize 当前data。为了高效，collector 是共享的

对于动画，changeset包含一个插入队列让mark计算需要加入的实例

**coordinating changeset propagation**

通过中心化的 scheduler 向合适的operator分发 datachange，而不是由operator自己代理

scheduler 控制传播符合拓扑规律，即依赖都更新了才算下游，能防止glitch，更好的剪枝

而交互 event 发生后，更新则不完全按照拓扑结构。signal会根据定义顺序重算。signal重算可能会基于依赖的前值，类似 E-FRP 中的二阶段更新，所有需要的signal重算好后，会发送一个包含新signal values 的 changeset并交给dataflow graph

**pushing internal and pulling external changeset**

dataflow graph 中连接 operator 的 edge 分为两种：

两边操作同样的数据，比如一个mark的build和evaluate。这种就是push

如果是外部依赖，比如其它data source，signal。他们不能直接连接operator，而是外部依赖连接到最近的上游 collector node。这种连接那个依赖到collector 的 edge上传播的称为 reflow changeset。当 collector 接收到 reflow dataset ，将会将其向前传播，标记他们为 modified。这样下面就能接收蒸汽的输入数据并通过scheduler请求依赖的最新值。

只有一个例外，就是signal依赖其他signal。reflow changeset 在edge上传播的是标量，不需要通过collector

这种 push/pull 混合的结构减少了单个元素的复杂度。比如 signal 的参数不管是数据变换还是视觉通道，都输出 reflow changeset。

vega架构图中实心箭头代表内部edge，空心箭头代表外部 edge

**dynamically restructuring the graph**

operator 可以增加或删减分支。

分支模型采用标准关系层次，所以下层不需要知道上层。

新branch计算队列的顺序与创建的一样。为确保拓扑顺序，operator 有一个rank。当加入新的edge，rank会重新计算确保每个operator的rank都比它的依赖大。scheduler列队计算operator时也会记录rank。在传changeset给operator之前，scheduler会比对这个operator当前rank和存储rank，如果一样就计算，如果不一样重建graph。

由于建立寄生的scene graph 是完全数据驱动的，重建最常源自 scene graph operator。子mark（包含 build-evaluate-bound 链)在父mark实例化之后实例化。所以在编译时，只会建立一个与 scene graph 的root node关联的分支。当数据流经 graph，或者发生交互才会创建branch并计算包含的mark。为确保mark计算在同一循环，新branch临时挂载在父上。这些链接会顺序被移除以确保子mark仅字啊背景数据源更新时 rebuit 和 re-encoded。

**vega-lite selection**

selection 的对象是data tuple，图形通过 inverse scale 查找到对应tuple

selection 定义时分为 point, list, interval 三种

selection 是一种高层次的封装，底层对应的原生事件根据平台自动决定

有事先选择的机制

有几种变式选项：

project：只去判断一个字段

toggle: 可开关多选

translate: 选框可拖动

zoom：选框可缩放

nearest: 根据泰森多边形选最近的

translate 和 zoom 同时也起到变换图表坐标区域的作用，通过将selection结果作用在scale上

selection是针对整个图表/可视化区域/坐标系的，它们也只对应一个tuple set

vega-lite编译到vega的中间产物也叫XXComponent

`vega-parser` -> runtime dataflow description -> `vega-runtime` -> live dataflow instance

流程：

使用vega的程序操作的对象是 View

View接受的对象是已经parse好了spec （runtime dataflow description，简称desc） ，里面是operators，streams，updates数组，但这个数组不是dataflow里的实例，是Entry

用户写的 spec 转换为 desc 是通过 vega.parse 函数

vega.parse是一个parseView级联一个toRuntime

parseView的传入参数是spec和一个新建的scope，其中操作就是针对这个scope，返回加工完成的scope。config参数相当于 default theme

scope.toRuntime抽取一些scope的属性组成一个对象返回，它就是desc

view 的 \_runtime 字段是一个Context对象，通过 runtime()函数获得

runtime()函数是一个Context的构造函数级联一个parse()函数，parse函数返回 this context

materialize的意思是从背景数据源中构建出所需的新list

dependency: 上游

dependent: 下游

df的每个run中，都只会新建并持有一个pulse（分叉后每个支路一个），遍历 heap 中的每个 op.run更新这一个pulse，体现“op传递pulse”

dataflow 只包含遍历 run每个op，view下一步会执行renderer.render，传入view.scenegraph.root，它是一个scene

scene对象并不保存绘图方法，而是rederer.draw方法执行是根据类型查找执行对应的mark.draw方法

在dataflow.runAsync和renderer.renderAsync中，都有一些异步执行标记的处理

在parse 的时候，有一些 built-in Signal ，它们会与view的一些设置相结合

data有个专门的 dataScope

在scope.toRuntime 中要执行finish函数，finish中主要的逻辑是 annotate，就是把保存在map的键中的name写到desc的对应字段中（比如 signal，scale）

view.scenegraph是在View的构造函数中新建的

ctx（或称 runtime）是在View的构造函数中构造并 parse的

operators 是在ctx.parse函数中被 add 到 dataflow中，并根据 params 被 connect，根据 source 新建 EventStream ，挂载listener也是在这一步（最终通过 canvas.addEventListener实现），其中sepc中的between、throttle等设置通过eventStream的对应函数实现

event source 分为 timer, view, widow 三大类

update在desc中是单独放的，标明 source 和 target，会通过 df.on 进行挂载

View 的构造函数中安排完runtime后，会在内部执行一次pulse初始化 scenegraph（注意pulse属于update，不包括run）

后面再进行一些涉及size和dom的操作

然后显式的调用一次 runAsync

vega 的 scenegraph 将同类型的mark并入到一个mark中，似乎很好

将resize引起的 变化单独处理，似乎很好

这样也就是说一个 scene 对应的是一个 element 整体，它控制着下面一个一个的item，通过 DataJoin 和 Encode 两个运算符连接

scenegraph: 用于生成并返回 scene的工具类

renderer：主要处理resize，render输入根 scene

vega 是通过遍历scene树的方式渲染







# Interp Vega

dataflow 感觉还是用函数式的思想，Tuple类尽量简单，用函数+变量代替类方法，方法大多返回对象本身

需要动态成员的地方先在局部添加个map，比如parameters

数组的迭代函数参数需要重点注意

hash多指表示映射关系的Map

vega 中的 timestamp， clock， stamp 都是指的采样周期，这是E-FRP的特点，我们代码里统一用论文中的 clock 指代

UniqueList 感觉完全可以用set取代，因为它只有add remove 方法，序号没意义

encode 在 vega-encode包中，它是 dataflow 中 Transform 的子类 Operator::Transform::Encode

filter 和 visitor 先都采用dart的只有item的方案

先依旧保持方法返回对象本身以便链式调用的方式，可能更简洁写，不过setter方法就不刻意做成函数，到时候用双点调用

子类不支持的方法用 UnimplementedError

为与图形的element冲突，集合元素称为item，对应包装的临时类叫 XXInfo



由于DV的特殊性，字段其实只能有 num, String, DateTime三种，要不要通过accessor，使得读取tuple字段成为可能？



util没有业务含义的统一放到公用的中，有业务含义的放到对应模块

时间都是精确到微秒（microseconds）

**Tuple**

ingest 就是 Tuple 的构造函数

如果以datum这种方式，根本就没有 rederive的功能

**Parameters**

set 直接设置和设置List的一项还是分开来写比较好

modifiedAny 还是单独写比较好，因为如果name是null 时容易混淆

**Pulse**

stopPropagation 不应该用实例相等判断，而应该用一个标志位判断（私有只有getter）

先假设整个dataflow中Tuple需要具有一致的泛型D

mask中有些操作需用于const，因此不抽象成函数

文件中的工具函数materialize好像就是where

注意js的小陷阱：0 判断是false，但是 0 || default 依然是0

因为他注释里强调了，所以 filter 函数还是采取返回tuple的形式，null 表示不要，同时起到 transformer 的作用

_visitArray 中list为非null，source单独判断

clean感觉就搞一个成员就可以了

modifed()函数逻辑比较复杂，现在这样写应该是比较合理的

由于目前datum不具备按字段修改，所以fields不需要是map，先改为bool名称暂时不变

dataflow的pulse方法中给pulse添加了一个target成员，暂时不知道什么用，先加上

加入Event继承自pulse的话，从对evnet的操作来看dataflow不是final的

**MultiPulse**

注意 change() 方法flags缺省时父子类的差别

modifed检查不能设置了noMod

**Operator**

op的id好像在scope中可以改的，所以先设为外部

update目前来看是需要传入operator本身的，在dataflow的 \_updater方法中就可以看出

set方法返回值感觉还是bool靠谱

skip modified两个改成访问器

parameters中子数组或对象不再搜索

感觉argops并不需要用到name和index，因此先作为List处理，initonly作为一个配套参数 \_argOpsInitOnly

注意现在由于null的存在，泛型V不一定继承自Object，全能母类型是 Object? ，类的泛型V在定义时仿佛是nullsafe的，但是和Object比对时又不认，暂时先用dynamic

为方便dataflow的rerank方法判断，_targets 要再搞一个hasTargets方法判断

op的async是个future，好像是从设置中传入的，在dataflow的evaluate方法中用上，先整上

从dataflow.onStream方法看，operator 的 evaluate, update方法可以接受pulse也可以接受event，这时候marshall中传入的stamp为undefined，update方法要定义为接受event的

**Transform**

run中的rv.then没太整明白，先挂在pulse中，估计是链式的

**Changeset**

根据论文，Changeset认为合成词

changeset 所有成员都为私有，仅暴露方法

modify 不具备改字段的功能，只能改data，是记录pulse的encode还是修改tuple的datum以

**Dataflow**

add 先按照只能传入 Operator 的方式来

update系列函数中的 options 直接作为可选参数（命名没有必要，也不利于on中使用，on有可选位置参数，一个函数尽量要么都是位置参数，要么都是命名参数）

注意pulse方法中的op.pulse，由于stopPropagation的存在，它的类型要特殊处理

由于没有loader，所以没有\_pending

DataflowCallback可能是async，所以要FutureOr\<void\>

中间 next = await next; 没看懂，先不管

next == null || next.stopPropagation 注意包含null和非stop的情况

_running 有很多作用，不光光load用，所以要的

\_getPulse 方法会根据传入的op的source中元素的个数决定返回一个pulse还是MultiPulse

从MultiPulse的逻辑来看pulses的元素不能为null，getPulse中几个pulse先都用 ! 置信

两个on先分开来写

onStream中skip 默认是true，onOperator中默认是false

onOperator中的target似乎是可以为null的

**EventStream**

vega中的EventStream不是指异步中Stream的概念，而是一个独特的事件定义模型

receive 采用先弄个占位符的方式，构造函数中在初始化，方便类型 null-safe

consume直接用成员

EventStream 的 detach 好像没用，但好像预示着 Operator 和 EventStream 有着相同的接口



从论文和某些代码来看，似乎存在着以下继承关系

```
Operator -> EventStream
Pulse -> Event
      -> Changeset
```

View 继承自dataflow

dataflow.\_heap 并不是挂载所有op，只是一个临时运行的缓存，所有op通过op.\_target以链表的方式存储

op的tuple的内容是个高度通用的，不一定指原始数据相关的

图表创建时，会产生包含 add 的changeset，事件时会产生包含mod的changeset

~~忽然觉得阿姨我不想努力了，先完全采用vega的spec，再用gg的概念去改造~~ vega grammar 毛病很多，但有很多值得借鉴的地方。GG最高！



# Vega Grammar vs GG

vega 的继承自D3 的scale很好

设计时完备性优于简洁性

vega没有坐标系很不好，所有的pie，radar都不好

Signal 很好

shape绘制器很关键，为了减少概念，直接占用shape 这个 aes attr

aes attr 可以扩展，比如shader（覆盖 color）







---

Graphic 大的架构为：

- GG 的 specification
- vega的架构
- 轻量渲染引擎 Graffiti

typed(dart) + declarative(vega) + gg(GPL) + E-FRP(vega)

vega-view API 会暴露vega架构中的对象，方便调试

注意 **dimension** 和 **domain** 的区分

字符串、extension 好像不太适合algebra，还是要定义个对象，不如统一用 Key('city')

~~可不可给element的shape属性注册一个relative symbol的方式来做legend？~~ shape 属性还是用函数吧，legend自己考虑

~~维度用什么？1,2,3，‘x', 'y', 'z'，~~还是Dim.x, Dim.y？**都用数字，指定维度叫dim，维度数叫dimCount，用数字更简洁纯正**

guide 可以拆分为 axis, legend, annot（annotation），去掉guide这一层，g2也是这样的

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

~~感觉 variable 的函数还是应该叫 mapper~~

感觉blend好像就起到多点图形的作用了？（blend是有序的，不满足交换律）

注意variable只是data的一个视图

需要区分只有ratio scale 才有原点

感觉在统计学中很多地方还是以从1开始的自然数符合习惯

blend 是否结合可能是判断是多个图元还是同一图元过个关键值的区别 见图7.32

以下内容感觉暂不包括：

facet：移动端不常用，不过 nest 运算先实现

geography：留给专业的

edge：图可视化一般也是专门的

**Custom/tag/mark annotaiont 可以实现title，legend等大部分功能**

感觉在 fpr 语法中的运算符还是直接用函数形式比较好，可模仿rx，因为这样直观易接受 **目前的高级gesture系统似乎不再需要事件的 fpr 了**

感觉在specification中会大量用到字符串作为标识符去指代某些变量，因为那些变量还没有被生成，比如signal的定义

variable只接受三种类型，num, String, DateTime

scale分为

QuantitativeScale

- LinearScale  (num)

- TimeScale  (DateTime)

DiscreteScale  (String)

- OrdinalScale

- BandScale

- PointScale

variable 统一为 field，更常用字更短

data transform(statistic) 可以拎出来单独做，即传入 data 字段的就是不可变的成品数据，然后可以提供一些工具类

~~除了gg的属性外，在提供给paint使用：~~ gg中aes属性是灵活多变的，根据实际需要来，gradient先单独搞，texture再想办法，虽然它们都是paint.shader实现

GradientAes 渐变，覆盖color，只支持Gradiant类作为shader，spec中用painting里的Gradient类，本身就是相对坐标系，然后直接通过createShader方法创建到mark上

~~StrokeAes 描边，还是挺重要的需求，新建个类包含 width 和 color 两个字段~~ 不要了，不是一个好的设计，而且比较麻烦

ElevationAes MD特色的阴影，通过 canvas.drawShadow实现

~~OpacityAes 还是加一下吧，比较实用，通过 withOpacity 实现~~ 好像完全可以通过Color很好的实现

Attr整理

PositionAttr   Offset

SizeAttr    double

ColorAttr    Color

ShapeAttr    Shape

GradientAttr    Gradient

ElevationAttr    double

其它的 paint 用默认值

在spec中，有name的多配置项，尽量用map

scale将值映射为 0-1或正整数，aes将0-1或正整数映射到属性值。PointScale和IntervalScale似乎没有必要

感觉 scale 作为 field 的附属更合理，gpl中与dim绑定不能处理多图形和颜色属性等问题，这样也与vega类似，由于

echarts, antv, vega-lite 数据都是只能有一个，我们也只弄一个，因为1，没有关联的两个数据源不应该出现在一个坐标系上，2一些交互逻辑需要统一数据源

还是用variable比较专业些，与gg一致，variable感觉可以不光光通过accessor，而且可以通过transform创造出

modifier gpl中只能应用一个

用element不用mark，gg中就是用element这个词，mark一般指ticket mark

而position等用Attr，因为它本来就叫Aesthetic Attribute或者Attribute Function，Aesthetic指代处理过程

不拘泥于全写，dart中也有 num bool var，google charts 中也有 spec，Fn

缩写记录：attr, coord, dim, 

selections 是为事件准备的，不是确定值，而是值的变化，所以应该用函数，与algebra 和 values没有关系

图片初始加载的那个周期里，还没有signal或selection，所以都是初始值值（由algebra和values决定）发生事件后会有影响，即selected有 true, false, null 三种状态，需要再考虑考虑...

重点考虑要不要 stat/trans 为data，比如比例图，目前维持判断，antv, echarts 中的饼图、比例柱状图都是事先算好数据，antv中的饼图都是确保有个字段是percent，输入数据要percent

注意有两种：

一种是 transform ，是variable的生成方式之一

另一种是statistics ，位置是在scale之后，geom之前，输入输出都是 scaled value，并且是从属于一个 attr的，所以gpl中 statistics value的概念要有，注意图 2.4 饼图的写法

vega是支持多数据源的，其架构中的branch，collector等也都为此考虑。~~要不要加入多数据源？~~ 从需求的角度，单数据源

只有operator 和 transformer 用名词，它们是抽象的父类，其它都用动词

spec 的定义不用太考虑 reuse，因为可以在 flutter 组件外定义 spec，实现 reuse

可能还是考虑叫 Gesture，今后的 SecondaryClick, Zoom, Hover 也包含进行，这样的一种 touch first

ChartState设为私有的，减少 Controller和其的耦合

Chart不算 spec 和 desc

context.parse为避免重名改名叫mount

思路上讲完全放弃 diff 的想法只有三种会导致图表自动的变化：定义的 signal，data发生变化（实例变了不是内部变化），自动形成的侦测 Runtime 变化的 signal

Desc 中需要包含的信息：id，type，value，param

Scope中包含的项：operators所有op，root：root op，signals（signals直接是 operators 的 desc，今后转换成operator），stream，updates（里面标明source，target，update函数）

context 执行完mount后，就已经把op挂载到dataflow上了，有以下项：data：每个data包含input（Collect），output（Collect），values（Sieve）；nodes：将所有 op 以id为键的速查表，root：root op；signals：所有signal的op；scales：所有 scale 的op。

不过可以搞个diff，一旦 onWidgetChange 不一样了的时候重新构建

设置 context 的目的好像是为了方便查找，比如 scales，比如 setState，getState 获取data和 signal的state，另外通过 context 中的 nodes 可以方便的通过id查找

不刻意追求“函数式”和“链式”的写法，还是用面向对象的习惯

文件夹的命名采用gg概念，而不是spec的包含关系

signal相关放到dataflow里

并不需要spec有递归的parse方法，只要统一弄一个

Chart 需要一个泛型D给表示Datum，如果今后多data了，这个泛型移到data上

collection 这个package有很多实用的功能，比如深比较，比如heap

dim 还是用 1,2,3... 表示，一般认为维度都是从1开始的

user constant不需要在algebra中定义，应该在variable中定义

modifier是“根据被某个其它aes使用的variable”分类，修改 statistics variable

先不做nest

expression 的缩写用 expr ，避免与 exponential 冲突

事件需要添加一些合成事件，arena里先管普通事件

事件可以统一放到一个enum中

geom 只决定两个东西，对dim的增减到固定格式，默认shape，shape不再与geom绑定，custom geom 就是没有dim检查，必须手动定义shape

scale 的分类为 continuous，discrete

如果没有设置position，就自动从variable里找

尝试 element 用不加后缀的

postion还是保留encode吧，说不定有起效，不过记得postion的 Offset 是0-1的抽象的，要与coord结合

其它attr的coord 功能融入到encode中了，postion单独，，那这样其它coord不应该用algebra，而应该是variable（反正都 values range了，代数没意义）

Attr：基本：只有encode，label继承自它，postion继承自它，多了algebra；variable类继承自基本，多了variable系列，又分为连续和离散以及都可以？？？？？？好像结构太深了，毕竟是个spec

scale仅做很纯粹的变换到 0-1,range交给坐标系，tickCount等交给axis（vega是这样）

axis是与dim绑定的，由于存在多个维度，每个维度可有多个axis，为防止嵌套过深，通过数组和dim字段的方式指定。

Default 用继承的办法似乎可行

axis实际的样子，要根据coord，以及此维度上几个variable（或指定）的scale combine的结果决定，scale类型不同的variable不能共用同一个axis

可以定义为signal的值：

Attr设为value时，

直角坐标系还是就叫rect 吧

这个range定义时，需要与手势事件关联，所以它不能定义在variable scale中，因为不知道它x还是 y，在coord中也不应该受transpose影响，所以应该与x绑定，且一维坐标也应该有另一维的设置。为表明与维度无关，不叫x，而叫horizontal和vertical（用全称，这个对外接口清晰为重）

theta和rho和paralle坐标，通过 polar 和 rect 设为一维来实现

shape恐怕还得用类定义并在specification中使用实例，因为可能有参数，不过要定义下 ==

spec 可能不能用 cont

**trans/stat 方案一**

trans不会增减原始数据或改变顺序，只会额外产生映射性的一维variable

而 stat则有可能排序、过滤、增补，生成多维，bin

trans的groupBy可以就用数组，多个就相当于叉乘，它重点是提供涉及到全局的计算，只涉及到单个元的直接用 accessor，

trans的类型定义先采用全最灵活型，并可直接定义 accessor，不过基类中不定义variable和groupBy，根据实际需要

先尝试 trans 和 stat 都不加后缀，两者没有交集，既可以trans，又可以 stat的优先做

**trans/stat 方案二**

trans 和 stat 定义上是一样的，但是在gg链路中所处的位置不一样，因此采用统一的类进行定义 Stat

这样 trans就不是variable的子类，而是与accessor 可选的字段，也仅可通过其它字段定义。

只有部分map类型（不改变data总数）的stat可用于trans定义

在trans中必须指定variable，在geom中如不指定则是指 statistics variable

**trans/stat 方案三**

似乎polygon，edge 类型必与 bin stat 关联

accessor 基本已覆盖trans的需求，为保持简洁性，不再设trans，统一到element下的 stat 属性。

这主要是为了实现图2.2中，stat位于 scale 与geom之间的位置。ggplot2中也只有 stat 的概念。

stat 可以可能排序、过滤、增补，生成多维，bin，也可改变原有字段，创建新字段。它的作用字段由 algebra和statistics variable决定，不过一些groupBy等辅助字段需指定。

polygon必须与 stat相关联

**trans/stat 方案四**

类似vaga，在根据variable建好tuples之后对tuples的处理

**目前确定的方案**

还是采用 vega那种吧，对materialize 的控制更合理。这样data也要允许多个，创建DataSet类，有variables和transforms类，

注意所有dataSet公用variable的命名空间；对于有些生成variable的transform，不加as就在原来的上面操作，加了as生成新的；生成的variable会自动配置scale，当然也可以设置，比如Proportion就自动是 0-1

---

最后尽量做到与 widget、md、captinou、ui、painting、gesture等库不冲突

signal，selection 事件触发是更改性质，所以不应该包value，value还通过原来的方式设置，update中包含preValue

bindState不放在signal中，而是通过spec的diff实现

这样的话，感觉signal的定义用一个map就行了

现在通过主副属性的方式，已经全部实现了vega-lite Parameters 的功能，

value 直接定义，bind，直接写外面state的值，通过diff变化，exp没有必要，如果非要一个依赖另一个，提取到外面的state，通过chart本身向外输出的channel触发

vega-lite selection 中的encodings，主要是为了处理匿名的fields

出于frp的考虑，需要不能给同一时间事件挂回调

如果spec 要 diff 的话，function 好像需要认为都相等，dart认为所有的function都不等

这样的话function不能绑定为变量

label文本还是用 TextSpan，attr额外再把painter的属性添上

graph以内（含包括）都是只有string，aes层才开始有 textSpan，根据需要酌情采用 textSpan（优先）或String 加textStyle，textPainter的属性不在spec中体现，统一加载到scene中

descrete scale 可以记录个bandPosition，表明在什么位置

heatmap、voronoi使用了不同的内置统计方法分面

背景的网格 band grid 等通过 axis 设置

annotation先搞三个

tag，文字，根据两维variable确定位置

region，一维上的区间

line，一维上的直线（弧线）

selection 中的 variables 感觉多个也没有意义。不过为了保持语法的完整性还是保留

tooltip采用 selection触发，不过作以下限制：类型必须是Point；不可toggle，variables最多一个，不单独搞子类了因为要可以共用。

可能要搞个事件，就是 select none

selection 有集中管理的意思在里面，所以还是采取统一定义然后用字符串选择的方式，一定要定义，但可以很简单 Selection()。

常用字段：

id：指自动生成的数字

name：指代这个对象的字符

title：用于 tooltip, label, legend, tag 等处显示的标题

首先要有group variable和statistics variable的区分。gpl中引入了 sv，事实上也暗中引入了 gv



单个tooltip 显示的内容为：

vTitle: vValue

vTitle: vValue

当指定variables时只显示指定的



当共用variable选定时，共用的被移至上面

commonValue

gValue1: sValue1

gValue2: sValue 2



暂时先不做marker，这个和legend一起

点上的标记先不做



const比较复杂，也没有必要性，先不考虑const spec了

事件体系，底层的是 Event-Signal ，Selection 是上层的，仅针对 element 选取，结果是选中的tuples

Interval做个简化，仅可使用scale，也没有translate和zoom，重新scale即可

外向内，不考虑使用Controller模式了，与declarative 相违背，通过diff实现

内向外，针对以上两层信息，做两个 onEvent 和 onSelection

实例沿用vega的习惯称为 View

transform 尽量也做成可扩展的

坐标区域背景色在coord中配置，也可设置 gradient

Spec并不能“拦截”强制要求重写 == ，chart继承的 widget 类不允许重写 ==，由于泛型的存在不能判断用 diff 还是 ==

接口中的函数尽量叫有意义的名字（至少叫mapper）不要叫callback或func

vega 的 dataset取名字段不好，结合g2 和 echart，取名为 source 和 from

spec中先不考虑 data source 的变化

tupe、event 等的相等性后面再考虑不属于 spec

Selected 和 Signals 由于有函数，判断的时候只判断keys

Shape中，由于用户可以自定义shape，要一个函数强制要求其 判定相等（ == 可能会忘了重写）

目前还没有 mustOverride 的注解，通过重定义抽象函数实现

由于在DataSet中还没有dim，所以统计字段皆需指定

geom的几个关键词冲突还是挺多的，加上Element后缀吧

因为 ! 不能重新，所以只能采取构造函数的办法

tuple 由于 id 的存在，还是包装一下好，性能不宜过早考虑

曲线的插值还是实现vega的那些吧



综合考虑：view分为dataflow 和 scenegraph两层，scene成为一个比较抽象概念与element对等，所以当spec不变它也不会变，属于compile graph的一部分，而且这样scenegraph的节点会很少，绘制的时候直接遍历，且可插入重排。

某些op的末端与scene相连，变化会传递到scene，scene不会再往下传递了，renderer会从scenegraph的root开始paint。scene的主要功能是绘制，不负责传递和计算值，所以它不是op

可能发生的事情：

spec重定义：（spec != old spec，注意这与data的变化无关）完全重构，重绘

data变化：从data的op发生pulse，一直传递到scene，重绘

发生事件：从signal发生的operator 发生pulse，一直传递到scene，重绘

resize：（width，height发生变化）resize 考虑做成一个事件，从 ChartSize发生pulse，一直传递到scene，重绘

堆仅适用于需要频繁存取的情况，而且只能pop，不方便遍历（要遍历可以用索引堆），所以compile之后就不动的不需要用堆，只需要执行完后排序一下。

目前渲染结构首先参考 graphic 0.3，其次参考vega

所有直接调用的绘制方法都称为 paint，Paint类型的样式称为 style

层级设置采用 vega 一样的 zIndex 的方式，默认都是0，默认的顺序是：grid , region, elements, line, tag

vega在dataflow中传递的是pulse，changeset是外部传入的，dataflow.pulse 方法会将changeset转换为pulse

pulse和changeset中保存的是放在 add, mod, rem，source 中的 tuples，（source一般指所有背景数据，不太常用）

由于涉及到大量ip计算，tuple还是包装一下

而 operator param 则好像可以直接用map，（tuple特点是用于list中）

event是一种pulse，但仅限基本 op 使用，

将op的param分为两类，一类固定值的，直接作为类字段，另一类从上游op拉取的，它们的值用一个map保存

run的时候，算完某一个后，会把它的targets压入栈中

在后续event触发的时候，heap就是不断把target放进去算的过程

op 的Parameters还是用map不能用类字段（理由：update要用，要能用set方法统一设置处理），可以设置，设置的时候可以设值或op

Op的params接收的时候可以用Map，但内部需要一个类似Map对象，要保存是否modified

Operator 和 Transform的区别是 op处理tuple的核心是构造时传入的update函数，基本上都用于signal，而transform是子类定义的 transform函数

在context中，operator是通过update定义，而transform 是通过类型名称定义

基于此，将op分为 Updater和transformer两类，transformer需要再具体实现

Operator的变量基本都叫op

vega中允许param某项为list然后list中的某项绑定到不同的op，但是包括这个，以及params的list单项脏检查，似乎都只应用到range设置，因此简化掉，万一真有需求，通过 ‘x:1' 这样的param实现

op 中的source似乎专指pulse源，所以换个词 paramOps

在 vega 中，op并不持有dataflow，pulse持有，我们也先这样弄

感觉pulse并不需要stopPropagation，null就表示停止了，passthrough 直接逻辑上返回输入就可以了

pulse中的几个数组可直接访问，而且常被整体替换

感觉 NO_FIELDS 和 SOURCE不需要单独搞出来

pulse fork和addAll之后，由于是直接取数组，原来的都不能用了

每次 fork的时候要注意source和fields和vaga是反的

addAll 目前似乎并不需要

op中的重要概念：

react：在setParams时，对于非pulse的参数是否将自己注册到上游的targets中，如果注册了，上游变化将触发下游变化

initOnly：在setParams时，是否将上游ops设为initOnly，如果设置了，marshall时从这些ops拉取只会触发一次，拉完后就清空。initOnly只在parse spec时connect时用过，所以不放在构造函数中

注意op的连接关系，push和pull有差别，push通过上游的targets以及下游的op.source，pull通过下游的paramOps，而initOnly则仅是pull内的一种区别

设置时的react、pulse，对targets sources的影响比较复杂

op.source 主要用在 dataflow.getPulse中

skip 和 modified 直接用个bool值

op提供一个直接修改值的方法供dataflow.update使用，返回是否更改

op 内的 paramOps，sourceOps，params，targets 都采取事先就有个空的的模式，用 isEmpty, clear 进行处理

op 先仅存在同步的情况

op.pulse 唯一的作用就是dataflow.pulse 取其中的source tuple，而对于这，0和null是一样的，

因为针对什么时候skip的处理updater和transformer有差异，在skip时无差异，所以调整evaluate的提取

感觉还是统一规定op.pulse 一定要等于evaluate的结果比较好，虽然在vaga中transformer里只有结果不为null才更新，但感觉这是个bug

dataflow先只考虑同步的情况

dataflow外部函数都返回this，内部函数随意

函数的布尔值参数尽量设为命名，除非跟在可选位置参数后面不好设置

pulse.encode 和 changeset中的field 都是指的 datajoin中的概念（外加hover），我们不用

既然在Tuple中有了TupleFilter这么好的东西，那就都用上吧

changeset的modify似乎很少用，先写着

先认为pulse和changeset中mod都是存放修改后的值

changeset.modiy似乎仅在vega-function中使用，而这个function似乎也从未被用到

似乎changeset仅起到过 add，移除所有再add，encode 三种作用过

df有异步的功能，op.run先不做异步的功能

prerun和postrun的回调都不需要参数

pulse 的本质：记录op间run时的通信，最关键的是指向source的指针，也可能没有，数组中记录的是约定的相关操作的tuple，为了性能，还记录了filter，materialize之前tuple和f都存在，visit时会临时应用下f，materialize之后filter被应用并清空

ChangeSet的本质：位置应当和op相当，记录对pulse的操作，当执行 pulse(p, source)时应用到pulse上，后面跟个source是因为它有时起到新建pulse的作用，前面的p是空的。

关于tuple modify的一个本质的问题：是否要精细到field；已经改变了的依据是tuple不等还是记录在mod中还是有field记录。op也存在modified依据是什么的问题

在明确了ChangeSet的本质后，可以提升ChangeSet的作用

scope/desc 的作用是作为dataflow初始化的输入

context存在的意义是，dataflow本身并不保存op，op是保存在context的nodes，以id为键方便查找中的，df只是持有touched op的引用

先规定只要data source变了就变化，发射 changeData事件。因为主要优化setState重置数据的场景

arena 保持独立性，event source 可以封装

dart函数的相等规则似乎挺正常的，不过spec中依然不判定因为一般定义用字面量比较多，设一个总的forceRebuild。

ctx中的events()就是df.events(), 因此在 ctx.parseStream方法中处理stream spec时会执行df.events生成事件源。而stream spec这是从 scope.addStream 中获取的

也就是说event source 只能有一个，event stream 可以有多个，df.events方法从event source新建stream，df.on方法将 eventStream和op关联

event stream 并不接入 df graph中，而是指定一个 target op 当事件发生时去 pulse 或者 update这个op

df.run的核心是操作touched op

有时会把某个op的pulse记录在 \_input 中，当df.run执行到 op.run的时候，优先拉取保存在\_input中的该op的pulse

从df的层面，op与op之间存在push连接，主要是通过setParams实现，params中pulse字段就是这个作用，它与param value 和 param op都没有关系，仅表示pulse，可能它认为pulse也相当于一个参数通道

所以df确实不需要针对op的on

将df.events的功能移到 EventStream 的构造函数中

实践证明，文件名就叫类名好，base这个名字找花眼



这里关于event stream是参数化还是子类继承式，它与df方法的关系，event stream可否可串联，是否可挂多个op，selection怎么实现等需要好好思考

vega中的es更多的是起到流处理的作用，因此它可以形成树状结构，每一个 stream只可以挂载一个op（apply方法添加下级stream）

我们也采用类似的方法，以便今后扩展stream的操作符。 stream的定义本身是通用的，df.createSourceStream为每个source创建一个stream，然后这些stream本身可以操作得到新的stream，又可以用df.on方法将op挂载到stream上。除了createSourceStream外stream不可自行创建。

stream有传入filter和listener，又有filter和listen运算符创建新的stream，emit方法暂时不可自定义，它本身不持有source。可以弄个last放上最后一个事件

select不是个事件，而是op，因为它不是“起点”，是个中间环节，它的起点是signal。event stream 大致分为value型和pulse型，通过子类区分

事件源一般还是叫 on, off，特别是on还带类型的，stream一般叫listen。

event 这一线，只存在推，不存在拉，op与es相连时与params无关，只会直接更改值或发起pulse，因此op的初始值也与es无关

定义多个dataset的目的，是为了同一个图表上可以展示多个数据源，from型dataSet是为了有些操作会改变数据源，注意from的意思仅仅是指和那个数据源源自同一个source，variable等还是独立的

op 哪些作为类成员哪些作为params？在vaga中都是用的params的方式，我们也先这样搞

数据源不需要，它就提供原始pulse

changeData这整个一路都先按重置数据来

tuple中似乎应当保存origin，这个单独弄个字段，而datum似乎没必要保存了，它对数据可视化没意义

有一些部件的定义依赖 tuples 因此他们的解析是个 Updater。

scale的求最值的先单独求，如果确有多处用到再提取 meta data

spec中缺少的值有几种补充方式 1.有固定默认值 2. 从Theme中找 3.需结合tuples确定。

结合tuples的看来要用修改法了，在创建的时候不要求所有数值都可以了

似乎不应该是desc，没有必要，而是直接parse方法，每一类一个统一的parse方法

环节op，如果要处理多态的部件，就统一用一个（比如scale）如果就一个可以通过不同子类实现，parse决定创建那种，（比如transform，coord）

scaleconv的逻辑：每次（包括初始）都重新检测一次，先用param，后用pulse

初始化时如果想要只遍历一遍逻辑过于复杂，还是有几个就遍历几遍吧。

aes attr 和 coord ，由于可以接受signal，因此应该都是op，selected恐怕也要放到tuples中

当一个op run的时候，它的pulse的几种来源

op只有一个sourceop的时候

1 如果该op记录在 df.\_input 中有pulse，则使用它

2 如果df当前的pulse和sourceop的pulse的clock一样，就用souceop.pulse

3 否则fork一份 df 的当前pulse，并且将它的source指向souceop.pulse的source

如果有多个sourceop

新建一个multipulse传入所有sourceop的pulse

collect这个节点比较关键，pulse经过它之后会变成它的value，似乎pulse.source都指向这里。可能问题的关键就是要区分不同的区域，它们彼此之间用collect连接

所以现在比较确定，数据流变形后，就会变成不同的 souce，它们用 collect 保存。df被分为不同的区域，不同区域内使用的是相同的tuple。

因此tuples仅保留id。id还是比较重要的，否则很多方法都不太方便

对于需要输出pulse的，都是transformer，但是可以无需输入pulse，df.run中会建个空的pulse，所以variable是transformer

datasouce 和 variable之间还是加个collect的操作符吧，说不定今后可以对data进行更精细的操作。collect的作用是将pulse的addmaterialize成value和pulse.source

op的value似乎初始为null的情况还是比较常见的

在一条pulse链路上，有些op能够转换pulse生成新source不同的pulse，在这些op之后会跟个collect，记录source，

sieve 的作用是：一个op要做别的op的param，它的pulse要返回空的，因此当要把pulse source作为其他op的param时，用sieve做个转接。vega scale由于它天生出来就是空pulse，所以可以直接做param

也不是对所有的op来说add, rem, mod都有意义，比如pie，stack都是直接针对source操作。只有仅针对元，且处于pulse链中间的采用到，add，rem，mod的应用也不能依赖前值。

感觉aes之前的，可能都是source型的了。

collect确实是根据pulse中的add，rem先rem再add的，对于数据源更新的办法就是pulse中增加 remF all。collect先不考虑sort

collect和sieve的区别：

collect处理的是变化，它的出口会保留变化，并且会通过变化生成source。提供给collect的pulse需要体现增量修改

sieve保留source，出口为空pulse（一般transformer可以定义source）

几个重要的op：

collect: 将pulse中的add、rem等形成新的source并记录，一般与datajoin、aggregate等一起构成一种数据的起点。注意datajoin、aggregate等依赖于前面的变化，所以collect也只能用来处理变化（它只处理add、rem对现有source的变化），不能处理全新的source。它会传递现有的pulse，所以不作为数据分支的结尾

Relay: 将一种类型的pulse的change关系传递给另一种类型的pulse，souce tuple 的对应关系保留在value中。

后面的op要用到这个关系的param就叫relay表示当前tuple和原始tuple的关系

sieve：收集souce，用来作为其它分支的op的param。它会建新的pulse，且结合它的功能，所以常作为数据分支的结尾

proxy：将param中'value'代理为自己的值，用来作为其它分支的op的param。它会建新的pulse，不做为分支的一部分

values：提取pulse的souce中的某个字段，形成新的数组并记录，给xscale等用，它原封不动返回现有pulse，但似乎一般作为其它op的param，是分支的结束。

branch的划分依据似乎是是不是同一个pulse，而是否要保留pulse就是看是否要保留add、rem等记录。从深层次讲是是处理同一段pulse，还是作为别人的param了。

在同一段branch中途的op，是可以更换source的，更换了的source如果还有用，就用collect收集，但pulse还是保留，这也就是collect为什么都在中途，末尾pulse不用了，直接用sieve。

统计方法型的transformer，一般会把计算结果记录在value中，这样就可以实现增量修改了。

这是以空间换增量的策略，全清是以增量换空间的策略（前面几个op不用记录了）。到底哪个好？

第一个分支：original value，field是variable

第二个分支：scaled value，field是variable，它们中间通过一个tuple到tuple 的map关联

第三个分支：aes value，field是color等属性，但项是与 scaled value一一对应的。

需要多data souce的另一个理由，比如确实有两组完全不相干的数值数据要画在同一个散点图上，完全没有必要拼接分类

一般位于collect之前的op，输入pulse和输出pulse的tuples不一样的（original value之前的variable和transform认为是一组）

由于scale之前有了collect，所以scale本身就已经具有处理各种change的能力了。至于今后事件放哪里再说。假设传入在ScaleConvOp之前，要保证source 已经是新的。

一般transformer处理change的顺序是 rem -> add -> mod

改变pulse类型的运算符中要新建pulse了。

tuple中的键都称为field包括aes的键，spec或param的参数名或变量名都称为name。

updater思考再三，还是采取方法实现update的方式。如果非要update可变，子类再用参数塞到update方法中

对于dim为1的坐标系，coord的convert和invert函数也当成完整的Offset来处理，至于实际的一维坐标怎么画由Offset决定

attr的converter先不要invert函数，可能都不需要，通过关联记录来查找，scaled value tuples 与 aes value tuples的关系是aes op的value

AttrConv本身似乎是一个固定值，不需要op，直接作为param

对于position attr，由于输出值是对用户无意义的坐标点，所以所有attr定义参数都失效了，并不需要positionAttr了，直接就是algebra

op的value应当没有初始值，vega中op的value基本都是第一次run的时候创建出来的，没有必要一定在op的构造时创建（比如ConvOp）。起点型的op，value直接获取的，就保留（比如Variable）。要用到value的在开头放一个value = this.value! 提醒自己，或者确实需要的进行懒初始化

对于aes，似乎一个一个用单独的op顺序添加是没问题的，group和modify放到最后

Collect并不会创造tuple，只会将其记录到source中

数组可以多次遍历，优先满足业务解耦的需求，因为多次循环并不会改变算法复杂度。

continuous scale 不能统一抽取，因为不一定是线性的。而channel attr 怎只有线性的了，非线性统一在scale中体现。而discrete scale则可以抽取，因为它都是查表

position的两步还是分开吧，虽然循环有两层，但是分离依然没有增加算法复杂度，

algebra的处理以form为核心。

所有op构造函数params放第一个因为最重要

各属性op：

position: PositionOp -> CoordOp

color: EncodOp\<Color\>

​           ChnnelOp\<Color\> with DiscreteChannelConv\<Color\> or ContinuousColorConv

evaluation: EncodOp\<double\>

​           ChnnelOp\<double\> with DiscreteChannelConv\<double\> or ContinuousEvaluationConv

gradient: EncodOp\<Gradient\>

​           ChnnelOp\<Gradient\> with DiscreteChannelConv\<Gradient\>

label: EncodOp\<TextSpan\>

shape: EncodOp\<Shape\>

​           ChnnelOp\<Shape\> with DiscreteChannelConv\<Shape\>

size: EncodOp\<double\>

​           ChnnelOp\<double\> with DiscreteChannelConv\<double\> or ContinuousSizeConv



Geom 中line和path合体，用户自行保证数据的顺序，并且可配置不同size

stack和area的堆叠方式，上下两层，null处理还沿用现在的

按照gg的分发，吧symmetric放到dodge和stack中，它们的domain

还是要有group的思想，stack和dodge就用group的模式，用户自行保证一一对应，jitter中的group指的是domain。groupBy 如未指定，将无法modify，但不放在modifier中，因为有时候group不需要modify。

modifer处理的都是normal value。

jitter先只支持在band内的完全随机。

所有的groupBy先只搞一个字段，因为多个笛卡尔积没必要且容易混乱。如确实需要多个，可以拼接新字段

aes中的position只做到abstract position，后面接modify涉及到分组和联动，就要重新处理了，这段就不属于 aes value pulse了，通过value-param的方式连接

如果某个位置固定需要某个环节一次，那么这里的op尽量用通用的，然后用不同的conv进行处理（比如scale，coord，modify）如果是不同环节完成相似功能，用多态（比如aes，比如trans）

由于现在null-safety了，数字是否可用只要判断 isFinite

abstractOriginPoint是有必要的，因为对于abstract point的值，当continuous scale的min不为0时，0不一定对应0，discrete scale也要考虑aligin。

可以考虑和以前一样，将origin的求法放到scaleconv中（因为在外面根据不同类型的original value代入求还是挺麻烦的，不如通过 scale 的不同子类实现）。由于scale conv 是动态生成的，这就要求有一个op求abstract origin。

目前不是所有的 converter 都是convop生成的，比如aes conv都是直接生成的。mdifier还是搞全套吧

abstract point 一律改称 normal point

geom不规定点数，是否需要complete由shape的complete方法决定，这样geom唯一的作用就是规定默认shape

每次绘制时，会取每一个group的第一个shape作为represent，调用它的drawGroup方法。

complete还是应当在shape中定义，但不应当在paint中执行，而应当在group完了，modify（假如有）之前执行

shape中用到多个点的时候，尽量用 0, 1 防止多了

Tuple的id直接用实例代替，因此Tuple只要搞Map<String, dynamic>，Pulse还是要用Tuple的，因为要根据键查找哪些mod了。

在dataflow中，aes attr 依然采用tuple，在进入scene op中传入shape前转换为 aes

complete不应该放在shape中，它处理的是抽象的normal point，目前先不要考虑优化那种，统一的弄个函数。

shape中操作的对象成为 group - item

文本的绘制 textPainter 需要 textSpan 和其它属性，每个item的aes仅决定textSpan，其它属性由shape统一决定。textPainter装载好这些特性后，执行一次layout就可以知道它的实际宽高等，以便进行调整。

channel还是需要一个有values和stops构成的，这样能起到palette的作用。这样从attr本身就不能推断到是否连续，都是values来起作用，discrete时查表，continuous时结合stops做渐变

label决定还是不用span了，要干净点

scale 的 align 还是用0-1以便与d3,vega一样

对于极坐标的绘制，需要normal position，因此aes中需要保存

coord前后的点称为 abstract position 和 canvas position。用abstract因为它不仅仅是0-1，而且与实际位置无关。为避免混淆，aes中明确区分这两个属性。这两个词一目了然，而且严格区分，方便在shape中使用

Interval那些shape还是都统一成rect吧

扇区圆角取br/r = tan,这样弧上切的小一些

图形圆角还是尽量用borderRadius，避免与极坐标混淆

逻辑运算符 && 优先级高于 ||

f2中绘制sector时0.0001的判断条件都可以去掉，多此一举。

Paths中的工具类的参数定义，以方便shape使用为准

borderRadius由于x,y可能不同，所以肯定是

size如果没有设置，就不会有aesop，shape中将取shape的default size

x是domain，y是measure，（transposed）相反，一般认为domain不会nan，measure会。通过abstract position 判断 nan，因为这个判断只对数据负责，canvas position shape负责处理

感觉coord op的转换没有必要，还是和之前一样，都放到shape中处理。

对于bar和histogram由于size等机制不同，绘制不能放在一起

sector的label偏移尽量用象限处理。

labelAnchor还是每次都算下吧，因为外面end基本上是必算的，省不了多少，而且到里面再算反而浪费

coord只有一维应当是只有最后一维measure维，domain维挤在一起

smooth只要搞一种吧

voronoi太复杂不画了

每个op的params不单独写子类是因为写访问器和构造函数并不会降低字符串写错的概率

关于初始化的地方这样，view的构造放在第一次getPositionForChild中，dataflow里必须有值才能run的op（比如size，variable）构造函数里设置值

region背景不符合可视化精神，移除。

每个variable都有自己的scale，理论上来讲，需要相同scale的variable应该是同一个variable，它们是一一对应的。而在同一维度上，axis也是和variable（scale）是一一对应的。

axis与数据无关，只与scaleConv有关，

关于 variable 目前最现实最简洁的方式，是将元信息放到scale中，由于variable和scale是一一对应的关系，scaleConv就是variable的化身。

tick指抽象的value，小线段叫 tickLine

tick作为抽象的，还是放到scale中吧，理论上更符合gg，实践上方便与min，max的调整结合，作为ticks参数，这样scale conv的计算放到构造函数中，反正每次都是构造新的。

tick的设置采用统一的 ticks-tickCount-maxTickCount 的模式，linear另外有些interval相关。

所有的spec中的默认值在parse中插入，除了动态生成的特殊情况（比如scale）

由于scene要求编译时就生成固定实例，所以当多态参数动态时它本身不可多态（比如决定axis的coord等是动态的），这样就需要painter对象负责多态

查找scales的操作比较简单，就不要徒增op了

axis的内部实现上，按“设置才有”的原则，外面可以根据大项是否有确定用不用默认的

现在region已经和coord没有关系了。为了突出这种无关，coord conv 中不持有 region。对于element和annotation的clip，rect coord的region是一个rect，polar是完整的circle。

style类的class不属于 spec了，默认值都加上。有统一的const的默认值，后面再设置

axis是与region绑定的，与coord的range没有关系，position也是region有关。

在考虑 region和annotation的关系时，一个基本的优先级是先认为coord的区域只会大于region，第二个就是polar只会变动外边缘。或者说polar的 clip region是

region 是图表padding导致的物理限制，对于rect是方形，对于polar是圆形。coord的range反映的是coord所需范围和region之间的抽象关系，超出region（方形或圆形）的部分将不显示（被clip掉）。因此polar是管到整个plane的，不存在缺角度和缺中心的问题。缩放应当主要是rect的coord区域大于region和polar外边缘变动。

为确保axis一直能被看到，它是依附于region的，附着于region的边缘，且在轴线方向上超出region的项不显示。

annotation 是依附于coord范围的，也应当被region所clip

dim顺序，以algebra为准，transpose后的称为canvasDim

pre 和 post 前缀还是用驼峰吧，



**重新思考**

初始化/spec发生变化：rebuild整个dataflow

data发生变化：从data开始重算主链路

signal发生：从signal开始重算下游

selection是aes之后的一套新的aes，上游的aes作为initialValue。

静态图特点：

一旦创建结构不会变化（包括rank等）

op只有params和value，params如果是op则是取其值，

value是op的唯一输出，且也仅需以输出为目的设置value，其它状态可可设置成员变量。 render的scene也不作为value了，它是副作用

value可初始化时设置（也可不设置，在第一次run时根据上游param计算）不可更改。

动态的变化以op被关联stream实现，stream发射时update这个op，并touch它，然后run。

op的param只有通过构造函数设置，df.add中也是。

df先只需要异步的run

op的qRank好像不需要了。

preRun postRun好像也没有必要的。

数据特点：

数据也是普通param和value，由于是有向无环图，param和value可以是同一实例

它分为 original，scaled，raw aes，aes四段，每次数据更新都是全量更新，相互之间以index关联。

---

event stream本身是不保存状态的，因此event stream下面要有个存放值的op，它们一般是dataflow的起点，要设置初始值

目前先完全不区别对待value为tuples的op，tuples的不同也以实例区分（每次都不同）

为保证安全，使用tuple的地方一律从collect收集，op的参数中，tuples一般指没有处理好的，而从collect取的叫 originals, scaleds, aeses,

按现在这个思路，aesop适合做成一体的。

因为要与 CustomEncoder 交叉，每个 Attr就不设子类了，通过泛型分别，即Encoder的实现主要区分功能。

设置Encoder的目的是为了所有attr在一次遍历中计算、组装。

吧创建除 positionEncoder 外的其它encoder的创建交给parse 吧

动态变化分为状态切换（initialValue -> value) 和状态转移（preValue -> value)，signal都支持，select仅支持状态切换

aes之后的select要生成新的实例，保证initial aeses不变。

原则上所有op的value都要返回新的实例，这样感觉其实内存占用浪费也不多

几种特殊类型的op

transform，modifier，有可能直接修改返回params中的tuples，所以后接transform的op不能直接取值，需要用一个collect

select为了保证能记录到原始值，整个都重

似乎只有把select放到modifier之后，才能保证有向无环图。

提供select的status和signal的event的op必须具有一个性质，即它的值被用过一次（df run过一次）之后就返回null，这通过op的consume实现。

这样与stream搭接的op，DataSourceOp，SizeOp是不consume的，GestureEventOp，ElementSelectStateusOp 是consume的。

position目前设置为不可通过selection更改。**select之后如果需要图形的变化，通过shape更改**

无论从vega selection的定义上讲还是实践上讲，都应当是从抽象的variable和scaled value对比确定selection。被stack了的，理论上应当只查找x，dodge和jitter都不影响position的查找范围。

chart spec 和 dataSource都设置一个三态参数 rebuild 和 changeData，true表示每次都更新，false表示都不更新，null表示根据diff规则。

dataSet不需要名字，因为我们定义时关注的是variable，而variable可以根据index查找dataSet

selection可以定义多个，以实现长按和双击效果不同。但是多个selection之间的 on和 clear不能相同，这样通过 gesture的竞技性保证了selection的竞技性。

对于同一组data，on和off是针对整体的，通过selectes是否为null判断，当on时，每一个element不是selected就是unselected，只需要 int set。

ElementUpdateOp和SelectOp他们的实例对应整个data，在parse中先要筛选出与该data有关的selection。他们都是有状态的，为当前这个data的选中状态，SelectOp通过暂态的Event修改状态。

selection先只考虑针对元素，line area这种不考虑selection

aes在group-modify之前不能获取canvasPostion，因为modify是针对 abstract position的。

检测针对groups，对其中的position通过coord转换， point select的定义是：距离最小，且在邻域范围；interval的定义是在rect中，都有 dim null, x, y 三种模式。variabs的作用是找到点后再添加对应variable相同的点。

select update针对已经group-modify之后的值，原因1要尽量往后放，减少要更新的op，2modify之后的position更准确些。实现上可通过二重index检索。

检索只通过abstract position，shape 族决定默认的dim模式，function（除了point）默认是1，partition，custom默认是null。

由于vega-lite中所有selection的关键词都是select，我们也用这个

很多shape要求每个item的shape是同一族的。

aes还是要加个index的，便于检索

select中的variable只有一个，避免or，and歧义，也够用了，类似groupBy。为避免歧义，PointSelect如果设置了toggle就不可以设置variable。variable的含义是：同时选中该值相等的项，和vega的field一样。

pointselect在单维的情况下，强制nearest方式，testRadius无效。

没有选中点（interval中无点或point中非nearsest模式下点空白），视同触发off

需要处理data为空的情况，现在的逻辑中先认为data不为空。

selector“是由手指创造的”，eventPoints是它的属性。同一时间只有一个当前Selector。它由SelectorOp控制。

而data、coord等是select函数的参数。

select中由于dim定义null是都有，因此没有默认值了。

一般position的最后一个点代表statiscal value，作为 represent position，也可自定义。

tooltip的crosshair无论是g2还是echarts都是要可以跟手和数据点两种模式的。而且可以不同维度分开。

event大类改成interaction，resize，changeData等也是广义上的系统互动。

guide中，scale由于只有两个axis和legend而且常用，放在外面，单独增加个interaction类目，放tooltip和axisPointer（名称取自echarts）

如果dim用null表示xy，则要有个前提，即所有默认的dim都是xy，

对应dim现在有的需求：

1.coord中表示dim数量

2.axis等只能对应到一个dim的表示哪个dim

3.有些比如select等要表示对应到哪个dim或所有dim。

经过思考再三，dim还是用int不用枚举，因为x,y,xy并不是平等的，第一层是“指定维度”和“不指定维度”两层，对应的是int和null。coord还是用dim，这个一般不会误解

还是只要一个数据源了。理论上来讲，没有关联的两组数据不应当放在同一个坐标系上，之前认为的那种需求应当属于facet。

但还是设置个DataSet，这样相当于从data到 originals 是一个独立模块，chart只负责originals，也避免D的泛型写到Chart上

Crosshair和axis类似，也是指到region边缘。

**对于极坐标的region边缘这个问题，对于element，不设限制，取rect region 的自然边缘。crosshair、axis这类背景型的，取坐标定义的扇区**

region也由coord持有吧，简化df的拓扑结构。反正coordConv的成员都是final的，也不存在数据一致性问题。这样凡是要用到coord作为参数的地方，就不需要重复的再要region了。

graffiti中setregion还是与coord无关的，它是与图表无关的引擎。

selector的结果中只能用int，否则选择时的逻辑太过复杂

tooltip 和 corsshair 与select的对应，先按最简单的方法，只可对应一个定义好的select

tooltip先不要设置太复杂的格式，仅有一个textStyle设置点颜色大小。

transform 中的 map，filter，sort 传入的对象都是整个original，这三个方法不宜改变variables

parse 函数采用最简单的根据spec往df上add的方法，在view的构造函数中调用。

view构造函数只会构建df，但不会run以及paint，只有事件会导致run。第一次run是在getPositionForChild中resize之后

每一个大项的parse函数单独写，输入需要的spec，op，返回生成的最终op。value型的以及其对应的event source都在parse中解析

arena 应该作为chart的抽象的基础部分，传给view

parse过程中有一些中间结果，似乎确实需要一个scope存放，便于记录一些op和map，统一parse函数的格式。

transform算在variable里面。

collect似乎不需要

多个geom在parse的时候通过index对应

position可以默认为variables的前两个cross

目前默认 attr 要么不设置用默认的，设置了就要把必要的配全

parse的过程原则上集中到模块的总parse函数中。

三大事件源，dataSource是在parseData中，size和gesture单独搞，它们有可能被其它用到，而select在geom中。搞一个signalReducer，向所有signalOp发送统一事件。

gesture arena改造成一个流式的，

~~arena为防止listener泄露，还是在view中创建实例~~

每一个 EventType 设置一个 source，因为绝大部分value op 只处理一种 EventType，能提高一点性能，而signal可以采取多次listen的方法。

signal的键主要用来区分gesture、resize、输入信号等。

多个select的时候的clear逻辑比较复杂，所以先采取没有默认clear的方式。

在op params中，由于op和值等价，且每个自身op适用范围小，所以参数名不加后缀，而spec比较特别，故命名类似 conv，spec

scope与parse中，也是spec，conv，加后缀，op不用加后缀

同时表示值和op的命名，以值为主。

---

由于不要限制用户指明泛型，Variable中的scale先强制要求。

op需要有一个标明本轮是否已运行过的标志，因为touched的元素不唯一。不通过类似vega那样记录stamp的方式，因为希望更状态化。

view的构造函数中放入size，强制要求。

给op设置一个 isSouce 属性，是的不touch。

通过accessor而不是variable的泛型，可以判断默认scale而不需要显式的泛型

在没有仔细思考之前，先不上theme，目前来看theme的意义不明确，所有设置可以通过具体的spec实现。只需要合理的设置好默认值。

避免chart泛型的理由不成立了，dataset也没有了存在的必要，反而加深了层级。先把variables平铺出来吧，今后要多数据源的时候再说。

changeData改为三态：true一定change，false一定不change，null，根据==判断。

为避免与widget库中撞名，Transform的基类改名VariableTransform

aes，geom，select 的parse的分布有点乱

guide等由于涉及到null表示不要，因此还是通过defaults来进行设置。

Theme没想明白，先不加，需要方便的放到 Defaults 里。

spec 并没有必要是final的，反而影响了复用部分修改的需求。

element 的初始化 selected 还得带上selector名称，用map的形式更简洁一些，且提醒必须要设置select，不过map中只能有一条记录

每次绘制前，还是要重新sort一下graffiti，因为scene是固定的，但scene上显示什么内容可能会被动态改变，zIndex是动态的。比如selector

在RenderOp中，如需此回合什么都不绘制，需将 scene的painter 设为null，无需设置clip

gesture中需要带arenaSize，因为“在100px的区域划过10px”和“在50px的区域划过10px”不能被认为是完全一样的。这个值用arena的值，因为本身 gesture-arena的值就是抽象的与chart无关的，也好实现。只需要size不需要rect是因为gesture中一般用相对坐标，arena的绝对位置不重要。

对于离散的attr的values，设置的values枚举长度必须大于 scale的值域长度，否则会报错。这样是合理的，因为你不能确定超出部分该如何对应，且这个枚举本身就不应该太长。

GradientAttr也可以是连续的，Gradient类本身就有lerp方法

dataflow中加个dirty字段，只有render op 有一个执行了，才会 repaint。

对于polar coord，要设置一个clamp，r不能小于0，先只这样规定，angle再看看

region的限制是图形的限制，而不是坐标系本身的限制，rect坐标系h和v都是无限的，polar坐标系r必须大于0，所以clip仅切region的矩形.

linearScale 加个margin属性，方便根据数据确定最值

在coord中，rangeXXX反映的是抽象域的大小，具体域的大小rect中固定是region，polar中可自定义。不过注意的是，这个具体域不等于 clip，clip的是region。

canvas绘制阴影要注意，先drawShadow，再drawPath。

如果本体可能是透明的，注意drawShadow的transparentOccluder要设为true，否则会很丑。

axis label的offset不要受tickline影响，因为默认没有tickline，有的话让用户自己调节，否则反而让人困惑

必须确保同一个element中的同一个维度的各variable 的scaleConv 相同，因此首先scaleConv要有等号重载，这项检查最好放在positionOp中

实际图表的代数形式中出现unitTag要怎么办还是要考虑下

现在先不考虑 algform 不齐次需要补 unitTag的问题

关于modifer，感觉还是g2的那种更科学，带串联，带单独的symmetric，这样至少画漏斗图更简单。这就带来了一个逻辑：modify之后的图形 position已经不能反映对应的值了。

需要考虑坐标系中某维度的方向（scale？coordRange？）

shape 中还是需要提供 origin 的，多了总比少了好，比如现在pyramid的逻辑，就应该是收到origin中

数字相等要尽量用差值很小，避免出现浮点数精度问题。

遍历寻找最值时，初始值不能取第一个，因为如果第一个是nan，会导致所有比较无效，应该去正负infi

partition elements 也可以有 radius的，因为分割空间并不一定要完全充满。

borderRadius统一通过 BorderRadius类来

每次页面发生一点变化时，会执行paint。所以paint会被频繁的反复执行。现在paint的输入是group、coord等，paint方法中的计算还是太多了，需要固化更多的东西（类似之前的引擎）。

shouldRepaint 起到的作用很有限，绝大部分情况下都是要执行paint的（哪怕shouldRepaint是false）。所以优化主要还是靠简化paint方法

为实现paint函数尽量简单的原则，painter类的paint方法要尽量简单，不出现判断等，功能放到不同的painter类。将判断等逻辑放到op中构建painter的地方。

改造graffiti，存储绘制信息的称为 figure，获取figure的方法称为draw

paths还是放到公共util中吧。不光光是shape中用

Single means both 不是一个好的设计，还是老老实实用 [dim1, dim2] 这种形式

对于Figures为空的优化，内部的根据实际方便来，shape中统一返回非null，在elements中判断是否为空。

如果 Paint的style不是 stroke，drawPath 不会绘制线条，但drawLine会

通过性能测试，优化了 paint 方法后比之前每帧运算时间缩短到原来的 1/2 到 2/3 的样子

~~label的align大多数时候是通过内部机制决定的（比如axis的象限、flitp，interval的上中下），用户只通过offset调节。而tag可将align设置成可用户自定义的。~~    align 应当作为label的一个属性，放在LabelStyle中。因为它和offset地位相等，并且两者结合控制label的旋转，只有它可设置了，才能控制旋转轴。即anchor + offset是旋转轴，然后再根据align确定paintpoint。但是align的默认值有其特殊性，特别是在极坐标下，需要动态计算，所以labelStyle中其可为null，paintLabel函数中的为。default align 参数

tag如果设置绝对位置，会不限于region，变成全图表可用。

现在有了Figure的概念，可以将tag和figure统一，提供更强大的功能，然后在抽象个tag

为强调防止混淆，Mark中命名为relativePath

elevation只是增加了一个阴影，并不能使视图在上层，决定上下层的是绘制顺序

注意 用到gesture.PointerEvent的时候要用localPosition（localFocalPoint)

RenderOp需要处理的不仅仅是figures，还有zIndex和clip，所以没有通用的FigureRenderOp，内部工具一般直接将生成figures的工作放在RenderOp中，但有时候也需要单独的FigureOp（比如抽象提取（FigureAnnot）和用户定制（ToolTip））时。

tooltip可以选中多个tuple，这发生在select 设置了variable或为 interval selector时。因此对tooltip的select不需要做限制，如果选中多个且位置不为followPointer，位置取其中心（主要是为stack服务）。tooltip的输入为多个tuples

当处于滑动的组件中时，onPointerDown第二次似乎失效了。

重构以 gestureDetector为基础的手势事件

由于 scaledetail 没有PointerDeviceKind，所以需要在gesture中加入。经实验发现，任何point一定是以hover开始，所以就从这里更新

现在遵从touch first 的原则，kind分为mouse和其它（都当做touch）

对scroll和hover还是封装一下，因为pointerEvent是底层的，gestureDetector是对他们的封装，因此hover和scroll也封装。

pointerMove 总是会发生，在scale之前发生，当scale只有一点时，pointerMove与scale的位置一样。

scale当有两点时，只能用来计算比例，因为focalPoint是它们的焦点，pointerMove的点也是跳动的，不能确定是哪个，它的scale是自开始起的，所以需要一个preDetail

还需要一个moveStart，才能实现画框的功能。

scale的localPosition就统一取focalPoint吧，两点的时候反正也没啥用，跳来跳去的pointerMove更没用

由于scale的功能限制，现在interval scale 的功能改为

先统一采用pan就是移动的方式，一个因为移动端框内外不太好选，另一个让用户养成双击取消的习惯。

scale中的几个delta并不是距离上次的delta，而是距离panstart的delta

tooltip也给搞个类似figureAnnotation的anchor。

select要做到完全的值检测，是有意义的：1，不需要每个点都convert，只要invert一次；2，使得单维度监测有意义。但缺点就是：interval selector 在ploar下必然是扇区。pointSelector的test距离要设计一下。

polar到底怎么搞还没想好，先规定interval只可用于rect坐标系

首先 testRadius 需要是实际长度，比较直观。对于单维度的，直接转换，对于全维度的，取平均值

发生手势时，selector一定存在，设置select的逻辑，一定会返回set，没选中就是空的。由于selectedPoint初始值是 0,0，所以没选中假设选中的位置就是 0, 0。tooltip再加个逻辑没选中不渲染。

radial标签的位置是：在轴线顺时针的后方，它和circular 的”外侧“情况还不太一样。还是用 if else 直观。

环通过两个半圆绘制

感觉coord中还是要用dimCount，“维度数量”和“指定维度”进行区分

dartdoc会合并getter和setter，并以setter为准

注释在注解之前

控制行长在80左右

chart的对内对外通信先不弄了。

为方便使用者理解，将Original命名为Tuple，它对外来说最重要，占个常用的好名字。

spec还是都采用可null的形式，在spec中注明默认值。并且以 if null 这种方式表述。意义上确实可以“没有“的不用特别注明

对应成员变量的注释（包括函数），要么是名词，要么用 Indicate 开头，

注释 this的使用规定只是说要指代对象时要用this不要用the，别的要特指的情况可以用this

signal 还是不要用map了，由于不能指定泛型没什么意义，还使得层级和概念特别复杂。

还是应该叫selection，这是类型名，vaga中是那个字段叫select，但是暗示这个对象叫selection

~~select、signal是概念总称，触发是selection和event，处理是update，字段分别叫 onSelect, onXXXSignal。event 经过signal op 集中发射后，就称为signal，有时候signal就是指的event本身。~~  感觉event和signal是完全重合的概念，将event术语完全替换为signal。select也统一到selection，减少概念方便统一

SignalUpdate 似乎并不需要区分event类型了，因为signal本身就是一个统一集中发射的东西，SignalUpdate要能处理所有类似的event

signal是一个信号，selection是一个状态，信号改变状态，onXXSignal要处理的是离散的信号，onSelection要处理的是不同的状态。

nearest还是要默认true的，因为绝大部分人在非点图中认为只要在图形范围内就能选中

行文中更多的以数据tuple为主体对象。

geometory element 的定义中抢到graphing的概念

区分一套element和单个element用 element series 和 element item

tooltip render 中引进 selector 和 scaleconv的目的是要variable和 title，而这些本就应该是用户定制的，因此不需要引入，还加重了心智负担。假如是要造一个比较通用，可以用高阶函数。

不要用draw这个方法名了，统一到render，只提供figures或将figures设置到scene。

图表的size在生成时还是叫 size，使用时除非发生冲突，否则还是用size，尽量在doc中表明含义。



interval in rect coord

bar with tooltip

transposed

dodge

stack

有标签的漏斗



interval in polar

donat

radius rose

stack rose

race



line and area

smooth line and area with nan

river

spider net



point

various shape point，coord can move, region annot, trigger tooltip

axis in center

polar coord, with a danger tag

1d coordinate value.



polygon

heatmap

corner radius heatmap

polar heatmap

sector polygon



custom

candle stick

custom triangle

custom tooltip



bigdata



避免label-text的设置过长，将核心参数设为位置参数，将lebel syle设为可选位置参数

```
   variable    scale           aesthetic                  shape
      |          |                 |                        |
data --> tuples --> scaled tuples --> aesthetic attributes --> figures
```



将所有的spec都放到chart中，移除spec类，这样做文档最简洁。

其它注释，类和字段、方法也按文档的方式，因为绝大部分是op，其它类不多。不过语言上可以不要那么严格，以表意为主，可多用引用。op的注释方法再想办法

方法中的注释在独立行，用双斜杠，

非文档的一般构造函数就不加注释了。

if else 等的注释，写到分支代码块里面，用散文的方式

op的依赖关系尽量用 souce 和 target 

在注释中无论 df还是op的run都统一为术语evaluate

根据数据形态的不同，将整个流程分为 variable, scale, aesthetic, group 这几个stage

由于 selector scene 肯能会出现不同 zIndex 的 selector，所以 zIndex 设置是动态的。

zIndex 与 scenes 排序的问题，还是采用基本不用排序，除非被通知了的方式精细控制

注意对于selection和signal update op，当其它变化引起的pulse不会触发它的 evalute，它会保持当前值

定义为 A grammar of data visualization 数据可视化语法，grammar取其广泛义，data visualization 比 graphic

更摩登更准确更广泛一些，同时也能与专指的GG区别开来。而graphic typological, declarative, interactive, animative 是特点。

解决 element label的问题，定义是：

对同一个element（哪怕是不同group）所有标签在所有图形上方，（不同element不管，如需标签在上方，把标签配在最上方的element中）（shadow还跟着原来的item是对的）

对于使用场景很多的stack、饼图都得这么搞。而像点图图形被完全遮挡，label却出现在上面的这种情况，我只能说，它不适合加label

实现方式是：

在ElementRenderOp中将两者分拣出来。虽然这样在性能上差了一点，但不在shape中处理是因为那很难搞，而且render差点没关系，不是paint就行。

Nest:

由于nester本身已经在tuple中了，事实上nested已经不重要了，但为了代数规则，还是需要记录 nested

nester 和 nested 都是form，一个表达式，应当只有一组nested和nester，表示数据只能有一次分组。这不是代数本身的要求，而是实现的要求。为保证这样，每次nest后要聚合，无法聚合报错

nester是数组，表示多重nest，多重nest、和nester是cross的情况，按笛卡尔积进行分组

nester 是blend的情况，书中没有例子，也按笛卡尔积进行分组。因为：第一感觉就该这么弄，别的也没法弄，第二不管是cross还是blend还是nest 的结果做 nester，原则是能分尽量分。

虽然都是笛卡尔积进行分了，但是存储上有差别，体现代数规则。

proportion transform中的groupBy的功能，主要就是为分组配套的，因此也改成 Varset，用它的form，命名为 nester，用户自行确保与想要的nester一样。

Nest实现：

对于仅有nest的情况，根据结合律，以任意方式添加括号都不受影响，即nest的定义是最左端的nested打头（没有就取其form），依次将所有东西添加到nester

奇怪组合，nested可以不等，这是故意的，为了满足代数规则，但是两者发生cross和nest时，必须保证nester相等。

form和nested不一样的情况，似乎只会从cross中产生。两个nested相同，form必相同；form相同，nested不一定相同。

**定义 nest**：由于nest是nest的发源地，所以所有操作都按定义设定

form取左侧form；

nested取左侧form；

nester依次添加右侧form、右侧nester，并深度去重。

**定义 cross**：

form取两个form的笛卡尔积；

nested两者都没有就算了，只有当两者之一有时用那一个，两者都有报错；

nester同nested。

**定义blend**：

form两边addAll后，齐次化，然后深度去重；

nested两者都没有就算了，

​    两者相同时（此时form必相同），左结合律，nested为此值，两个nester必须为单元素，两个nester进行addAll后深度去重（c/a+c被认为非法）

​    两者不同时，如nester相同，右结合律，nested两边addAll后深度去重，nester取那个nester

​	nested和nester都不同，报错。



图形代数英文名称为 graphics algebra ，不大写，不加 the

感觉所有的parse都放到parse函数中好，现在这样分没有意义，而且完全不知道哪个在哪里，现在后面 aes、element、selection完成窜了。

nest和cross分面，在本系统中的区别，体现在 DiscreteScale的values上

groups现在还是用list表示，今后如需要，大不了再配个对应的nester值的list。用nester值做键的map不太靠谱而且麻烦，不如这种都用list的，相当于index是键。

分组的时候体现一下nest，就是每分完一次，去除一遍空数组，这在多重分组的时候是必要的。

尽量让从前完后的nester相同的靠在一起。

按照flutter项目的习惯，test文件夹就是单元测试，如果需要再搞同级的其它文件夹 text_fixes 等

scaleConv.formatter 泛型的问题，对比convert，似乎是因为 formatter 不是方法的原因，套个方法解决

time就不要引入 intl库支持mask了吧，那样要引入额外的规则和库，用户可通过fomatter函数和自己引入intl实现。

类中，直接在成员定义时初始化优先级最高。

所有spec中函数类型的property，还是都按名词命名吧，因为用户关注的它是什么（出自 Effectiv Dart）

selection 同时唯一性：

现在的逻辑是这样的：同时只有一个 gesture -> 现在规定一个gesture只能定义一个selection -> 所以自然产生对于同一个element同时只会发生一个selection

但是对于同一个element同时只会发生一个selection应当是一个额外的规定，同一个gesture应该可以定义多个 selection，同一时刻产生多个selects（用map存储），而在update中判断onSelection不能定义有同时发生的selection

对应 element update，最重要的目的是，同一时间只能有一个selection起效，当只触发一个selection时，OK，当触发多个selection时，必须确保只有其中的一个在defined names中

selection定义中添加一个仅在某些设备上运行的开关（signal中可在实际Gesture signal detail中判断设备）

tooltip添加一个自动往里挤的功能，可开关

现在新的selector渲染机制也不需要动态zIndex了，决定把改机制去了，zIndex都是静态的。

默认值应当尽量在parse中设置，而不在op中处理

矩形树图 treemap 本质上还是图可视化，对应树状数据结构，先不管。

echarts example upgrade

1.当selection设置了variable，默认也是multituples

2.增加OrdinalScale.inflate

3 FigureAnnot都不要clip了，因为它自然发生时总不是好的，尤其是在首位数据处，可以伸到padding里面，如果确要clip用户自行设置path

4 chart padding 也应该是size的函数

_ChartLayoutDelegate 关于relayout的机制恐怕涉及动画时还要再思考一番，现在就先用 shouldRelayout一律为true的方式

spec的hash和相等要再好好研究一下，现在先全用rebuild控制

在scale range需要计算时，如果所有值都一样，interval就取这个值的绝对值，时间的话取1s（国际标准单位）

antv scale 的 nice number计算已经早就改为用d3的了，后续需要更新。

这是flutter team对于虚线的讨论https://github.com/flutter/flutter/issues/4858

目前来看由于虚线的实现性能不好，按照消耗高的要实现起来比较麻烦的原则，没有直接提供接口。它可以通过Path.computeMetrics 实现的。因此flutter并没有不鼓励使用dash，只是他们觉得应该用一种麻烦的方式用。

就用path_drawing去实现吧，因为它是flutter成员做的，并且表示它和本体是一样的，只是为了遵循高消耗高麻烦的原则没有加入本体。

charts_flutter中的虚线是自己实现的，只能画垂直或水平。fl_chart等中也是用的path_drawing

什么地方提供dash api，就是当这里不能直接设置path时，可直接设置path时自己调用Paths.dashLine

不管是什么类型的 source path，都叫 dash line 吧，这好像比较符合 flutter的哲学，就是一段一段分隔的线

hash选用31做底数，因为它1是个不大不小的底数，2.31 * i == (i << 5) - i

## TODO

整合errorlog，需处理：throw, assert, list.single，singleIntersection

tooltip grammar

legend grammar

in and out communication
