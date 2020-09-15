

### Chart<D>

---

**width | widthPercent**

type: num | num

default(widthPercent): 100

**height | heightPercent**

type: num | num

default: Infinity

**padding | paddingPercent**

type: [EdgeInsets](https://docs.flutter.io/flutter/painting/EdgeInsets-class.html) | [EdgeInsets](https://docs.flutter.io/flutter/painting/EdgeInsets-class.html) 

default(padding): null(auto)

**data**

type: List<D>

**scales**

type: List<Scale>

**coord**

type: Coord

default: RectCoord()

**axes**

type: List<Axis>

**geoms**

type: List<Geoms>

**legend**

type: Legend

**tooltip**

type: Tooltip

default: null (not show)

**guides**

type: List<Guide>



### Scale

---

**field | fieldList**

type: String | List<String>

**formatter**

type: Object => String

**range**

type: ScaleRange

**alias**

type: String

**ticks | tickCount**

type: List<String> | int



### LinearScale : Scale

---

**nice**

type: bool

**min**

type: num

**max**

type: num

**tickInterval**

type: num (contract with tickCount)



### CatScale : Scale

---

**values**

type: List<Object>

**isRounding**

type: bool

default: false



### TimeCatScale : CatScale : LinearScale

---

**mask**

type: String

default: 'yyyy-MM-dd' (contract with formatter)

The date format is based on [intl](<https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html>) , so they have the same patten string rules:

```dart
Symbol   Meaning                Presentation       Example
------   -------                ------------       -------
G        era designator         (Text)             AD
y        year                   (Number)           1996
M        month in year          (Text & Number)    July & 07
L        standalone month       (Text & Number)    July & 07
d        day in month           (Number)           10
c        standalone day         (Number)           10
h        hour in am/pm (1~12)   (Number)           12
H        hour in day (0~23)     (Number)           0
m        minute in hour         (Number)           30
s        second in minute       (Number)           55
S        fractional second      (Number)           978
E        day of week            (Text)             Tuesday
D        day in year            (Number)           189
a        am/pm marker           (Text)             PM
k        hour in day (1~24)     (Number)           24
K        hour in am/pm (0~11)   (Number)           0
z        time zone              (Text)             Pacific Standard Time
Z        time zone (RFC 822)    (Number)           -0800
v        time zone (generic)    (Text)             Pacific Time
Q        quarter                (Text)             Q3
'        escape for text        (Delimiter)        'Date='
''       single quote           (Literal)          'o''clock'
```

```dart
Format Pattern                    Result
--------------                    -------
"yyyy.MM.dd G 'at' HH:mm:ss vvvv" 1996.07.10 AD at 15:08:56 Pacific Time
"EEE, MMM d, ''yy"                Wed, Jul 10, '96
"h:mm a"                          12:08 PM
"hh 'o''clock' a, zzzz"           12 o'clock PM, Pacific Daylight Time
"K:mm a, vvv"                     0:00 PM, PT
"yyyyy.MMMMM.dd GGG hh:mm aaa"    01996.July.10 AD 12:08 PM
```





### Coord

---



### RectCoord : Coord

---

**transposed**

type: bool

default: false



### PolarCoord : Coord

---

**radius**

type: num

default: 1

**innerRadius**

type: num

default: 0

**startAngle**

type: num

default: 0

**endAngle**

type: num

default: 0



### Axis

---

**field | fieldList**

type: String | List<String>

**show**

type: bool

default: true

**position**

type: AxisPosition

default: AxisPosition.bottom for x, AxisPosition.left for y

**line**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 

**labelOffset**

type: num

**grid | gridFunc**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) | GridFunc

**tickLine | tickLineFunc**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) | GridFunc

**label | labelFunc**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) | TextFunc

**top**

type: bool





### Geom

---

**generatePoints**

type: bool

default: false for line, path, true for others

**sortable**

type: bool

default: true for area, line, false for others(if data has been sorted, false will inhence peformance)

**startOnZero**

type: bool

default: true

**position**

type: Position

**color**

type: ColorMap

**shape**

type: ShapeMap

**size**

type: SizeMap

**adjust**

TODO

**style | styleFunc**

