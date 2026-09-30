import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/cache/hive/hive_methods.dart';
import 'package:futureexpressapp/core/routes/app_routers_import.dart';
import 'package:futureexpressapp/core/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../extension/context_extension.dart';
import '../extension/date_time_extension.dart';

class DateMethods {
  static String formatOrderFullDate(DateTime? dateTime) {
    if (dateTime == null) return "";

    // نجيب اللغة الحالية من الجهاز
    String locale = HiveMethods.getLang();

    // لو عربي نرجع فورمات عربي
    if (locale.startsWith("ar")) {
      String datePart = DateFormat('d MMMM yyyy', 'ar').format(dateTime);
      String timePart = DateFormat('hh:mm a', 'ar').format(dateTime);
      return "$datePart | $timePart";
    } else {
      // أي لغة تانية إنجليزي
      String datePart = DateFormat('d MMMM yyyy', 'en').format(dateTime);
      String timePart = DateFormat('hh:mm a', 'en').format(dateTime);
      return "$datePart | $timePart";
    }
  }

  static String formatWithToday(DateTime? dateTime) {
    if (dateTime == null) return "";

    String timePart = DateFormat('hh:mm a', 'en').format(dateTime);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime dateToCheck =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    String locale = HiveMethods.getLang();
    bool isAr = locale.startsWith("ar");

    if (dateToCheck == today) {
      return "${isAr ? "اليوم" : "Today"} $timePart";
    } else if (dateToCheck == yesterday) {
      return "${isAr ? "أمس" : "Yesterday"} $timePart";
    }

    return "${DateFormat('yyyy-MM-dd', 'en').format(dateTime)} $timePart";
  }

  static String formatToDate(DateTime? dateTime) {
    return dateTime != null
        ? DateFormat('yyy-MM-dd', 'en').format(dateTime)
        : "";
  }

  static String formatToFullData(DateTime? dateTime) {
    return dateTime != null
        ? DateFormat(
            'dd MMMM yyyy - hh:mm a',
            AppRouters.navigatorKey.currentContext!.locale.languageCode,
          ).format(dateTime)
        : "";
  }

  static String formatToDayMonthYearArabicMonth(DateTime? dateTime) {
    if (dateTime == null) return "";

    // نجيب اللغة الحالية
    String locale = HiveMethods.getLang();
    bool isAr = locale.startsWith("ar");

    // Format بالتاريخ بناءً على اللغة
    String formatted = DateFormat(
      'd MMMM yyyy',
      isAr ? 'ar' : 'en',
    ).format(dateTime);

    if (isAr) {
      // تحويل الأرقام العربية (٠١٢٣٤٥٦٧٨٩) إلى إنجليزية (0123456789) في حالة العربي
      const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      for (int i = 0; i < arabicDigits.length; i++) {
        formatted = formatted.replaceAll(arabicDigits[i], i.toString());
      }
    }

    return formatted;
  }

  static String formatToTime(DateTime? dateTime) {
    return dateTime != null
        ? DateFormat(
            "hh:mm a",
            AppRouters.navigatorKey.currentContext!.locale.languageCode,
          ).format(dateTime)
        : "";
  }

  static String formatTime(String? time) {
    Map<int, String>? s = time?.split(':').asMap();

    int hours = s?.containsKey(0) == true ? int.parse(s![0]!) : 00;
    int minutes = s?.containsKey(1) == true ? int.parse(s![1]!) : 00;

    DateTime? dateTime =
        s != null ? DateTime(0000, 00, 00, hours, minutes) : null;
    return dateTime != null
        ? DateFormat(
            "hh:mm a",
            AppRouters.navigatorKey.currentContext!.locale.languageCode,
          ).format(dateTime)
        : "";
  }

  static bool isSameDay({required DateTime date, DateTime? secondDate}) {
    DateTime dateTime = date;
    DateTime dateTime2 = secondDate ?? DateTime.now();
    return dateTime.year == dateTime2.year &&
        dateTime.month == dateTime2.month &&
        dateTime.day == dateTime2.day;
  }

