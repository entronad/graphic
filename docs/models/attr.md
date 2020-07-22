## AttrComponent

作用是通过一组 `List<double> scaledValues` 求得一个 `A attrValue`, 其中scaledValues需与field（如 `'x*y'`）中一一对应。

AttrComponent 本身中是不需要使用到field的，但是为方便用户定义，在其props中加入此字段，作为一个有用的值