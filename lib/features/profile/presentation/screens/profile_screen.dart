import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futureexpressapp/core/services/services_locator_imports.dart';
import 'package:futureexpressapp/features/auth/data/repositories/logout_repository.dart';
import 'package:futureexpressapp/features/profile/data/models/user_profile.dart';
import 'package:futureexpressapp/features/profile/data/repositories/profile_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/navigator_methods.dart';
import '../../../../core/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdating = false;

  Future<void> _editProfile(UserProfile profile) async {
    final changes = await showDialog<_ProfileChanges>(
      context: context,
      builder: (_) => _EditProfileDialog(profile: profile),
    );
    if (changes == null) return;

    setState(() => _isUpdating = true);
    final result = await sl<ProfileRepository>().updateProfile(
      currentProfile: profile,
      name: changes.name,
      email: changes.email,
      phone: changes.phone,
      avatarPath: changes.avatarPath,
    );
    if (!mounted) return;
    setState(() => _isUpdating = false);
    final error = result.fold<String?>((failure) => failure.errMessage, (_) => null);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final updatedProfile = result.fold<UserProfile?>((_) => null, (profile) => profile);
    await AppScope.of(context).setUserProfile(updatedProfile!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr(context, AppLocaleKey.profileUpdated))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final profile = state.userProfile ??
        UserProfile(
          name: state.name,
          phone: state.phone,
          email: state.email,
          city: state.city,
        );

    return Scaffold(
      appBar: AppBar(title: Text(tr(context, AppLocaleKey.profile))),
      body: PageBody(children: [
        SurfaceCard(
          child: Column(children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.paleRed,
              backgroundImage: profile.localAvatarPath != null
                  ? FileImage(File(profile.localAvatarPath!))
                  : profile.avatar == null || profile.avatar!.isEmpty
                      ? null
                      : NetworkImage(profile.avatar!),
              child: profile.localAvatarPath == null &&
                      (profile.avatar == null || profile.avatar!.isEmpty)
                  ? const Icon(Icons.person, size: 42, color: AppColors.red)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(profile.name ?? tr(context, AppLocaleKey.courierName),
                style: Theme.of(context).textTheme.titleLarge),
            Text(
              profile.code == null
                  ? tr(context, AppLocaleKey.courier)
                  : '${tr(context, AppLocaleKey.profileCode)}: ${profile.code}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ]),
        ),
        const SizedBox(height: 20),
        SectionTitle(tr(context, AppLocaleKey.personalData)),
        const SizedBox(height: 8),
        SurfaceCard(
          child: Column(children: [
            _ProfileRow(
                Icons.person_outline, tr(context, AppLocaleKey.userName), profile.name ?? '—'),
            const Divider(),
            _ProfileRow(
                Icons.phone_outlined, tr(context, AppLocaleKey.phone), profile.phone ?? '—'),
            const Divider(),
            _ProfileRow(Icons.mail_outline, tr(context, AppLocaleKey.email), profile.email ?? '—'),
            const Divider(),
            _ProfileRow(
                Icons.location_on_outlined, tr(context, AppLocaleKey.city), profile.city ?? '—'),
            if (profile.nationalId != null) ...[
              const Divider(),
              _ProfileRow(
                Icons.badge_outlined,
                tr(context, AppLocaleKey.nationalId),
                profile.nationalId!,
              ),
            ],
            if (profile.licenseNumber != null) ...[
              const Divider(),
              _ProfileRow(
                Icons.credit_card_outlined,
                tr(context, AppLocaleKey.licenseNumber),
                profile.licenseNumber!,
              ),
            ],
            if (profile.bankName != null) ...[
              const Divider(),
              _ProfileRow(Icons.account_balance_outlined, tr(context, AppLocaleKey.bankName),
                  profile.bankName!),
            ],
            if (profile.bankAccountNumber != null) ...[
              const Divider(),
              _ProfileRow(
                Icons.account_balance_wallet_outlined,
                tr(context, AppLocaleKey.bankAccountNumber),
                profile.bankAccountNumber!,
              ),
            ],
            if (profile.workType != null) ...[
              const Divider(),
              _ProfileRow(Icons.work_outline, tr(context, AppLocaleKey.workType),
                  profile.workType.toString()),
            ],
            const Divider(),
            _ProfileRow(
              Icons.swap_horiz,
              tr(context, AppLocaleKey.shiftStatus),
              tr(
                context,
                state.onDuty ? AppLocaleKey.shiftActive : AppLocaleKey.shiftInactive,
              ),
            ),
            if (profile.completedShipments != null) ...[
              const Divider(),
              _ProfileRow(
                Icons.local_shipping_outlined,
                tr(context, AppLocaleKey.completedShipments),
                profile.completedShipments.toString(),
              ),
            ],
            if (profile.successRate != null) ...[
              const Divider(),
              _ProfileRow(
                Icons.trending_up,
                tr(context, AppLocaleKey.successRate),
                '${profile.successRate}%',
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        ActionButton(
          label: tr(context, AppLocaleKey.updateProfile),
          icon: Icons.edit_outlined,
          onPressed: _isUpdating ? null : () => _editProfile(profile),
        ),
        if (_isUpdating) ...[
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
        const SizedBox(height: 20),
        SurfaceCard(
          child: InkWell(
            onTap: state.toggleLanguage,
            child: Row(children: [
              const Icon(Icons.language, color: AppColors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tr(context, AppLocaleKey.changeLanguage),
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const Icon(Icons.chevron_left),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: InkWell(
            onTap: () => NavigatorMethods.pushNamed(context, RoutesName.supportScreen),
            child: Row(children: [
              const Icon(Icons.headset_mic_outlined, color: AppColors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tr(context, AppLocaleKey.help),
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              const Icon(Icons.chevron_left),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        ActionButton(
          label: tr(context, AppLocaleKey.logout),
          icon: Icons.logout,
          outlined: true,
          onPressed: () async {
            final result = await state.signOut(sl<LogoutRepository>());
            if (!context.mounted) return;
            result.fold(
              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.errMessage)),
              ),
              (_) {},
            );
          },
        ),
      ]),
    );
  }
}

class _ProfileChanges {
  const _ProfileChanges({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarPath,
  });

  final String name;
  final String email;
  final String phone;
  final String? avatarPath;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _email = TextEditingController(text: widget.profile.email);
  late final _phone = TextEditingController(text: widget.profile.phone);
  String? _avatarPath;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatar() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (mounted && image != null) setState(() => _avatarPath = image.path);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? error.code)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(tr(context, AppLocaleKey.updateProfile)),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Tooltip(
                message: tr(context, AppLocaleKey.chooseAvatar),
                child: GestureDetector(
                  onTap: _chooseAvatar,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.paleRed,
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : widget.profile.localAvatarPath != null
                            ? FileImage(File(widget.profile.localAvatarPath!))
                            : widget.profile.avatar == null || widget.profile.avatar!.isEmpty
                                ? null
                                : NetworkImage(widget.profile.avatar!),
                    child: _avatarPath == null &&
                            widget.profile.localAvatarPath == null &&
                            (widget.profile.avatar == null || widget.profile.avatar!.isEmpty)
                        ? const Icon(Icons.add_a_photo_outlined, color: AppColors.red)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: tr(context, AppLocaleKey.userName)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr(context, AppLocaleKey.userNameRequired)
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: tr(context, AppLocaleKey.email)),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return tr(context, AppLocaleKey.validateEmailStructure);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: tr(context, AppLocaleKey.phone)),
                validator: (value) => value == null || value.trim().isEmpty
                    ? tr(context, AppLocaleKey.phoneRequired)
                    : null,
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(context, AppLocaleKey.cancel)),
          ),
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                _ProfileChanges(
                  name: _name.text.trim(),
                  email: _email.text.trim(),
                  phone: _phone.text.trim(),
                  avatarPath: _avatarPath,
                ),
              );
            },
            child: Text(tr(context, AppLocaleKey.save)),
          ),
        ],
      );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.icon, this.title, this.value);

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, color: AppColors.muted, size: 20),
          const SizedBox(width: 9),
          Text(title),
          const Spacer(),
          Flexible(
            child:
                Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodySmall),
          ),
        ]),
      );
}
