# Graphic

<p align="left">
<a href="https://pub.dev/packages/graphic">
<img src="https://img.shields.io/pub/v/graphic.svg" />
</a>
</p>

Graphic is a grammar of data visualization and Flutter charting library.

- **A Grammar of Graphics**: Graphic derives from Leland Wilkinson's book *The Grammar of Graphics*, and tries to balance between theoretical beauty and practicability. It inherits most concepts, like the graphic algebra.
- **Declarative and Reactive**: As is encouraged in Flutter, the chart widget of Graphic is declarative and reactive. The grammar of data visualization is implemented by a declarative specification and the chart will reevaluate automatically on widget update.
- **Interactive**: With the *signal* and *selection* mechanism, the chart is highly interactive. It is easy to pop a tooltip or scale the coordinate.
- **Customizable**: With the *shape* and *figure* classes, it's easy to custom your own element, tooltip, annotation, etc.
- **Dataflow Graph and Operators**: Graphic has a internal structure of a dataflow graph and operators. That is how the reactive reevaluation and interaction is implemented.

## Documentation

See in the [documentation](https://pub.dev/documentation/graphic/latest/graphic/graphic-library.html).

## Examples

Example of charts can be seen in the [Example App](https://github.com/entronad/graphic/tree/main/example). Please clone this repository and run the example project in example directory.

<div align="center">
<img src="https://github.com/entronad/graphic/raw/main/devdoc/signal_channel.gif"/>
<img src="https://github.com/entronad/graphic/raw/main/devdoc/selection_channel.gif"/>
</div>

![examples](https://github.com/entronad/graphic/raw/main/devdoc/examples.jpg)

## Used by

Graphic is used by these companies:

[![rows](https://github.com/entronad/graphic/raw/main/devdoc/logo_rows.svg)](https://rows.com/)

## Tutorials

[The Versatility of the Grammar of Graphics](https://medium.com/@entronad/the-versatility-of-the-grammar-of-graphics-d1366760424d)

## Reference

Besides *The Grammar of Graphics*, the API terminology also referes to [AntV](https://antv.vision/en) and [Vega](https://vega.github.io/). The dataflow structure is inspired by [Vega](https://vega.github.io/).

## License

Graphic is [MIT License](https://github.com/entronad/graphic/blob/main/LICENSE).

## Keep Informed

[Twitter](https://twitter.com/entronad_viz)

[Medium](https://medium.com/@entronad)

[Zhihu](https://www.zhihu.com/people/entronad)
