import 'dart:io';

import 'package:futureexpressapp/core/custom_widgets/custom_toast/custom_toast.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherMethods {
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  static Future<void> launchInBrowser(String url) async {
    if (url.isNotEmpty) {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } else {
      CommonMethods.showToast(message: "url is empty", type: ToastType.error);
    }
  }

  static Future<void> launchInApp(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  static Future<void> makeMailMessage(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }

  static String _whatsAppUrl(String phone) {
    if (Platform.isAndroid) {
      return "https://wa.me/$phone";
    } else {
      return "https://api.whatsapp.com/send?phone=$phone";
    }
  }

  static Future<void> launchWhatsApp(String phoneNumber) async {
    if (!await launchUrl(
      Uri.parse(_whatsAppUrl(phoneNumber)),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch ${_whatsAppUrl(phoneNumber)}';
    }
  }

  static Future<void> launchGoogleMap(double? lat, double? long) async {
    final url = 'https://www.google.com/maps?q=$lat,$long';
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