  static bool timeBetween(String? start, String? end) {
    Map<int, String>? s = start?.split(':').asMap();

    int hoursS = s?.containsKey(0) == true ? int.parse(s![0]!) : 00;
    int minutesS = s?.containsKey(1) == true ? int.parse(s![1]!) : 00;

    Map<int, String>? e = end?.split(':').asMap();

    int hoursE = e?.containsKey(0) == true ? int.parse(e![0]!) : 00;
    int minutesE = e?.containsKey(1) == true ? int.parse(e![1]!) : 00;

    DateTime? startTime =
        s != null ? DateTime(0000, 00, 00, hoursS, minutesS) : null;
    DateTime? endTime =
        e != null ? DateTime(0000, 00, 00, hoursE, minutesE) : null;
    DateTime? nowTime = e != null
        ? DateTime(0000, 00, 00, TimeOfDay.now().hour, TimeOfDay.now().minute)
        : null;

    if (startTime != null && endTime != null) {
      if (nowTime.isBetween(startTime, endTime)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  static String timeAgo(DateTime? date, BuildContext context) {
    return date != null
        ? timeago.format(date, locale: context.locale.languageCode)
        : "----";
  }

  static int daysInMonth(final int monthNum, final int year) {
    List<int> monthLength = List.filled(12, 0);
    monthLength[0] = 31;
    monthLength[2] = 31;
    monthLength[4] = 31;
    monthLength[6] = 31;
    monthLength[7] = 31;
    monthLength[9] = 31;
    monthLength[11] = 31;
    monthLength[3] = 30;
    monthLength[8] = 30;
    monthLength[5] = 30;
    monthLength[10] = 30;

    if (leapYear(year) == true) {
      monthLength[1] = 29;
    } else {
      monthLength[1] = 28;
    }

    return monthLength[monthNum - 1];
  }

  static bool leapYear(int year) {
    bool leapYear = false;
    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      leapYear = false;
    } else if (year % 4 == 0) {
      leapYear = true;
    }

    return leapYear;
  }

  static String monthName(int month) {
    DateTime dateTime = DateTime(0, month);
    return DateFormat(
      'MMMM',
      AppRouters.navigatorKey.currentContext!.locale.languageCode,
    ).format(dateTime);
  }

  static String? weekdayName(int? weekday, BuildContext context) {
    const Map<int, String> weekdayNameEn = {
      1: "Monday",
      2: "Tuesday",
      3: "Wednesday",
      4: "Thursday",
      5: "Friday",
      6: "Saturday",
      7: "Sunday",
    };

    const Map<int, String> weekdayNameAr = {
      1: "الأثنين",
      2: "الثلاثاء",
      3: "الأربعاء",
      4: "الخميس",
      5: "الجمعه",
      6: "السبت",
      7: "الأحد",
    };
    return weekday != null
        ? context.apiTr(
            ar: weekdayNameAr[weekday] ?? "",
            en: weekdayNameEn[weekday] ?? "",
          )
        : null;
  }

  static Future<void> pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required void Function(DateTime) onSuccess,
    DateTime? firstDate,
    DateTime? lastDate,
    Color? mainColor,
    Color backgroundColor = AppColors.surface,
    Color textColor = AppColors.navy,
    List<DateTime>? disabledDates,
  }) async {
    // Ensure the initialDate is not in the disabled dates
    DateTime validInitialDate = initialDate;
    if (disabledDates != null) {
      while (disabledDates.any(
        (disabledDate) =>
            disabledDate.year == validInitialDate.year &&
            disabledDate.month == validInitialDate.month &&
            disabledDate.day == validInitialDate.day,
      )) {
        validInitialDate = validInitialDate.add(const Duration(days: 1));
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate:
          firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 30)),
      selectableDayPredicate: (day) {
        if (disabledDates != null) {
          return !disabledDates.any(
            (disabledDate) =>
                disabledDate.year == day.year &&
                disabledDate.month == day.month &&
                disabledDate.day == day.day,
          );
        }
        return true; // All days are selectable if no disabled dates are provided
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: mainColor ?? AppColors.red,
                  onPrimary: backgroundColor,
                  surface: backgroundColor,
                  onSurface: textColor,
                ),
            dialogTheme: DialogThemeData(backgroundColor: backgroundColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: textColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSuccess.call(picked);
    }
  }

  static Future<void> pickTime(
    BuildContext context, {
    required DateTime initialDate,
    required void Function(DateTime) onSuccess,
    Color? mainColor,
    Color backgroundColor = AppColors.surface,
    Color textColor = AppColors.navy,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialDate.hour,
        minute: initialDate.minute,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: mainColor ?? AppColors.red,
                    onPrimary: backgroundColor,
                    surface: backgroundColor,
                    onSurface: textColor,
                  ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: textColor),
              ),
              dialogTheme: DialogThemeData(backgroundColor: backgroundColor),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      DateTime time = DateTime(0000, 00, 00, picked.hour, picked.minute);
      onSuccess.call(time);
    }
  }
}
