import 'home_page.dart';
import './pages/shape_page.dart';
import './pages/attribute_animation_page.dart';
import './pages/delegate_event_page.dart';
import './pages/on_frame_animation_page.dart';
import './pages/path_animation_page.dart';
import './pages/shape_event_page.dart';
import './pages/transform_page.dart';

final routes = {
  '/': (context) => HomePage(),
  '/demos/attribute_animation_page': (context) => AttributeAnimationPage(),
  '/demos/delegate_event_page': (context) => DelegateEventPage(),
  '/demos/on_frame_animation_page': (context) => OnFrameAnimationPage(),
  '/demos/path_animation_page': (context) => PathAnimationPage(),
  '/demos/shape_event_page': (context) => ShapeEventPage(),
  '/demos/shape_page': (context) => ShapePage(),
  '/demos/transform_page': (context) => TransformPage(),
};
