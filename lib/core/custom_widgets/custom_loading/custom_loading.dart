import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../theme.dart';

class CustomLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? secondRingColor;
  final Color? thirdRingColor;
  const CustomLoading({
    super.key,
    this.size = 35,
    this.color,
    this.secondRingColor,
    this.thirdRingColor,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.discreteCircle(
      color: color ?? AppColors.red,
      secondRingColor: secondRingColor ?? AppColors.green,
      thirdRingColor: thirdRingColor ?? AppColors.blue,
      size: size,
    );
  }
}
