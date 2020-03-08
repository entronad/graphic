包含两个模块

canvas -- A canvas shape library, also the rendring engine for Aesth.

chart -- A charting library with the Grammar of Graphics.

一个图形引擎，应该是一个完全抽象的对象，在构造时传入 Canvas 和 ValueNotifier<自己的手势事件类型> ,只管一次绘制，不管需不需要重绘，裸用的时候在 paint 方法中调用

采用完全配置式的？会导致一些真正需要控制的地方不好弄



或者以这样的形式呢：图形引擎包含 widget，但是配置是以命令式的，配完了返回，

这样的好处是

- 功能完整，包进了手势检测器，也可以把自身作为vsync而不需要暴露

- 可以获取引擎实例，进行使用过程中的命令

- 同时也可以进行只有命令式可以完成的配置，比如响应事件中的回调配置

这样就是引擎本身是实体，上层都是抽象的。

将引擎和图表都放在 aesth 这个项目（相同的repo和lib）中，分别在 canvas 和 chart 这两个目录下



最终的 Canvas 是一个 Widget ，build返回的是一个类似 GestureDetector(CustomPaint) 的结构，所有的命令式配置须在使用者提供此 Widget 的函数中 返回前执行



要做一件事，就是将 g 中的各种参数尽可能的“dart化”

addShape 方法以传入的 ShapeAttr 类型来决定画什么图，ShapeAttr（比如 EllipseAttr）命名参考 g 便于关联，参数参考canvas.draw，使其更 “dart化”

---

注册事件通过Shape或Container的on方法 (EventType type, F callback, [Set<String> delegations])

首先定义一些高级的手势类型 和一些低级的手势类型

获取 longPress doubleTap 等的位置：https://github.com/tomwyr/positioned-tap-detector

将手势的 scale 转变成矩阵：https://github.com/pskink/matrix_gesture_detector

gesture 的侦测比较复杂，需要提供一个包装组件，该组件接受 ValueNotifier<自己的手势事件类型> ，以此为与图形引擎沟通的纽带

---

flutter 本身的动画机制不直观，且耦合性较高，封装成类似 g 的

g 提供以下功能：根据提供的一个或多个属性动画，根据 (double ratio) => Attr 动画

需要两个类，一个提供动画的各种属性，一个提供图形需要动画的属性的表

---

文件/类建立原则：无需g-base中的接口，g-base 中的abstract类尽量与g-canvas中的合并

Base -- 用 g-base 中的，抽象

Element -- 用 g-base 中的，抽象

Container -- 用 g-base 中的，抽象

CanvasController -- 同 g 中的 Canvas，结合 g-base 和 g-canvas，不抽象

Group -- 结合 g-base 和 g-canvas，不抽象

Shape -- 结合 g-base 和 g-canvas 放在 shape/base.dart 中，不抽象

ShapeBase -- 各种 Shape 构造器的 Map ，两者都放置在shape/shape.dart中

Canvas -- 实际的Widget，提供CustomPaint，Listener等，对应DOM，不抽象

从接口定义和使用情况看，Shape指的是基类，ShapeBase指的是构造器，不过g-canvas中的定义与其相反，我们采用前者，并我防止混淆放置在一个shape.dart文件中





另外还有 util, math, event, animate 文件夹, 每个文件夹可能还有自己的 util

附属的类定义尽量放在对应的类的文件夹中，公共的放在types.dart中

---

#EventEmitter

使得继承者成为一个EventEmitter，它是一个高度抽象的类，唯一的作用就是提供并操作 _events



GestureDetector 可回调的手势中

有以下几类没有参数：所有的cancel；点击、双击、长按的整体，也只有这三种有整体方法；onLongPressUp

detail 分成几类： tap、longPress，drag，scale，forcePress，都是没有父类的

定义时的冲突规则：vertical，horizontal，pan三者只能同时存在两个，不能三个同时存在，scale是pan的超集，不能和pan同时存在，可替代pan参与上一条规则

嵌套：目前不管 GestureDetector 如何嵌套，每个 GestureDetector 都会将事件发送到竞技场，最后只会有一个 GestureDetector 的一种事件胜出。

behavior 是控制测试区域的，有child时默认是deferToChild，没有child时默认是translucent。

