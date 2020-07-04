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

存在大量“仅保存props”，“追加混入props”的理由

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



## API

api 中的类使用段名字，实体类加后缀

笛卡尔坐标系用 Cartesian

数据感觉还是要采用List<Datum>的形式，并需要 fieldMapper

允许用户输入的数值泛型应当是 num, 然后内部需要double的时候用 num.toDouble

!!!: 泛型是很重要的，但要用好