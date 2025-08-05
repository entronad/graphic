# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Requirements
All content in this project (including code, comments, and documentation) must be in English.

## Project Overview
Graphic is a Flutter charting library implementing a grammar of graphics for data visualization. The library provides a declarative API for creating interactive and animated charts with customizable shapes and visual elements.

## Common Development Commands

### Running Tests
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/algebra/varset_test.dart

# Run tests with coverage
flutter test --coverage
```

### Linting and Code Analysis
```bash
# Run Flutter analyzer to check for issues
flutter analyze

# Lint the code with dart formatter
dart format lib/ test/ --set-exit-if-changed
```

### Example Application
```bash
# Navigate to example directory
cd example

# Install dependencies
flutter pub get

# Run the example app
flutter run

# Build for specific platforms
flutter build ios
flutter build android
flutter build web
```

### Publishing
```bash
# Dry run to check if package is ready for publishing
flutter pub publish --dry-run

# Publish to pub.dev (requires authentication)
flutter pub publish
```

## Architecture Overview

### Core Concepts Flow
```
variable -> scale -> aesthetic -> shape
   |         |          |          |
data -> tuples -> scaled tuples -> aesthetic encodes -> elements
```

### Key Modules

1. **Chart Widget** (`lib/src/chart/`)
   - Entry point for the library
   - Manages data visualization lifecycle
   - Handles resize events and data changes

2. **Data Processing** (`lib/src/data/`, `lib/src/variable/`)
   - Variables define tuple fields and data transformations
   - DataSet manages the raw data
   - Transforms include filter, map, proportion, and sort operations

3. **Algebra System** (`lib/src/algebra/`)
   - Varset defines how variable values map to position dimensions
   - Implements the graphic algebra for position assignment

4. **Scales** (`lib/src/scale/`)
   - Convert tuple values to scaled values
   - Types: Linear, Ordinal, Time, Discrete, Continuous
   - Includes utilities for nice numbers and ranges

5. **Marks** (`lib/src/mark/`)
   - Visual representations: Area, Interval, Line, Point, Polygon, Custom
   - Modifiers: Dodge, Stack, Jitter, Symmetric
   - Each mark type has corresponding shape implementations

6. **Shapes** (`lib/src/shape/`)
   - Render tuples with aesthetic attributes
   - Create MarkElements for the rendering engine
   - Custom shapes extend base shape classes

7. **Encoding** (`lib/src/encode/`)
   - Aesthetic encodings: Color, Size, Shape, Label, Gradient, Elevation
   - Channel encoding for mapping data to visual properties

8. **Coordinates** (`lib/src/coord/`)
   - RectCoord for Cartesian coordinates
   - PolarCoord for polar coordinates
   - Determines position mapping on canvas

9. **Guides** (`lib/src/guide/`)
   - Axes (horizontal, vertical, circular, radial)
   - Annotations (line, region, tag, custom)
   - Interactive components (tooltip, crosshair)

10. **Interactions** (`lib/src/interaction/`)
    - Event handling for gestures, resize, and data changes
    - Selection system for point and interval selections
    - Event and selection updaters

11. **Rendering** (`lib/src/graffiti/`)
    - Low-level drawing elements and primitives
    - Transition animations
    - Scene management

### Extension Points

- **Custom Marks**: Extend `Mark` class in `lib/src/mark/`
- **Custom Shapes**: Extend `Shape` class in `lib/src/shape/`
- **Custom Scales**: Extend `Scale` class in `lib/src/scale/`
- **Custom Annotations**: Extend `Annotation` class in `lib/src/guide/annotation/`

### Testing Strategy
- Unit tests in `test/` mirror the library structure
- Focus on algebra, scale utilities, and data transformations
- Example app in `example/` serves as integration testing