`deferToChild`：子组件会一个接一个的进行命中测试，如果子组件中有测试通过的，则当前组件通过，这就意味着，如果指针事件作用于子组件上时，其父级组件也肯定可以收到该事件。

`opaque`：在命中测试时，将当前组件当成不透明处理(即使本身是透明的)，最终的效果相当于当前Widget的整个区域都是点击区域。

`translucent`：当点击组件透明区域时，可以对自身边界内及底部可视区域都进行命中测试，这意味着点击顶部组件透明区域时，顶部组件和底部组件都可以接收到事件。

secondaryTap指的是鼠标右键

onDoubleTap会吃掉点击的位置信息，onLongPress会影响拖动，因此只用tap和scale这两个模拟所有的手势事件

但是会被外面的detector影响到，看看可能要通过自定义GestureRecognizer处理 https://juejin.im/post/5b70eee8e51d456682516d36

如果用listener，不会被外面的手势捕获影响，保证会有事件，也不会影响外面的手势获取

不过先看看RawGestureDetector能不能更方便的解决 https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html    https://gist.github.com/Nash0x7E2/08acca529096d93f3df0f60f9c034056 

目前来看，可以通过重写 XXGestureRecognizer 的 rejectGesture 方法在其中调用 acceptGesture，使得本detector能捕获所有手势包括失败的手势，看看有没有什么办法使得自己成功获取的手势也能穿透给底下的detector，好像不能，要不还是用Listener

设计目标：脱离Arena，不影响canvas外层的detector，也不被其影响，canvas内部有竞技场，一个手势只会触发一个事件，竞争规则同竞技场

关于事件类型：GestureDetector 包裹 Widget ，其接受的事件类型本身就是“针对 Widget 对象”的，所以可以取同样的类型，“针对 Shape”也说得通。

事件注册统一采用枚举类型 EventType，EventCallback (EventDetails) => void

这样的设计逻辑上完全说得通，关键是实现。

EventDetails 实现所有Details类型，保留变量关系，但不要空值检验

# GraphEvent

目前来看，type指的是事件类型，name是代理对象名:事件类型，

~~g 中的传播 propagation 指的是DOM的传播，flutter不具备此功能，不管，使用者可在外面套prevent组件~~

g 中 GraphEvent 同时起到 detail 中的作用，先尝试这样搞一下，把detail作为graphEvent的一个成员，代替x，y等，传递给handler也是传detail

先尝试不要name

bubble好像是canvas内部的，还是要的

target系列感觉应该是element类型

timeStamp 改为 DateTime 类型的 time

propagationXX 好像也是要内部用的，propagationPath内部放的Element

element 的cfg有个字段name，用来标定此元素，应该是可以重名的，起到控制多个的作用。我们这里事件的代理也采用此机制，而不直接传元素，因为这样好像可以控制多个元素，而且更简洁高效。

目前来看，要标定一个事件，必须有name和type两个要素，这样就用一个Event来包装这两个类，并重写 == ，内部都用这个，对外也暴露Event，否则位置参数不太好放，因为对外暴露，所以用比较简短的名字，并且要添加一个静态成员通配符成员all，记号type在前（必需），name在后（非必需）。g中的通配符表示所有事件所有名称，所以也只有一个all

看来 g 和 G2 的确是想将整个GraphEvent交给handler，这样无论图表内部还是用户自定义时都可获取target等，

在g-base中，事件的传递分成 原生Event - GraphEvent两层，事件类型采用web标准，即两层之间并没有对事件类型进行封装，由于这是写在 g-base中的，即也将应用在移动端。

因此这样，事件模型完全采用和g一样的模型，方便后面逻辑编写，在 widget 中组装并触发这些事件

详细文档 https://www.yuque.com/antv/ou292n/pest1f 

由于flutter的机制，不考虑画布外元素与画布的交互



web的事件模型并不完全适用于flutter，建立一套新的以pointer为基础的，并与web的对应

由于Listener包含各种鼠标未按下的事件，故可处理（flutter也可能遇到有鼠标的情况），模拟底层故取名用click而不是tap

