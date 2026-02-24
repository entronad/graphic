# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Graphic is a Flutter charting library for data visualization based on Leland Wilkinson's *Grammar of Graphics* theory. It is a single-package Flutter library (not a monorepo) published to pub.dev.

- **SDK constraints**: Dart >=2.13.0 <4.0.0, Flutter >=3.16.0
- **Entry point**: `lib/graphic.dart` (exports all public API)
- **Only public Widget**: `Chart<D>` — all chart configuration is declarative via constructor parameters

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter test                 # Run all tests
flutter test test/path.dart  # Run a single test file
dart format .                # Format code (CI enforces --set-exit-if-changed)
flutter analyze .            # Static analysis
cd example && flutter run    # Run the example app
```

## Architecture

### Data Processing Pipeline

```
data → Variable → Tuple → Scale → Encode → Shape → MarkElement
```

Each layer is independently composable following Grammar of Graphics principles.

### Key Modules (`lib/src/`)

| Directory | Purpose |
|-----------|---------|
| `chart/` | `Chart` StatefulWidget and `ChartView` (extends `Dataflow`, the reactive computation graph) |
| `dataflow/` | Reactive dataflow engine — `Operator<V>` nodes form a DAG evaluated via priority queue |
| `parse/` | `parse()` converts Chart spec into a network of Operators in the Dataflow graph |
| `mark/` | Geometry mark types: Area, Line, Point, Interval, Polygon, Custom, Function, Partition |
| `encode/` | Aesthetic encodings: Color, Size, Shape, Label, Gradient, Elevation, Position |
| `scale/` | Scales: Linear, Ordinal, Time (with nice numbers utilities) |
| `coord/` | Coordinate systems: RectCoord (Cartesian), PolarCoord (polar/radial) |
| `shape/` | Shape renderers — each Mark type has corresponding Shape implementations |
| `graffiti/` | Low-level rendering engine: Graffiti → MarkScene → MarkElement, with transition animations |
| `guide/` | Axis, Tooltip, Crosshair, Annotation components |
| `interaction/` | Gesture handling, Selection (Point/Interval), events |
| `algebra/` | `Varset` with cross (`*`), blend (`+`), nest (`/`) operators for variable arrangement |
| `variable/` | Variable definitions and data transforms (Filter, Map, Proportion, Sort) |

### Core Design Patterns

- **Spec/Conv separation**: Spec classes (e.g., `Scale`, `Coord`) are declarative configuration; Conv classes (e.g., `ScaleConv`, `CoordConv`) are runtime converters
- **Dataflow reactivity**: Interactions (gesture, resize, data change) flow through `StreamController` → Operator DAG re-evaluation → re-render
- **CustomPaint rendering**: All drawing uses Flutter `Canvas` API directly, not higher-level Widgets
- **Animation interpolation**: `MarkElement.lerpFrom()` enables transition animations between states
- **Deep equality**: `deepCollectionEquals` used to avoid unnecessary recomputation in Operators

## Code Conventions

- Uses `flutter_lints` ruleset with `hash_and_equals` disabled (many classes override `==` without `hashCode`)
- CI requires `dart format` compliance
- Function-typed properties are always treated as "unchanged" in equality comparisons
- `Mark.tag` is used for element correspondence matching during animations
- Modifiers (Dodge, Stack, Jitter, Symmetric) work with the algebra nest (`/`) operator
- Custom shapes extend `CustomizableSpec` and must implement `equalTo()`
