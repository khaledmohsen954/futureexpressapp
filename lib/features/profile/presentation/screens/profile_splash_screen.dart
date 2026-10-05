import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/assets/app_images.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/theme.dart';

class ProfileSplashScreen extends StatelessWidget {
  const ProfileSplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.background],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppImages.fexLogo1024_500NoBG,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 36),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr(context, AppLocaleKey.loadingProfile),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
}