```
'mousedown',       pointerDown
'mouseup',         pointerUp
'dblclick',        doubleClick
'mouseout',        pointerOut
'mouseover',       pointerOver
'mousemove',       pointerMove
'mouseleave',      pointerLeave
'mouseenter',      pointerEnter
'touchstart',      touchStart
'touchmove',       touchMove
'touchend',        touchEnd
'dragenter',       dragEnter
'dragover',        dragOver
'dragleave',       dragLeave
'drop',            drop
'contextmenu',     secondaryClick
'mousewheel',      scale
```

同时将触发事件瞬间的那个Detail 传来作为originalEvent传来

现在关于鼠标进出悬浮等移到MouseRegion中了，但是它对手指操作无效，是用在desktop中的。只能用位置模拟。注意对于Listener，拖动手指移进去不会有任何触发，在里面开始移除去会继续。

先不要手指无法模拟出的事件

PointerEvent 中的timeStamp 是Duration类型，相对于过去的某个时间点，完全可以用来做事件时间比对





这样涉及到的类
EventType 事件的类型

OriginalEvent Listener发送的对象，包含EventType type 和 Object detail 两个字段，detail是PointerEnterEvent等其中之一

EventTag 由EventType type 和String name构成的引擎中事件唯一标识

GraphEvent 等同于g，引擎中完整的事件信息，回调函数的参数



antv 还有一个叫 g-gesture 的库，根据描述是供g使用的，目前是在G2Plot中使用的



#Base <- EventEvitter

getParent 必然返回Group，只有Group可以做parent



g 中存在两层继承体系

- cfg -- visible, capture, zIndex ； 没有特定的对象

- attrs -- 图形的 x, y, r 等，matrix, canvas的绘图属性 ；对象为ShapeAttrs 它将各图形所有可能的属性都列出

经过搜索发现，所有的get()和set()方法在使用时都是传入字面量的，故可将cfg, attrs做成比较静态的类，而无需非常动态的 Map

需要处理mix()

需要处理使用者的 element.attr()方法，这与动画中处理属性变动表好像是同一个问题？

在 addShape() 中传入的是cfg，但一般只设置其中的 attrs ，考虑是否应该将子类的cfg attrs做的限定一些方便代码提示？

给cfg和attrs类做一个Map<String, 访问器>形式的记录，访问器{getter, setter}，这个通过一个记录的基类来实现，基类提供一些诸如merge，get的方法，实际的配置重写记录

为确保设置属性的时候有提示，键考虑不用string用枚举？

这个问题可能可以通过 extension 或者 static 可以获得 this 的特性解决。

https://stackoverflow.com/questions/38908285/add-methods-or-values-to-enum-in-dart

cfg - attrs 设计的要点：

内部机制：shape 内部 cfg(attrs(paint)) ，构造函数中就用这个，并且 cfg 和 attrs 都有子类，方便代码提示

更新机制，供attr方法、动画更新使用，使用类似 rect.attr(RectAttrsRecord.width.set(16)) 好像太重了？采用这样：react.attr({RectAttrsKeys.width, 16}) ，即更新采用Map<ShapeAttrsKeys, Object> 为依据，放弃一点属性值的类型提示，

或者还有一个方式，就是还是传入一个ShapeAttrs实例，所有的ShapeAttrs实例有获知你构造函数中设置了哪些字段的能力，这个感觉好些，属性值的类型提示还是比较重要的，但是无法处理Paint的问题

或者还有一个办法，让attrs继承自Paint，这样最扁平？如果仅继承Paint，可能层级上不太对，比如Paint里面还有个Rect，要不用混入的形式搞成多重继承，Paint等有构造函数，不能直接混入，直接采用平铺的形式，设置参考 g 

对性能要求最重要的是动画，看看动画中推荐的是怎么做的

Paint 对象很特殊，它内部是通过buffer而不是实际的属性存储的，构造函数没有参数，通过访问器改动这些属性，可作为混入对象

最重要的一点：由于属性要提供出来动画，所以属性要固定，而不能直接输入一个 Rect 对象，所以位置属性参考 g。

这样确定一下 Attrs 的最终方案：Attrs混入Paint，在构造函数中记录一下哪些设置了（好像就是不是null）在attr() ，动画设置时类似React中的setSate。

attr循环调用 element 的 setAttr 方法， setAttr 方法会先比对是否变化，如果一样什么都不做，不一样触发触发onAttrChange方法

