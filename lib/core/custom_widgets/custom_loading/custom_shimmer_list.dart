import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class CustomShimmerList extends StatelessWidget {
  const CustomShimmerList({
    super.key,
    this.width,
    this.height = 80,
    this.radius = 11,
    this.shimmerColor,
    this.fillColor,
    this.duration = const Duration(milliseconds: 1500),
    this.padding,
    this.length,
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;
  final Color? shimmerColor;
  final Color? fillColor;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final int? length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: _buildShimmerList(context)));
  }

  List<Widget> _buildShimmerList(BuildContext context) {
    return List.generate(
      length ?? 5,
      (index) => Container(
        padding: padding ??
            const EdgeInsetsDirectional.only(start: 0, bottom: 0, end: 0),
        width: width ?? double.infinity,
        margin: margin ?? const EdgeInsetsDirectional.only(bottom: 16),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: Shimmer(
          color: shimmerColor ?? AppColors.red,
          duration: duration,
          child: SizedBox(
            height: height,
            width: width ?? double.infinity,
          ),
        ),
      ),
    );
  }
}
