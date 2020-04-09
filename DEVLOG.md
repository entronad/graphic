包含两个模块

canvas -- A canvas shape library, also the rendering engine for Graphic.

chart -- A charting library with the Grammar of Graphics.

~~一个图形引擎，应该是一个完全抽象的对象，在构造时传入 Canvas 和 ValueNotifier<自己的手势事件类型> ,只管一次绘制，不管需不需要重绘，裸用的时候在 paint 方法中调用~~

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

~~addShape 方法以传入的 ShapeAttr 类型来决定画什么图，ShapeAttr（比如 EllipseAttr）命名参考 g 便于关联，参数参考canvas.draw，使其更 “dart化”~~

addShape 统一为只有cfg一个参数，通过cfg中的type、name、attrs指定属性

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

Shape -- 结合 g-base 和 g-canvas，抽象，各子类不抽象

ShapeBase -- 各种 Shape 构造器的 Map ，以上两者都放在 shape/shape.dart中，否则引用的时候记不得

Canvas 实际的Widget，提供CustomPaint，Listener等，对应DOM，不抽象

js中的context对应dart中的ui.Canvas

从接口定义和使用情况看，Shape指的是基类，ShapeBase指的是构造器，不过g-canvas中的定义与其相反，我们采用前者，并我防止混淆放置在一个shape.dart文件中





另外还有 util, math, event, animate 文件夹, 每个文件夹可能还有自己的 util

附属的类定义尽量放在对应的类的文件夹中，公共的放在types.dart中



特点：

attrs 和 cfg

事件与图形拾取

基于ticker的更底层的动画