type:  [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) | (datum) => [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 



### Point : Geom

---



### Path : Geom

---



### Line : Geom

---



### Area : Geom

---



### Interval : Geom

----



### Polygon : Geom

---



### Schema : Geom

---



### Guide

---

**top**

type: bool

default: true



### ShapeGuide : Guide

---

**start | startFunc**

type: GuideAnchor | (xScale, yScales) => GuideAnchor

**end | endFunc**

type: GuideAnchor | (xScale, yScales) => GuideAnchor

**style**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 



### LineGuide : ShapeGuide

---



### RectGuide : ShapeGuide

---



### ArcGuide : ShapeGuide

---



### TextGuide : Guide

---

**position | positionFunc**

type: GuideAnchor | (xScale, yScales) => GuideAnchor

**content**

type: String

**style**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**offset**

type: [Offset](https://docs.flutter.io/flutter/dart-ui/Offset-class.html) 

default: Offset(0, 0)



### TagGuide : TextGuide

---

**direct**

type: TagGuideDirect

default: null

**size**

type: num

default: 4

**background**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 

**withPoint**

type: bool

**pointStyle**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 



### Legend

---

**field | fieldList**

type: String | List<String>

**show**

type: bool

default: true(if dataKey is set, false apply to it, else false apply to all)

**position**

type: LegendPosition

default: LegendPosition.top

**align**

type: AlignMode

default: AlignMode.start(for top/bottom position), AlignMode.center(for left/right position)

**itemWidth**

type: num

default: null(auto)

**showTitle**

type: bool

default: false

**titleStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**offset**

type: [Offset](https://docs.flutter.io/flutter/dart-ui/Offset-class.html) 

default: Offset(0, 0)

**titleGap**

type: num

default: 12

**itemGap**

type: num

default: 12

**itemMarginBottom**

type: num

default: 12

**wordSpace**

type: num

default: 6(marker 与 word之间)

**unCheckColor**

type:  [Color](https://docs.flutter.io/flutter/dart-ui/Color-class.html) 

**itemFormatter**

type: String => String

**marker**

type: Shape TODO

**nameStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**valueStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**joinString**

type: String

**triggerOn**

TODO

**selectedMode**

type: SelectedMode

**clickable**

type: bool

default: true

**onClick**

type: ev => void

**custom**

type: bool

default: false

**items**

type: List<LegendItem> (when custom is true)



### ToolTip

---

**alwaysShow**

type: bool

default: false

**offset**

type: [Offset](https://docs.flutter.io/flutter/dart-ui/Offset-class.html) 

default: Offset(0, 0)

**triggerOn**

type: TouchEvent TODO

**triggerOff**

type: TouchEvent TODO

**showTitle**

type: bool

default: false

**showCrosshairs**

type: bool

**crosshairsStyle**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 

**showTooltipMarker**

type: bool

**background**

type: [Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) 

**titleStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**nameStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**valueStyle**

type: [TextStyle](https://docs.flutter.io/flutter/dart-ui/TextStyle-class.html) 

**showItemMarker**

type: bool

**itemMarkerStyle**

type: Shape

**custom**

type: bool

**onShow**

type: (x,y,title,items,chart) => void

**onHide**

type: (x,y,title,items,chart) => void

**onChange**

type: (x,y,title,items,chart) => void

**crosshairsType**

**showXTip**

type: bool

**showYTip**

type: bool

**xTip | xTipFunc**

**yTip | yTipFunc**

**xTipBackground**

**yTipBackground**

**snap**

type: bool

### ScaleRange

---

**min**

type: num

default: 0.0

**max**

type: num

default: 1.0



### Attr

---

**field | fieldList**

type: String | List<String>

**valueList | value | callback**

type: List<V> | V | (datum) => V



### PositionAttr : Attr

---



### ColorAttr : Attr

---

**colorList | color | colorFunc | gradient**

type: List\<[Color](https://docs.flutter.io/flutter/dart-ui/Color-class.html)\> | [Color](https://docs.flutter.io/flutter/dart-ui/Color-class.html) | (value) => [Color](https://docs.flutter.io/flutter/dart-ui/Color-class.html) | [Gradient](https://docs.flutter.io/flutter/painting/Gradient-class.html) 



### ShapeAttr : Attr

---

**shapeList | shape | ShapeFunc**

type: List<Shape> | Shape | (value) => Shape



### SizeAttr : Attr

---



**size | sizeFunc**

type: num | (value) => num

default: null, if not null, max and min are invalid



**range**

type: Range



### GuideAnchor

---

**x | xPercent | xMeasure**

type: F | num | statsMeasure



### Type Enums

---

**AxisPosition**

top

right

bottom

left



**LegendPosition**

top

right

bottom

left



**TagGuideDirect**

topLeft

top

topRight

right

bottomRight

bottom

bottomLeft

left





**AlignMode**

start

center

end



**StatsMeasure**

max

min

median



### Functions

---

**GridFunc**

[Paint](https://docs.flutter.io/flutter/dart-ui/Paint-class.html) Function(String text, int index, int count)