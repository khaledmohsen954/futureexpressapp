import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futureexpressapp/core/theme/app_text_style.dart';
import 'package:futureexpressapp/core/theme/cubit/app_theme_cubit.dart';

void main() {
  testWidgets('AppTextStyle builds after app-wide initialization',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => BlocProvider(
          create: (_) => AppThemeCubit(),
          child: MaterialApp(
            locale: const Locale('en', 'US'),
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) => Text(
                'Styled text',
                style: AppTextStyle.textD16B(context),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Styled text'), findsOneWidget);
  });
}
