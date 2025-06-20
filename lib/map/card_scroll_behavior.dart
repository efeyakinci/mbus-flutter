import 'package:flutter/widgets.dart';

class CardScrollBehavior extends ScrollBehavior{
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => ClampingScrollPhysics();
}