GeomComponent的作用是一个纯工具，持有attr、adjust的配置，只有当这些配置改变时它会改变

它的作用是提供一个函数render，，当chart的配置发生改变时，chart调用此函数清除group上的rendershape，生成新的rendershape挂载上去

它只持有 `ChartComponent chart` `Group plot` , data, accessor, scale, 都是通过attr中的field到chart中去找对应的

一个Geom中到底是按照data长度（interval）还是固定个数（line）绘制renderShape的个数通过不同geom子类的方法实现

shape的本质是提供一个draw方法

Geom先不要有style属性，视觉样式完全由attr决定