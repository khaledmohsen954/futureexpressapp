import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/l10n/app_strings.dart';
import 'package:futureexpressapp/core/utils/common_methods.dart';
import 'package:futureexpressapp/core/widgets/messages.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> captureStatusImage(BuildContext context) async {
  try {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (!context.mounted || image == null) return null;

    final compressed = await CommonMethods.compressImage(File(image.path));
    if (!context.mounted) {
      await CommonMethods.cleanupStagingFiles([compressed]);
      return null;
    }
    return compressed;
  } on PlatformException catch (error) {
    if (context.mounted) {
      showLocalMessage(
        context,
        error.message ?? tr(context, AppLocaleKey.statusImageRequired),
      );
    }
    return null;
  } catch (error) {
    if (context.mounted) showLocalMessage(context, error.toString());
    return null;
  }
}
