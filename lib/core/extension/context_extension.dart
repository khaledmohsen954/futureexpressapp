import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

extension ContextExtension on BuildContext {
  double width() => MediaQuery.sizeOf(this).width;

  double height() => MediaQuery.sizeOf(this).height;

  String fontFamily() => apiTr(ar: 'ArbFONTS-GE_SS_Two', en: 'Frutiger');
  String fontFamilyAr() => 'ArbFONTS-GE_SS_Two';
  String fontFamilyEn() => 'Frutiger';

  double fontHeight() {
    return Localizations.localeOf(this).languageCode == 'en' ? 1 : 1.0;
  }

  String apiTr({required String ar, required String en}) {
    String text = '';
    switch (Localizations.localeOf(this).languageCode) {
      case 'ar':
        text = ar;
        break;
      case 'en':
        text = en;
        break;
    }
    return text;
  }

  dynamic getByLang({required dynamic ar, required dynamic en}) {
    switch (Localizations.localeOf(this).languageCode) {
      case 'ar':
        return ar;
      case 'en':
        return en;
    }
  }

  void doByLang({required VoidCallback ar, required VoidCallback en}) {
    switch (Localizations.localeOf(this).languageCode) {
      case 'ar':
        ar.call();
        break;
      case 'en':
        en.call();
        break;
    }
  }

  bool isRTL() {
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(this).languageCode);
  }
}
