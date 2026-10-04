import 'dart:async';

import 'package:flutter/material.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/support/data/models/app_settings.dart';
import 'package:futureexpressapp/features/support/data/repositories/app_settings_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme.dart';
import '../../../../core/widgets.dart';

/// Figma 11:465 — contact details loaded from app settings.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, this.repository});

  final AppSettingsRepository? repository;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  AppSettings? _settings;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await (widget.repository ?? sl<AppSettingsRepository>())
        .getAppSettings();
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.errMessage;
      }),
      (settings) => setState(() {
        _settings = settings;
        _isLoading = false;
        _error = null;
      }),
    );
  }

  String _whatsappNumber(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '966${digits.substring(1)}';
    return digits;
  }

  Future<void> _launch(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          mounted) {
        showLocalMessage(context, tr(context, AppLocaleKey.linkCouldNotOpen));
      }
    } catch (error) {
      if (mounted) showLocalMessage(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.help))),
      body: PageBody(children: [
        if (_isLoading) const LinearProgressIndicator(),
        if (_error != null)
          Row(
            children: [
              Expanded(child: Text(_error!)),
              TextButton(
                onPressed: _isLoading ? null : _loadSettings,
                child: Text(tr(context, AppLocaleKey.retry)),
              ),
            ],
          ),
        const SizedBox(height: 12),
        const Center(
            child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.paleRed,
                child: Icon(Icons.headset_mic_outlined,
                    size: 42, color: AppColors.red))),
        const SizedBox(height: 14),
        Text(tr(context, AppLocaleKey.helpTitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
        if (settings != null) ...[
          const SizedBox(height: 5),
          Text(
            settings.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
        const SizedBox(height: 5),
        Text(tr(context, AppLocaleKey.helpSubtitle),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 26),
        SurfaceCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.chat_outlined, color: AppColors.green),
            const SizedBox(width: 9),
            Text(tr(context, AppLocaleKey.whatsapp),
                style: Theme.of(context).textTheme.titleSmall)
          ]),
          const SizedBox(height: 8),
          Text(tr(context, AppLocaleKey.whatsappHint),
              style: Theme.of(context).textTheme.bodyMedium),
          if (settings != null) ...[
            const SizedBox(height: 8),
            Text(settings.phone, style: Theme.of(context).textTheme.titleSmall),
          ],
          const SizedBox(height: 14),
          ActionButton(
              label: tr(context, AppLocaleKey.openWhatsapp),
              icon: Icons.chat,
              color: AppColors.green,
              onPressed: settings == null
                  ? null
                  : () => _launch(Uri.https(
                        'wa.me',
                        '/${_whatsappNumber(settings.phone)}',
                      ))),
        ])),
        const SizedBox(height: 13),
        SurfaceCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.phone_outlined, color: AppColors.red),
            const SizedBox(width: 9),
            Text(tr(context, AppLocaleKey.call),
                style: Theme.of(context).textTheme.titleSmall)
          ]),
          const SizedBox(height: 8),
          Text(tr(context, AppLocaleKey.callHint),
              style: Theme.of(context).textTheme.bodyMedium),
          if (settings != null) ...[
            const SizedBox(height: 8),
            Text(settings.phone, style: Theme.of(context).textTheme.titleSmall),
          ],
          const SizedBox(height: 14),
          ActionButton(
              label: tr(context, AppLocaleKey.phoneCall),
              icon: Icons.call_outlined,
              onPressed: settings == null
                  ? null
                  : () => _launch(
                        Uri(scheme: 'tel', path: settings.phone),
                      )),
        ])),
        if (settings != null) ...[
          const SizedBox(height: 13),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.email_outlined, color: AppColors.red),
                  const SizedBox(width: 9),
                  Text(
                    tr(context, AppLocaleKey.email),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ]),
                const SizedBox(height: 8),
                Text(
                  settings.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ActionButton(
                  label: settings.email,
                  icon: Icons.mail_outline,
                  onPressed: () => _launch(
                    Uri(scheme: 'mailto', path: settings.email),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(tr(context, AppLocaleKey.supportHours),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}