不如 attr 对外提供构造函数和访问器，提示类型，但内部用 Map存储，可以方便处理?

并不需要每次确切的知道那个attr变了，attr主要供 draw 方法使用，每次都是新的也没关系，只有animate的时候需要？

也许attrs只是一个存储，不要赋予它太多的东西

attrs 本质上只是一个Map，只不过为了用户提示将其封装了构造函数和访问器，这个Map存储了_paint 和 _attrs 然后重写一些方法，使其可以像Map那样使用

但是现在有不知道attr()方法中显式的设置了哪些值了，要不加个Set记录哪些key被设置过？

感觉这样不能发挥静态的类的优势，要不 attrs就是最呆的类，然后paint拓展一个应用attrs的方法，attrs里用是不是null判定有没有传入，再提供个mix方法

attrs虽然具有paint的所有接口，但内部存储机制不一样，不实现paint接口不作为paint使用； ~~给 paint 添加一个 extension ，paint.attr(shapeAttrs) ,比反过来好，因为一般参数是不变的~~

三个方案，extension paint 太麻烦，不直观；直接继承一个 ShapePaint，好处是顺序对，而且构造函数需求不重；不如直接用paint，给attrs添加一个方法 applyTo

extension 太麻烦了，而且不直观，直接扩展一个 ShapePaint 

mix 方法设计为单参数且不返回本体的，要级联时用级联运算符，感觉这样更dart一些

ShapeAttrs中除了Paint的属性外，还要包含 element -> shape 两者的defaultAttrs

以上方案没法mix到指定类型，不如还是用Map保存，attrs完全是个包装类，性能不一定差，不要过早优化，mix方法只需要拼接map，用个泛型指定返回类型，map不要暴露

由于mix可能改变类型，所以采用传入参数，新建返回的形式，返回的类型由泛型决定，参数传入数组便于扩展，作为ShapeAttrs的静态方法，这样好像也不行

这样，搞一个attrs的基类，完全抽象，仅重写[]运算符，添加mix方法，所有attrs接口仅作为外部使用的接口，提供构造函数和访问器的包装，内部都是使用attrs基类，用[]访问，这样mix方法也可以直接在第一个参数上处理了。这样的mix方法输入是没有问题的，要不输出反正返回基类，不用烦了，用户也不会要attrs的输出，子类的包装只是为了方便用户输入，这样要把

attr函数使用时只能传入attrs对象，且返回完成后的attrs对象，返回的时候注意包装一下

名称上好像不会与上层冲突，那个叫Attribute

g中的attrs只有ElementAttrs和ShapeAttrs两个互不相干，拓展一下ShapeAttrs使其具有子类，ElementAttrs是用于动画设置的，从目前代码来看就是ShapeAttrs

因此只搞一个Attrs类不再分子类，为方便mix且动态节省空间，内部存储用map，可拓展一些构造函数，

attrs中的bool类型字段由于可能为null，直接取了判断可能会有问题，可能需要在getter中处理一下，但这样也有可能其它问题，先想想





opacity 不要了，通过颜色的透明度进行设置，这是dart推荐的，也没有 globalAlpha 的接口。同时 G2中也废弃了透明度设置，推荐这样做

不用第三方的方式实现 dash，先不提供这个属性

g 中的 lineAppendWidth 是自己添加的用户拾取，这里为与strokeWidth 一致改名为 strokeAppendWidth

matrix 用vector_math_64 的 Matrix4，它是对 canvas.transform 接收的是4维矩阵对应的Float64List的包装，代表三维变形。flutter 虽然目前只有 2D，但这里是4维矩阵，可以扩展，是目前dart中比较标准常用的，g 中也将升级为4维矩阵。传入函数时用 matrix.storage 获取。它与webcanvas中的svgmatrix的对应关系是：

```
m11  m21  0  dx
m12  m22  0  dy
0    0    1  0
0    0    0  1
```



Cfg采用和Attrs类似的内部存储结构，出于类似attrs的mix的原因，也将所有类型集成到一个类中

原则上在g的基础上不再增加文件数量，相应的辅助类放到现有的相关文件中

注意所有类中的 getXX setXX 方法都尽量改用变量名访问器的形式，Base 类中不再有get() set()方法，因为Cfg暴露的是字段名是静态的，改为用 this.cfg.xx的形式。

