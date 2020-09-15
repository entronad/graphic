## NodeState with TypedMap

*props, abstract*

*state, abstract*

**entries**

`Path clip`

裁剪

`Matrix4 matrix`

变形

`int zIndex`

高度，注意由于它对本身的渲染没有影响，因此它可直接修改不触发任何 setter/onSet

`bool visible`

是否可见

`Group parent`

父元素



## Node<S extends NodeState> extends Component<S>

*component, abstract*

**notes**

**constructor**

将props中的attrs设为defaultAttrs混入cfg.attrs

**methods**

`A get bbox`

所有节点都有bbox，Group和RenderShape实现不同

`void paint(Canvas canvas)`

供Painter调用，分_setCanvas, draw, _restoreCanvas 三步，

`void _setCanvas(Canvas canvas)`

应用变形和剪切

`void draw(Canvas canvas)`

绘制的实现，由于Group的draw中调用的是子元素的paint，保证了所有的canvas设置都会被调用

`void _restoreCanvas(Canvas canvas)`

恢复canvas

`void remove()`

移除子元素

`void transform(Matrix matrix)`

将形变应用到matrix上

`void onTransform()`

发生形变时执行的 onSet

`void translate({double x = 0, double y = 0})`

位移

`void scale({double x = 1, double y = 1, Offset origin})`

缩放，原点默认坐标原点

`void rotate(double angleRadians, {Offset origin})`

旋转，原点默认坐标原点

---

## RenderShapeState extends NodeState

*state, abstract*

**entries**

Paint 的各种属性，TextRenderShape具有Text的各种属性



## RenderShape<S extends RenderShapeState> extends Node<S>

**deriveds**

`final Path _path`

复用避免反复重建

`final Paint _stylePaint`

复用避免反复重建

`Rect shapeBBox`

缓存bbox计算值的关联变量，bbox getter直接获取它

**constructor**

父类构造函数中的混入完成后，要执行以下 assign()方法第一次计算关联值

**methods**

`static RenderShape create(Props props)`

根据传入的props创建RenderShape

`void assign()`

赋值所有关联变量，所有计算所有关联变量并在构造函数中调用的方法都叫这个，它与 onSet 分开来

`void draw(Canvas canvas)`

canvas.drawPath

`void setProps(Props<RenderShapeType> props)`

设置属性更新

`void onSetProps()`

设置属性时的更新，调用assgin更新全部

`void onTransform()`

形变影响且只影响shapeBBox，它要重新算下

`Rect calculateBBox()`

计算bbox，目前先用 path.getBounds 统一实现。bbox包含形变（path不包含形变）

`void createPath(Path path)`

创建path的方法，会传入重置好的 _path ，由各子类实现

---

## GroupState extends NodeState

**entries**

`List<Node> children`

## Group extends Node

**methods**

`RenderShape addShape(Props<RenderShapeType> props)`

新建并添加一个图形，根据attrs的实际类型决定添加何种图形

`Group addGroup()`

新建并添加分组

`void _add(Node element)`

将元素挂载到渲染树上，f2中还要移除this同级的element，不知道为什么，先不弄，也先不设置renderer

初始化时的空children已经确保了children不为空

属于 setter

`void _onAdd()`

需要重排下

`void _sort()`

根据元素的 zIndex 进行排序，要用个辅助的 siblingOrders 确保zIndex一样时的稳定

`void clear()`

清空child

`void draw(Canvas canvas)`

调用每个child的paint方法，保证了canvas设置和visible检查

`Rect get bbox`

由于子节点变化时自己不会知道，所以每次都要重算

---

## Renderer extends Group







