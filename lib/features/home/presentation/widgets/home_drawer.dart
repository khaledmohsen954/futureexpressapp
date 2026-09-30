import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/auth/data/repositories/logout_repository.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.state,
  });

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.navy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.paleRed,
                    child: Icon(Icons.person, color: AppColors.red),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.name ?? tr(context, AppLocaleKey.courierName),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.onDark),
                  ),
                  Text(
                    tr(context, AppLocaleKey.courier),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.onDarkMuted),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.headset_mic_outlined, color: AppColors.red),
              title: Text(tr(context, AppLocaleKey.help)),
              onTap: () {
                Navigator.pop(context);
                NavigatorMethods.pushNamed(context, RoutesName.supportScreen);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.red),
              title: Text(tr(context, AppLocaleKey.changeLanguage)),
              onTap: () {
                Navigator.pop(context);
                state.toggleLanguage();
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.red),
              title: Text(tr(context, AppLocaleKey.logout)),
              onTap: () {
                Navigator.pop(context);
                state.signOut(sl<LogoutRepository>()).then((result) {
                  if (!context.mounted) return;
                  result.fold(
                    (failure) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.errMessage)),
                    ),
                    (_) {},
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
