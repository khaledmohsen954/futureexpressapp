import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';

import '../theme.dart';

/// The new Saudi Riyal sign is used throughout every monetary value.
class Money extends StatelessWidget {
  const Money(this.amount,
      {super.key, this.color = AppColors.navy, this.size = 16, this.crossAxisAlignment});
  final Object amount;
  final Color color;
  final double size;
  final CrossAxisAlignment? crossAxisAlignment;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: [
          Text('$amount',
              textDirection: TextDirection.ltr,
              style:
                  Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: size, color: color)),
          SizedBox(width: 3),
          SvgPicture.asset(
            AppImages.saudiRiyal,
            width: 35,
            height: 35,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          )
        ],
      );
}
