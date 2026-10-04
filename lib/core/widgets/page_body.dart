import 'package:flutter/material.dart';

/// Consistent padded page container for all right-to-left screens.
class PageBody extends StatelessWidget {
  const PageBody(
      {super.key,
      required this.children,
      this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 24),
      this.physics});
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: padding,
          physics: physics,
          children: children,
        ),
      );
}
