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

Base -- 用 g-base 中的

Element -- 用 g-base 中的

Container -- 用 g-base 中的

Canvas -- 同 g 中的 Canvas，结合 g-base 和 g-canvas

Group -- 结合 g-base 和 g-canvas

Shape -- 结合 g-base 和 g-canvas 放在 shape/shape.dart 中



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

注意所有类中的 getXX setXX 方法都尽量改用变量名访问器的形式，Base 类中不再有get() set()方法，因为Cfg暴露的是静态的。



# Canvas <- Container

在 g 中 canvas 是一个完全抽象的对象，通过传入 dom 与实际的视图关联。

在本引擎中，这里既要提供 widget ，又要提供 g 中canvas的各接口，如果集中在同一个对象上，由于没有多重继承，实现比较麻烦，且强制用户使用函数返回组件的形式，比较呆板。



在 Flutter 中，经常有 Widget - Controller 配合使用的模式，Controller 一般继承自 Notifier ，controller可直接在state的成员定义时初始化（一般无构造参数）或用异步的方式，这个模式比较好

其中 Canvas为 Widget ，CanvasController 为抽象的类，等价 g 中的Canvas，注意只提供默认构造函数

同理 Chart 为 Widget，ChartController为抽象类