mix还是单参数吧，对于绝大部分情况是单参数的能提升性能，多参数也可以级联

有一些cfg感觉不太适合放在构造函数中，比如parent，canvas，不过也不一定



# Element <- Base

cfg 在clone的时候不是所有的属性都要clone，有个列表CLONE_CFGS = ['zIndex', 'capture', 'visible', 'type']

attrs中先没有opacity属性，都是1

getGroupBase和 getGroupBase 获取的都是类，先尝试将所有类的都改造成构造方法，其中 Ctor<T> 表示有一个Cfg参数的工厂方法

ShapeBase是一个工厂方法的Map，这里就直接写Map了

parent感觉这里类型应该是Container而不是Group，接口中是Container

attr() 方法只有一种形态，传入新的 Attrs，进行mix，返回this（即element），至于只有一个键时是不是要省略遍历优化性能？先不考虑，感觉这是编译器需要做的。不过内部实际的setAttr要精细处理，因此Attrs对象要暴露[]运算符

afterAttrsChange 传入的是引起变化的 Attrs，即变化量

Attr的指导思想是：本质上就是Map，只不过给外部用户进行了类型包装，在其它类的代码中不可避免直接操作 String Object 键值对。Cfg内部机制类似，不过感觉先不需要暴露直接键值对操作。

BBox类型直接用dart:ui中的Rect

g 中的getClip()方法怪怪的，是不是处理 undefined ?

很多setXX方法有各种返回值，这个还是保留一下

toFront 和 toBack 方法里会获取个el但是没用，不知道干什么的

需不需要搞个AttrSingle()修改单个键值对，减少新建Attr和遍历的开销？先不要过度优化

Matrix4的乘法和g中三阶矩阵的乘法是否相同？

对于移动向量，参与矩阵运算（即g中以vec形式的）用Vector4，对用户暴露的用Offset，占前两位

注意通过element.shapeBase获取到的不一定就是代码中定义的静态shapeBase

在 clone 方法中，只针对 attr 为List和List<List>的情况做深拷贝处理，注意还有个Matrix4要处理

clone 方法的作用：1 复制一份attrs，2新建一个对象，3复制指定的cfg字段。为了返回值的类型限定，每个子类都重写下clone返回子类型，但是复制attrs和复制指定字段的

不如将attrs和cfg的clone移到attrs类和cfg类里，注意cfg只clone需要的字段，由于element是抽象类，所以这里做成抽象函数，由子类去实现。

所有形变方法的接口模仿Canvas类的对应方法

只保留moveTo不保留move

目前来看，新版g摒弃了使用action的transform方法，这个action的结构也很不dart，矩阵的变化函数参考 https://github.com/marcglasberg/matrix4_transform 

矩阵变换时注意尽量保证安全和性能，初始矩阵没有就用单位矩阵，但由于我们是位置参数，不做空值检验，而且不做0值检验，因为调用了这个函数时一般都是有值的，加个判断反而负优化了。

矩阵变换参考 https://www.zhangxinxu.com/wordpress/2012/06/css3-transform-matrix-矩阵/

translate：对应到dart中应该用 leftTranslate

```
1  0  0  t1
0  1  0  t2  *  m
0  0  1  0
0  0  0  1
```

rotateAtStart也调用rotateAtPoint方便统一

g中rotate移动时是先负后正，但是matrix4_transform中是先正后负，不知道有没有差别，先按g中的来



# Canvas <- Container

在 g 中 canvas 是一个完全抽象的对象，通过传入 dom 与实际的视图关联。

在本引擎中，这里既要提供 widget ，又要提供 g 中canvas的各接口，如果集中在同一个对象上，由于没有多重继承，实现比较麻烦，且强制用户使用函数返回组件的形式，比较呆板。



在 Flutter 中，经常有 Widget - Controller 配合使用的模式，Controller 一般继承自 Notifier ，controller可直接在state的成员定义时初始化（一般无构造参数）或用异步的方式，这个模式比较好

其中 Canvas为 Widget ，CanvasController 为抽象的类，等价 g 中的Canvas，注意只提供默认构造函数

同理 Chart 为 Widget，ChartController为抽象类

