## 2.2.1

**2023-09-26**

- Operator value use deep equality: https://github.com/entronad/graphic/pull/262


## 2.2.0

**2023-05-15**

- Add `RepaintBoundary` to reduce chart repainting: https://github.com/entronad/graphic/pull/220
- Fix that all items use the same shape params: https://github.com/entronad/graphic/issues/221

## 2.1.0

**2023-04-20**

- Add `Gesture.chartKey`: https://github.com/entronad/graphic/pull/217
- Add `localMoveStart` for both update and end events in scale and long presses.

## 2.0.3

**2023-04-12**

- Fix the Modifier error when updating: https://github.com/entronad/graphic/issues/206
- Rename enum property `MarkEntrance.alpha` to `MarkEntrance.opacity`.
- Fix polygon shape when there is only one datum or one value in a dim: https://github.com/entronad/graphic/issues/166

## 2.0.2

**2023-04-06**

- Change name the following names to avoid conflict with dart/flutter built-in libraries (https://github.com/entronad/graphic/issues/193, https://github.com/entronad/graphic/pull/200):

  `View -> ChartView`

  `Scene -> MarkScene`

## 2.0.1

**2023-04-04**

- Fix LineShape dash: https://github.com/entronad/graphic/issues/212

## 2.0.0

**2023-04-02**

- Add feature of transition animation, see details in `Mark.transition`. And thus the rendering engine is rewrited. The imperative `Figure` classes are changed to declarative `MarkElement` classes. See details in this folder: https://github.com/entronad/graphic/tree/main/lib/src/graffiti/element

- Update terminology to keep same with modern mainstream data visualization libraries. Some class names have changed:

  `GeomElement -> Mark`

  `Attr -> Encode`

  `Signal -> Event`

  `Channel -> Stream`

  `Figure -> MarkElement`

  And thus some properties related are also changed, like `elements -> marks`.

- Fix diposing functions.

## 1.0.1

**2022-12-18**

- Add mouse-focus scaling signal: https://github.com/entronad/graphic/pull/173

## 1.0.0

**2022-11-01**

- Graphic has finished initial development and ready for production from this version. The API will be stable while a new major version begins in the design.
- Add size to tooltip renderer function: https://github.com/entronad/graphic/pull/159

## 0.10.7

**2022-09-20**

- Fix memory leak of channels: https://github.com/entronad/graphic/issues/143

## 0.10.6

**2022-07-22**

- Fill region annotations with a gradient: https://github.com/entronad/graphic/pull/132

## 0.10.5

**2022-06-07**

- Fix the bug that `GeomElement.selected` dosen't work.
- Fix: handle big numbers when calculating nice range/numbers: https://github.com/entronad/graphic/pull/107

## 0.10.4

**2022-05-20**

- Remove `_mouseIsConnected` checking from chart widget state.
- Expose linearNiceRange and linearNiceNumbers algorithms: https://github.com/entronad/graphic/pull/105

## 0.10.3

**2022-05-02**

- Fix Stack Overflow when comparing modifiers: https://github.com/entronad/graphic/pull/96

## 0.10.2

**2022-05-02**

- Add `coordConv` to `Modifier.modify`'s arguments.

## 0.10.1

**2022-04-28**

- Add `clip` for `FigureAnnotation`s: https://github.com/entronad/graphic/issues/93
- Export modifier argument classes.

## 0.10.0

**2022-04-28**

- Add tuple indexes in tooltip renderer: https://github.com/entronad/graphic/pull/80
- Make modifier customizable: https://github.com/entronad/graphic/pull/88
- Remove `CustomShape`. Custom shapes directly extend `Shape`.

## 0.9.4

**2022-04-20**

- Fix dodge modifier: https://github.com/entronad/graphic/pull/86

## 0.9.3

**2022-04-19**

- Fix: add key to Chart StatefulWidget: https://github.com/entronad/graphic/pull/75
- Fix: add dispose to Chart.dart: https://github.com/entronad/graphic/pull/79
- Add size argument to custom annotation renderer method for responsiveness: https://github.com/entronad/graphic/pull/82
- Fix Sector corner radius bug: https://github.com/entronad/graphic/issues/58

## 0.9.2

**2022-04-05**

- Remove tooltip on exit chart area: https://github.com/entronad/graphic/pull/63
- Handle NaN in Point shape: https://github.com/entronad/graphic/pull/70

## 0.9.1

**2022-02-21**

- Allow `Label.text` and `Scale.formatter` return type to be null. For better performance, if they are null or empty string, nothing will be rendered: https://github.com/entronad/graphic/issues/51.
- The element gradient will be constained within the coordinate region except point element: https://github.com/entronad/graphic/issues/53.
- Fix non-gesture signal bug of signal updaters in `Defaults`: https://github.com/entronad/graphic/issues/52.

## 0.9.0

**2022-01-23**

- Add Interaction Channel feature. See details in [Chart.gestureChannel], [Chart.resizeChannel], [Chart.changeDataChannel] and [Element.selectionChannel].
- Rename updater properties.
- Add more [LabelStyle] properties. Now it includes all properties for [TextPainter].
- Add coordinate region background.
- Fix auto scale bug when all values are 0.

## 0.8.0

**2022-01-08**

- Upgrade the tick nice numbers algorithm and API.
- Optimize radical axis label alignment.
- Forced data operator `equalValue` method to false so that modifying the data list instance can trigger evaluation: https://github.com/entronad/graphic/issues/43.

## 0.7.0

**2021-12-28**

- Dimensions now has a enum type `Dim` instead of int [1, 2], which is always confused with [0, 1]: https://github.com/entronad/graphic/issues/31.
- `layer` now replace `zIndex`, which may confuse with z dimension and has a flavour of HTML.
- Fix `ScaleUpdateDetails.delta` problem.
- Fix resize problem. Now chart will resize properly and will inflate even if parent has no indicated size: https://github.com/entronad/graphic/issues/37.
- Fix and recover the auto spec diff feature.
- Add dash line feature.

## 0.6.2

**2021-12-19**

- Fix the issue of CustomAnnotation: https://github.com/entronad/graphic/issues/33.
- Fix the auto scale range when all data values are equal: https://github.com/entronad/graphic/issues/30.

## 0.6.1

**2021-12-13**

- Fix the issue of shouldRelayout: https://github.com/entronad/graphic/issues/29.
- Temporarily remove the auto spec diff feature. Now the default `rebuild` is always false.

## 0.6.0

**2021-12-11**

- Upgrade flutter version to `'>=2.6.0'` for `ScaleUpdate.focalPointDelta`: https://github.com/entronad/graphic/issues/21.
- The default `multituples` is true if a selection's variable is set.
- Add `OrdinalScale.inflate`.
- Remove the clip of figure annotation.
- `Chart.padding` is a function of chart size now.

## 0.5.1

**2021-12-01**

- Tooltip constraints.
- Now selections triggerd with same gesture is allowd.
- Device settings of selection.
- Now all z indexes are static, thus no need to resort scenes.
- Some updates above are inspired by https://github.com/entronad/graphic/issues/27.

## 0.5.0

**2021-12-01**

- Tooltip constraints.
- Now selections triggerd with same gesture is allowd.
- Device settings of selection.
- Now all z indexes are static, thus no need to resort scenes.
- Some updates above are inspired by https://github.com/entronad/graphic/issues/27.

## 0.5.0

**2021-11-18**

- Add nest operator: `\` of algebra.
- Remove `GeomElement.groupBy`, which is replaced by nesting.
- Force labels always above graphics in an element.
- Rename All function properties to nouns.
- Fix a scale fommatter generic bug: https://github.com/entronad/graphic/issues/22.
- Constrain flutter version to `'>=2.4.0 <2.6.0'` for `ScaleUpdate.delta`: https://github.com/entronad/graphic/issues/21.

## 0.4.1

**2021-10-27**

- Optimize the documentation.
- Move specifications to Chart class.

## 0.4.0

**2021-10-26**

- A complete refactoring.
- Better declaration grammer.
- Dataflow.
- Interactive.
- Documentation.

## 0.3.0

**2020-12-04**

- Add chart interaction.
- Optimize big data rendering by remoing _sort() in addShape().

## 0.2.1

**2020-11-17**

- Add invalid datum handling. Now if datum has invlid y values(null, NaN, Infinity), processions will handle correctly and line/area shape will have a break at that point.
- Add big data examples.

## 0.2.0

**2020-11-03**

- Redefine scale types to CatScale, LinearScale, and TimeScale, basicly according to the value type. This classification is closer to *The Grammer of Graphics*.
- Change Shape type from function to class, for future expansions.
- Redefine the datum record object.
- Remove polygon geom and move heatmap to point geom and rename it to 'tile'. This classification is closer to *The Grammer of Graphics*.
- Reconstruct the interval and area shape. Now they have two position points.
- Reconstruct stack adjust. Now they will really stack in height.
- Reconstruct symmetric adjust. Now it will not generate new records list.

## 0.1.1

**2020-09-15**

- Fix example pic link in readme.

## 0.1.0

**2020-09-15**

- First version.
- Provide static charts.
