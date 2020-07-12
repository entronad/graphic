## ElementProps<A extends ElementAttrs> with TypedMap

*props, abstract*

**notes**

**entries**

`A attrs`

渲染属性，由于group也需要clip、matrix等，因此attrs放在基类中

`int zIndex`

层叠层级

`bool visibale`

是否可见

`Group parent`

渲染树中的父节点

`siblingIndex int`

在渲染树中兄弟节点序号，辅助排序用

## ElementAttrs with TypedMap

*abstract*

**notes**

- 包含引擎绘图时的全部信息，包括尺寸、Paint和Text相关的
- 成员设置尽量扁平
- 虽然与gg中的Attr冲突，但为与其它常用引擎保持一致，仍使用Attrs、attr()的术语，此类仅在引擎中使用，gg中相关联的对象优先使用内置对象，或以Style命名

**entries**

`Path clip`

裁剪

`Matrix4 matrix`

变形

## Element<P extends ElementProps, A extends ElementAttrs> extends Component<ElementProps, TypedMap>

*abstract, component*

**notes**

**constructor**

将props中的attrs设为defaultAttrs混入cfg.attrs

**methods**

`A get attrs`

直接获取attrs的访问器

`set attrs(A attrs)`

获取初始化的attrs

`void attr(A attrs)`

更改attr的属性，并触发相关操作，仅可通过此方法对attrs进行操作

`void onAttrsSet()`

所有在attrs设置了之后要执行的操作放在这里，构造方法、attr()、变形方法中会执行一次，注意addShape/addGroup不会执行，group的属性获取还是需要即时计算

`Rect get bbox`

获取包围盒，无论是shape还是group，我们需要的包围盒是变形之后的，所以在计算包围盒时就需要加上变形，为求精确，我们全部用变形法。

`void paint(Canvas canvas)`

判断是否visible，如是的则调用setCanvas，draw，restoreCanvas方法

`void _setCanvas(Canvas canvas)`

save，然后执行clip和transform操作

`void draw(Canvas canvas)`

实际的canvas绘图操作，对于Container和RenderShape不同

`void _restore(Canvas canvas)`

canvas.restore()

`void remove()`

将自身从渲染树上移除

`void transform(Matrix4 matrix)`

在当前形变基础上再进行matrix代表的形变

`void translate(double x, double y)`

平移

`void rotate(double rad)`

旋转

`void scale(double x, double y)`

拉伸

`void _applyTransform(Canvas canvas)`

---

## RenderShapeProps<A extends RenderShapeAttrs> extends ElementProps<RenderShapeAttrs>

*props, abstract*

**entries**

`Rect bbox`

## RenderShapeAttrs extends ElementAttrs

*abstract*

**note**

标志位置的字段放到子类中，addShape通过类型确定，Text中注意对applyToPaint抛错误

**entries**

paint 相关的，默认值与paint相同

text除外，text中同位参数的优先级是textSpan高于text和textStyle

**method**

`RenderShapeType get type`

获取RenderShape的类型，由子类写死实现

`void applyToPaint(Paint paint)`

应用到Paint上

## RenderShape<P extends ElementProps, A extends ElementAttrs> extends Element

`final Path _path`

复用避免反复重建

`final Paint _stylePaint`

复用避免反复重建

**methods**

`Path get path`

重置、create、返回 _path

`Paint get stylePaint`

将attrs应用到 _paintStyle 并返回

`void draw(Canvas canvas)`

canvas.drawPath

`Rect get bbox`

看看当前有没有bbox，没有就创建，然后返回

`Rect calculateBBox()`

计算bbox，目前先用 path.getBounds 统一实现。开头调用path访问器确保先计算一遍path

`void createPath(Path path)`

创建path的方法，会传入重置好的 _path ，由各子类实现

---

## GroupProps extends ElementProps<ElementAttrs>

**entries**

`List<Element> children`

## Group extends Element

**methods**

`RenderShape addShape(RenderShapeAttrs attrs)`

新建并添加一个图形，根据attrs的实际类型决定添加何种图形

`Group addGroup()`

新建并添加分组

`void _add(Element element)`

将元素挂载到渲染树上，f2中还要移除this同级的element，不知道为什么，先不弄，也先不设置renderer

初始化时的空children已经确保了children不为空

添加完了需sort，这样感觉sort应该是内部函数

`void _sort()`

根据元素的 zIndex 和 siblingIndex 进行排序

`void clear()`

清空child

---

## Renderer extends Group







