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
