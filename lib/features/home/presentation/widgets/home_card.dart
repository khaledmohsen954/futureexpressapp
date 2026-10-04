import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

class HomeCard extends StatelessWidget {
  const HomeCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.iconWidget,
      required this.onTap});
  final String label, value;
  final IconData icon;
  final Widget? iconWidget;

  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 120,
          child: SurfaceCard(
            color: AppColors.navy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: AppColors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (value.isEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.onDarkMuted,
                      size: 22,
                    ),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                      if (iconWidget != null) ...[
                        const SizedBox(width: 5),
                        iconWidget!,
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
}
