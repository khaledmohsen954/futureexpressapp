import 'package:flutter/material.dart';

/// Show non-persistent UI feedback for actions without API integration.
void showLocalMessage(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
