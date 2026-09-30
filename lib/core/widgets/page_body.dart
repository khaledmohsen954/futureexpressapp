import 'package:flutter/material.dart';

/// Consistent padded page container for all right-to-left screens.
class PageBody extends StatelessWidget {
  const PageBody(
      {super.key,
      required this.children,
      this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 24)});
  final List<Widget> children;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) =>
      SafeArea(child: ListView(padding: padding, children: children));
}
