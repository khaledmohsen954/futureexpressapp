import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futureexpressapp/core/l10n/app_locale_key.dart';

class ValidationMethods {
  static String? validateName(String? value) {
    if (value!.trim().isEmpty) {
      return tr(AppLocaleKey.validateName);
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value!.trim().isEmpty) {
      return tr(AppLocaleKey.validateEmail);
    } else if (!_emailValidationStructure(value.trim())) {
      return tr(AppLocaleKey.validateEmailStructure);
    }
    return null;
  }

  static bool _emailValidationStructure(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  static String? validatePhone(String? value, {Country? country}) {
    if (value!.trim().isEmpty) {
      return tr(AppLocaleKey.validatePhone);
    } else if (value.startsWith('0') &&
        (country != null && (value.trim().length != (country.example.trim().length + 1)))) {
      return tr(
        AppLocaleKey.validatePhoneContainTenNumbers,
        args: ["${country.example.trim().length + 1}"],
      );
    } else if (!value.startsWith('0') &&
        (country != null && (value.trim().length != country.example.trim().length))) {
      return tr(
        AppLocaleKey.validatePhoneContainTenNumbers,
        args: [country.example.trim().length.toString()],
      );
    } else {
      return null;
    }
  }

  static String? validatePassword(String? value) {
    if (value!.trim().isEmpty) {
      return tr(AppLocaleKey.enterYourPassword);
    } else if (value.trim().length < 6) {
      return tr(AppLocaleKey.validatePassword);
    }
    return null;
  }

  // Remove the static _password variable

  static String? validateNewPassword(String? value) {
    if (value == null || value.trim().length < 6) {
      return tr(AppLocaleKey.validatePassword);
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().length < 6) {
      return tr(AppLocaleKey.validatePassword);
    } else if (password != value) {
      return tr(AppLocaleKey.validateConfirmPassword);
    }
    return null;
  }

  static String? validateEmptyField(String? value, {String? error}) {
    if (value!.trim().isEmpty) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    }
    return null;
  }

  static String? validateEmptySingleSelect(dynamic value, {String? error}) {
    if (value == null) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    }
    return null;
  }

  static String? validateEmptyMultiSelect(
    List<dynamic>? value, {
    String? error,
  }) {
    if (value == null) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    } else if (value.isEmpty) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    }
    return null;
  }

  static String? validateImage(File? value, {String? error}) {
    if (value == null) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    }
    return null;
  }

  static String? validateMultiImage(List<File>? value, {String? error}) {
    if (value == null) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    } else if (value.isEmpty) {
      return error ?? tr(AppLocaleKey.validateEmpty);
    }
    return null;
  }
}
