## 0.5.1

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