(flutter目前没有且并不打算添加动画的 pause/resume https://github.com/flutter/flutter/issues/3299)

context

可记录路径节点的 Path 对象

transform Matrix的不同

配合path.contains的stroke拾取检验



---

在开发过程中，g 和 G2 也在不断的改进，每次注意实时更新，完成后测试前全部对比更新一下

---

如自定义的类名与内置冲突了，原则上给内置包加命名空间，包名_文件名，比如 flutter_animation，并且此命名空间是单独重新引用一下该包文件，dart:xx 类型的包直接叫 xx

---

antv中的each()根据dart的lint建议应该使用for in

原则上只有一个参数，没有泛型的函数不用typedef，参数也不命名

---

先暂定统一不要arrow

---

Text 和 Image 两种类型的 Shape 等到全部完成走通后再做



WITHOUT arrow、虚线、阴影

TODO 完成后记录并比对从init commit 到那之间 g 的commit 变化

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



# Timeline

感觉所有的时间都该用Duration

Tween 是线性插值

~~是否需要限制一下可以设置动画的attrs？最好单独弄个类AnimationAttrs，只可构造函数赋值，可与Attrs互动~~

不需要单独的AnimationAttrs，1onFrame的方法理论上应该可以让用户精细控制离散值，直接设置attrs的只需要定义好哪些突变哪些差值

d3-timer的作用是接受一个回调，传入流逝的时间，并可控制timer停止。感觉应该对应到 animation..addListener（值通过animation.value获取）即对应到Animation对象，

g中的Animation对象是个中间对象不对用户暴露，

g中的动画曲线是借助的 d3-ease ，对应flutter中是Curves类

将AnimateCfg的回调函数对象名都改为 onXXX

我感觉今后实际的动画结构是类似

```
animation = new Tween(begin: 0.0, end: 300.0).animate(CurvedAnimation(
  parent: controller,
  curve: Curves.bounceOut
))
  ..addListener(() {
    setState(() {});
  });
controller.forward();
```

timeline 中animation、controller、curve三者都需要，curve在animateCfg中，animation、controller替代g中timeline的timer

_update函数的作用是对fromAttrs 和toAttrs，根据ratio获取当前的插值值

update函数考虑了repeat 和onFrame

g中渐变色是没有插值的

由于element.attr方法是增量变换而不是替换，因此在update方法中传给attr()的toAttrs只需要包括变化的属性就可以了，我们这么做比较好，就是给Attrs对象整体搞一个lerp函数，按dart的惯例作为Attrs的静态方法，结果只包含 toAttrs中的属性，不可lerp或fromAttrs中不包含的属性以toAttrs为准，可否lerp按类型判断

当涉及到Duration或时间对象转换为数值时，尽量取到inMicroseconds

~~对外animate分成animateFrame 和 animateAttrs两个函数~~，但内部Animation对象两个字段都有，按优先onFrame的方式判断，这样animateCfg改名animationCfg避免歧义

将flutter_animation.Animation、controller等封装为timer对象，

完全不用flutter的上层动画对象，直接使用底层Ticker系列，将timer系列成员名改为ticker

因为只有 state 能提供TickerProvider，所以canvas必须是一个StatefulWidget，通过canvasController连接

为方便使用，将tickerProvider和el同级，作为canvas的cfg，通过animation中的canvasContro获取

animate方法参数都搞成命名参数，onFrame优先级高于toAttrs，cfg为必需

由于attrs中不会有repeat，timeline中_update函数中本身有属性相等的逻辑，且用户写大量重复属性的概率很小，因此感觉不用getFormatFromAttrs， getFormatToAttrs函数，只需要clone一下fromAttrs

把AnimateCfg的默认参数补上

g中stopAnimate中没有将_paused设为true，感觉是个bug，我们加上

感觉 Animation 的所有callBack都有判断，不需要设置noop的初始值

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

attrs 和 cfg 的setter中，当传入空值时都是移除对应属性，为实现这个功能，重写并调用 []= 运算符

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

不如将attrs和cfg的clone移到attrs类和cfg类里，注意cfg只clone需要的字段，由于element是抽象类，所以这里做成抽象函数，由非抽象子类（Group、CanvasController、Shape的子类）去实现。

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

cfg和attrs肯定是直接成员，故可直接访问，其它的原则上要赋值后调用，以防是实时访问器

需要添加一个作为子元素的属性index，作为排序时的默认索引

所有id用Widgets包的UniqeKey

initAttrs只有部分shape的子类要用到，其它是真的要个“空方法”，所以不做成抽象方法而是空方法

在 g-canvas 中 Element还有 draw 和 skipDraw 两个方法

# Shape <- Element

在g中完整的继承链是 BaseShape <- AbstractShape <- Element 最终的 BaseShape 是可实例化的

BaseShape AbstractShape两者重叠的方法calculateBBox()， isInShape()，使用BaseShape的

g 的cfg中叫canvasBox，感觉还是统一叫 canvasBBox好，和外部接口统一。

在web中，线还是面是通过fill和stroke两个属性是否为空判断的，可同时存在，但在dart中根据PaintingStyle枚举觉得，只能是其中一种，我们采用dart的模式。不过函数的接口还尽量保持假装可以同时存在的样子

flutter中shadow采用的material design的模式，不可直接作为图形属性，也不可计算bbox，故先不要

思考再三，觉得shape基类不应该可实例化，类型中不应该有base

所有的Ctor都不重新定义变量了，要用的地方直接写字面量

refreshElement为名字的函数出现在两个地方，一个是CanvasController的方法，一个是util/draw.ts中的函数，CanvasController的方法好像只要一个参数，util/draw.ts处的调用疑似错了。

js 中的 context 同时起到画布和存储样式的作用，因此建立一个新的类与之对应

antv定义了一套自己的渐变色字符串语法，并且g中有对应的解析器，dart中不需要，可通过自定义 Paint 中的 Shader 来设置

js中path，context要怎么去对应还需要再思考下

js中的save/restore 主要存储三样东西：变形，裁剪，样式属性；dart中canvas本身的save/restore主要存储变形，裁剪，需要模拟样式的栈。

在g中 save/restore 仅仅在clip、兼容模式ellipse等处使用，我们不采用。

感觉我们的绘图机制应该采用更dart的方式，

绘图系统传入的是canvas，描绘图形最重要的是 path matirx paint，但是每个状态可能是不一样的，

通过以下方式实现：

Shape 类有_path 和 _paint 两个成员，避免反复重建销毁，将g中的createPath 和applyAttrsToContext的作用改造为 get path 和 get paint 两个访问器，

_paint 的 getter都一样，写在Shape中，特别注意g中需要transform的地方，所有applyAttrsToContext分成transform和获取paint两步

而_path 在Shape中的getter方法都一样子类重写的是 createPath 方法，每次先reset，感觉比每次都新建性能好些

原则上每次使用 path 和 paint 的时候都要显式的赋一下值，防止重复计算和副作用

对绘制过程进行一个大简化，不要g中的drawPath，createPath（用path访问器代替），strokeAndFill方法，保留afterDrawPath，_afterDraw方法

bbox可直接通过 path.getBounds() 获取，将calculateBBox中的相关代码进行替换，移除bbox文件夹

常量Map的ShapeBase为与成员区别，首字母大写

arrow 的设置定义一个单独的类 ArrowCfg，放在util.arrow中，这个类自带一个默认样式的静态成员

在g中，shape有isFill和isStroke两种，可同时存在，因为web canvas是这个机制，但是dart中这两者互斥的，我们决定为了更dart味，所以也采取互斥的，相关字段和isInStrokeOrPath参数进行调整，字段叫paintingStyle

拾取检验采取的策略是简单的进行计算，复杂的用path.contain，目前用path.contain的是polygon

#Path <- Shape

g 中的 path 指的是通过svg path command 指令绘制出的图形，目前不想保留，直接用dart的path需要解决几个问题：

1线性插值

2起始点，终点，方便添加箭头符号

~~由于dart中Path存在add类的方法，因此不存在“路径节点”无法满足上面两点，可以创建一个Path类,继承自Path，重写并置空add类方法，添加路径节点的记录（通过重写to方法类进行记录）命名为 SequencePath 表明有序和节点~~

创建一次Path操作的对象PathCommand，分类还是按dart中的类型

offset还是即使计算吧，因为感觉用的少，只会在给起止点加箭头时用到

arcTo 终点太难算了，先不用了，估计后面还是要补上

offset可能是绝对的也可能是相对的，通过isRelative判别，

在g的util/path中，不是所有的方法都有用的，好多从来没被使用过，比较有用的是：

pathToAbsolute，将path command数组全部转换为绝对的，

pathToCurve，将所有path command数组转换为 M C C C...的形式

将g中attrs的path字段改名为pathCommands

g中path插值的顺序：都是以toPath为基准，首先将fromPath转换到和toPath一样长，然后每一项归化到一样的类型，然后进行线性插值，这些操作仅适用于绝对定位操作，相对定位操作回滚为和toPath一样

转换长度的原理是利用 levenshteinDistance 最小进行操作，归化操作原理是用控制点进行操作

基于以上深入的调研之后，我们发现，我们实际使用中有意义的是绝对命令，只有绝对命令需要points，不用操心起始点，close不需要points

pathToAbsolute， fillPathByDiff， formatPath，

formatPath只允许from大于等于to，此时from的后段会保留，为timeline中animation.pathFormatted有关的逻辑准备

在动画中主要关心端点，所以为方便先这样，fillPathByDiff中判断相等用最后一个点相等

fillPathByDiff方法中source.splice(index, 0, [].concat(source[index]));注意js中concat方法传入非数组是直接装进去，传入数组是取其中的元素装进去（很坑）

注意g中_getSegmentPoints获得的点是逆序排列的，我们还是顺序排列比较好

g中的_splitPoints感觉不太合理，按照自己的办法重写一下，g中采用的是在横轴上长度均分，我们采用序列均分

g中的segment的计算过于复杂，好像主要用来计算路径长度、夹角等，看能不能通过PathMetric系列进行计算。将所有涉及 segment 的内容先移除

getSegments()函数仅在shape/path中存在，当计算起点终点夹角、计算是否在stroke上时使用。

注意 moveTo 命令会生成一个新的 sub path ，close 命令只会封闭当前的 sub path 而不是针对整个 pathCommands，所以使用者需要自己保证 close 



dart 中的贝塞尔曲线：

QuadraticBezierTo 二阶

CubicTo 三阶

ConicTo 二阶带权重

对于stroke拾取问题，和长度问题，好像必须用计算法了，带权重的算不了，先删去，仅做二阶三阶。

math/bezier, quadratic, cubic 中的方法哪怕接口奇怪也先尽量按它的来。

由于不涉及箭头，先不要加pi、tangent等内容



shape需要的功能，以及shape/path的实现：

createPath 创建 ui.Path：直接顺序添加 pathCommand

isInStroke：顺序计算距离

isInFill：直接用path.contain

totalLength：顺序相加length

getPoint：顺序在tCache上查找

应该将所有pathCommand所需要的不同类型的操作都作为子类的方法，而不用switch判断。

因此需要给每个AbsolutePathCommand添加

inStroke，getLength，getPoint，均需传入 prePoint，formatPath涉及到是否起始点，而且也不是严格意义上的一一对应，不应该做成员方法

对于圆弧

inStroke 近似算法

getLength 用PathMetric计算

getPoint 用PathMetric计算

从g中的 pathToCurve方法看，对于moveTo，是不把其作为curve，不计算其长度的，但每次都会记录其移动的点，作为close的终点，这一点我们在处理函数中也需要记录并处理，因此还要记得把close自带的都返回null，在外面特殊处理（作为LineTo或特殊返回）

圆弧拾取感觉可以用近似的同心圆法。

在起始点处做近似，移动只要垂直于起始点的连线，半径分别加减一半线宽，其它不变

计算公式：dx = (r/r0) * dy0, dy = (r/r0) * dx0，符号规则，当dy0 与dx0同号时，dy与dx异号，

bezier曲线的拾取判断先只看距离不管bbox



在 shape/path中保存的pathCommands保证是绝对的，通过在\_setPathArr转换，由于在initAttrs和 setAttr中都调用了\_setPathArr，所以可以确保shape/path中能接触到的pathCommands都是绝对的。~~因此，为方便使用，shape/path 添加一个访问器pathCommand进行类型转换。~~ 还是不要了，很多时候出现 final xx = this.cfg或attrs.xx 是为了固定变量使其在下面的逻辑中不再改变，

以上方法也同样用在replaceClose上，即确保没有close。



path的isPointInStroke也先不管 bbox

g中对待长度技术的策略是全部转换为cubic，称为curve，有相关的字段、缓存和方法，我们先都不要

~~感觉g算tCache的方法（包括polyline）不科学，算了两遍~~ g中的polyline的_方法中调用 getLength 由于有缓存，不会算两遍，而且还能顺带检查更新下缓存，而且在shape/path中， _setTcache 本身就是同时计算并更新 length 和tCache的作用。那我还是觉得不要算两次

设置一个函数，替换pathCommands中的close为lineTo，使逻辑简化

关于path的subpath规则：第一个subpath的初始点是0,0；moveTo 会开启一个新subpath，起始点就是moveTo的点，close也会开始一个新的subpath，起始点置0；

# Marker <- Shape

attrs中的symbol属性先不支持自定义，改名为symbolType

如果不需要箭头的话，感觉也不需要 util/draw 中的 drawPath 方法了

g中的paramsCache目前主要用在drawPath中缓存圆弧参数，我们目前不要用到，移除相关定义

# Line <- Shape

路径类型的shape（line/path/polyline）有totalLength getPoint()两个方法

# Rect <- Shape

当 rect为strike时，采取两个矩形相减的拾取策略

为方便 Rect 统一采用 RRect 处理

# Polyline <- Shape

tCache 指每一个节点的ratio 每段 curve 对应起止点的长度比例列表，形如: [[0, 0.25], [0.25, 0.6]. [0.6, 0.9], [0.9, 1]]

# Container <- Element

getFirst, getLast, getChildByIndex, getCount, contain 虽然可以直接可以从children获取，但考虑到container的性质，还是提供一下包装类

为防止命名重复，此文件开头的函数都加个 _

# Group <- Container

g-base 与 g-canvas 无重合

shape和group中的_applyClip重复了，而且好像不一定作为成员，放到util/draw中

group 的draw 方法中，归根到底是要画的是shape，shape一定会有path和paint，故group中除drawChildren外只要应用个matrix

# Canvas <- Container

在 g 中 canvas 是一个完全抽象的对象，通过传入 dom 与实际的视图关联。

在本引擎中，这里既要提供 widget ，又要提供 g 中canvas的各接口，如果集中在同一个对象上，由于没有多重继承，实现比较麻烦，且强制用户使用函数返回组件的形式，比较呆板。



在 Flutter 中，经常有 Widget - Controller 配合使用的模式，Controller 一般继承自 Notifier ，controller可直接在state的成员定义时初始化（一般无构造参数）或用异步的方式，这个模式比较好

其中 Canvas为 Widget ，CanvasController 为抽象的类，等价 g 中的Canvas，注意只提供默认构造函数

同理 Chart 为 Widget，ChartController为抽象类

