# Graphic

<p align="left">
<a href="https://pub.dev/packages/graphic">
<img src="https://img.shields.io/pub/v/graphic.svg" />
</a>
</p>
Graphic is a grammar of data visualization and Flutter charting library.

- **Flexible declarative grammar**: This visualization grammar derives from Leland Wilkinson's *The Grammar of Graphics*, and tries to balance between theoretical beauty and practicability. Data processing steps and mark shapes can be composed freely in a declarative specification, not limited to certain chart types. And shape draw methods are customizable.
- **Interaction**: With the *event* and *selection* definition, the chart is highly interactive, such as highlighting selected items, popping a tooltip, or scaling the coordinate.
- **Animation**: Mark transition animation can be set when a chart is built or changed. The entrance animation has various forms.

## Documentation

See in the [documentation](https://pub.dev/documentation/graphic/latest/graphic/graphic-library.html).

## Migration Guide to 2.0

Some of the terminalogy has been changed in v2.0. Please follow the below guide to migrate your code.

| old code      | new code |
| ----------- | ----------- |
| GeomElement      | Mark       |
| Attr   | Encode        |
| Signal   | Event        |
| Channel   | Stream        |
| Figure   | MarkElement        |
| element:   | marks:        |
| ColorAttr   | ColorEncode        |
| ShapeAttr   | ShapeEncode        |
| element:   | marks:        |
| IntervalElement | IntervalMark |
| PointElement | PointMark |
| LabelAttr | LabelEncode |
| color | fillColor |
| strokeStyle | PaintStyle |






## Examples

Example of charts can be seen in the [Example App](https://github.com/entronad/graphic/tree/main/example). Please clone this repository and run the example project in example directory.

<div align="center">
<img src="https://github.com/entronad/graphic/raw/main/devdoc/animation1.gif" width="40%" height="40%" />
<img src="https://github.com/entronad/graphic/raw/main/devdoc/animation2.gif" width="40%" height="40%" />
<img src="https://github.com/entronad/graphic/raw/main/devdoc/animation3.gif" width="40%" height="40%" />
<img src="https://github.com/entronad/graphic/raw/main/devdoc/animation4.gif" width="40%" height="40%" />
<img src="https://github.com/entronad/graphic/raw/main/devdoc/signal_channel.gif" width="40%" height="40%" />
<img src="https://github.com/entronad/graphic/raw/main/devdoc/selection_channel.gif" width="40%" height="40%" />
</div>

![examples](https://github.com/entronad/graphic/raw/main/devdoc/examples.jpg)

## Tutorials

[The Versatility of the Grammar of Graphics](https://medium.com/@entronad/the-versatility-of-the-grammar-of-graphics-d1366760424d)

[How to Build Interactive Charts in Flutter](https://medium.com/@entronad/how-to-build-interactive-charts-in-flutter-e317492d5ba1)

## Share this Lib

[![Twitter](https://img.shields.io/badge/share%20on-twitter-03A9F4?style=flat-square&logo=twitter)](https://twitter.com/share?url=https://github.com/entronad/graphic&text=Graphic:%20A%20grammar%20of%20data%20visualization%20and%20Flutter%20charting%20library.)
[![HackerNews](https://img.shields.io/badge/share%20on-hacker%20news-orange?style=flat-square&logo=ycombinator)](https://news.ycombinator.com/submitlink?u=https://github.com/entronad/graphic)
[![Reddit](https://img.shields.io/badge/share%20on-reddit-red?style=flat-square&logo=reddit)](https://reddit.com/submit?url=https://github.com/Kanaries/pygwalker&title=Graphic:%20A%20grammar%20of%20data%20visualization%20and%20Flutter%20charting%20library.)

## License

Graphic is [MIT License](https://github.com/entronad/graphic/blob/main/LICENSE).

## Keep Informed

[Twitter](https://twitter.com/entronad_viz)

[Medium](https://medium.com/@entronad)

[Zhihu](https://www.zhihu.com/people/entronad)

Thanks for reading.
