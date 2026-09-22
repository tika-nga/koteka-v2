import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/core/user_result.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/services/auth_service.dart';
import 'package:flutter_marketplace_template/services/delete_user_use_case_service.dart';
import 'package:flutter_marketplace_template/services/notifications_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:flutter_marketplace_template/view_models/profile_view_model.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';
import 'package:flutter_marketplace_template/screens/favorite_places_screen.dart';
import 'package:flutter_marketplace_template/screens/my_ads_screen.dart';
import 'package:flutter_marketplace_template/views/components/profile_avatar_widget.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:permission_handler/permission_handler.dart'
    show
        Permission,
        PermissionActions,
        PermissionCheckShortcuts,
        PermissionStatusGetters,
        openAppSettings;
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(
        showTitle: true,
        showMenu: false,
        showChat: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileCard(context),

          const SizedBox(height: 20),

          _buildMyAdsCard(context),

          const SizedBox(height: 20),

          _buildFavoritesCard(context),

          const SizedBox(height: 20),

          _buildPreferencesCard(context),

          const SizedBox(height: 20),

          _buildActivityCard(context),

          const SizedBox(height: 24),

          _buildAccountButtons(context),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
  ) {
    return _CardContainer(
      child: Consumer<ProfileViewModel>(
        builder: (
          context,
          profileVM,
          _,
        ) {
          final user =
              profileVM.currentUser;

          final isLoading =
              profileVM.isLoading;

          final name =
              isLoading
                  ? '…'
                  : user?.nickname
                              .trim()
                              .isNotEmpty ==
                          true
                      ? user!.nickname.trim()
                      : 'Utilisateur';

          return Stack(
            children: [
              SkeletonFreeProfileHeader(
                name: name,
                avatarUrl:
                    user?.avatarUrl,
              ),

              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  tooltip:
                      'Modifier le profil',
                  icon: Icon(
                    Symbols.edit_square,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                    size: 22,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (
                            context,
                          ) =>
                              Consumer<
                                ProfileViewModel
                              >(
                                builder:
                                    (
                                      _,
                                      vm,
                                      __,
                                    ) =>
                                        ProfileEditDialog(
                                          avatarUrl:
                                              vm.currentUser
                                                  ?.avatarUrl,
                                        ),
                              ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyAdsCard(
    BuildContext context,
  ) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
                size: 24,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Mes annonces',
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Gérez les annonces que vous avez publiées.',
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 14,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(
                        alpha: 0.70,
                      ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const MyAdsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.list_alt_outlined,
                size: 19,
              ),
              label: const Text(
                'Voir mes annonces',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesCard(
    BuildContext context,
  ) {
    return _CardContainer(
      child: Consumer<
        FavoritePlacesViewModel
      >(
        builder: (
          context,
          favVM,
          _,
        ) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                    size: 24,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      'Favoris : '
                      '${favVM.favoritesCount}',
                      style: TextStyle(
                        fontFamily: 'Mplus1p',
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w500,
                        color:
                            Theme.of(context)
                                .colorScheme
                                .primary,
                      ),
                    ),
                  ),

                  if (favVM.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              const FavoritePlacesScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite_border,
                  size: 19,
                ),
                label: const Text(
                  'Voir les favoris',
                ),
                style:
                    TextButton.styleFrom(
                  foregroundColor:
                      Theme.of(context)
                          .colorScheme
                          .onSecondary,
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .secondary,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
  ) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Préférences',
          ),

          const SizedBox(height: 8),

          const Divider(
            height: 1,
            thickness: 0.5,
          ),

          const PreferencesSection(),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
  ) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            title: 'Activité',
          ),

          const SizedBox(height: 8),

          const Divider(
            height: 1,
            thickness: 0.5,
          ),

          Consumer<ProfileViewModel>(
            builder: (
              context,
              profileVM,
              _,
            ) {
              return _ActivityTile(
                label:
                    'Annonces publiées',
                value:
                    profileVM
                            .publishedAdsCount
                            ?.toString() ??
                        '—',
                icon:
                    Icons
                        .inventory_2_outlined,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountButtons(
    BuildContext context,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _BottomProfileButton(
            title:
                'Supprimer le compte',
            color:
                const Color.fromRGBO(
              255,
              59,
              48,
              1,
            ),
            onPressed: () async {
              await context
                  .read<
                    IDeleteUserUseCaseService
                  >()
                  .softDeleteUserAccount();
            },
            icon:
                Icons.delete_outlined,
            confirmationRequired: true,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: _BottomProfileButton(
            title: 'Se déconnecter',
            color:
                const Color.fromRGBO(
              16,
              20,
              94,
              1,
            ),
            onPressed: () async {
              await context
                  .read<IAuthService>()
                  .logout();
            },
            icon:
                Icons.logout_outlined,
          ),
        ),
      ],
    );
  }
}

class _CardContainer
    extends StatelessWidget {
  final Widget child;

  const _CardContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,
        borderRadius:
            BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              20,
              94,
              0.08,
            ),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SkeletonFreeProfileHeader
    extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const SkeletonFreeProfileHeader({
    super.key,
    required this.name,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          ProfileAvatarWidget(
            avatarUrl: avatarUrl,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Profil Koteka',
                  style: TextStyle(
                    fontFamily: 'Mplus1p',
                    fontSize: 14,
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(
                              alpha: 0.65,
                            ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _BottomProfileButton
    extends StatelessWidget {
  final Future<void> Function()
      onPressed;

  final IconData icon;
  final String title;
  final Color color;

  final bool confirmationRequired;

  const _BottomProfileButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.color,
    this.confirmationRequired = false,
  });

  Future<void> _execute(
    BuildContext context,
  ) async {
    if (!confirmationRequired) {
      await onPressed();
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Confirmez-vous ?',
          ),
          content: const Text(
            'Cette action supprimera votre compte.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text(
                'Annuler',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Oui',
                style:
                    TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed:
          () => _execute(context),
      icon: Icon(
        icon,
        size: 21,
      ),
      label: Text(
        title,
        textAlign: TextAlign.center,
      ),
      style:
          FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor:
            Colors.white,
        minimumSize:
            const Size(
          double.infinity,
          48,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }
}

class _PreferenceTile
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _PreferenceTile({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 15,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                Theme.of(context)
                    .colorScheme
                    .primary,
            size: 22,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 16,
                fontWeight:
                    FontWeight.w500,
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
              ),
            ),
          ),

          if (trailing != null)
            trailing!,
        ],
      ),
    );
  }
}

class _ActivityTile
    extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ActivityTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 15,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                Theme.of(context)
                    .colorScheme
                    .primary,
            size: 22,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Mplus1p',
                fontSize: 16,
                fontWeight:
                    FontWeight.w500,
                color:
                    Theme.of(context)
                        .colorScheme
                        .primary,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Mplus1p',
        fontSize: 22,
        fontWeight:
            FontWeight.w600,
        color:
            Theme.of(context)
                .colorScheme
                .primary,
      ),
    );
  }
}

class PreferencesSection
    extends StatefulWidget {
  const PreferencesSection({
    super.key,
  });

  @override
  State<PreferencesSection>
      createState() =>
          _PreferencesSectionState();
}

class _PreferencesSectionState
    extends State<PreferencesSection> {
  bool notificationsEnabled = false;

  String? userId;

  late final INotificationsService
      _notificationsService;

  Future<bool>
      _hasNotificationPermission() async {
    if (Platform.isIOS ||
        Platform.isMacOS) {
      final settings =
          await FirebaseMessaging.instance
              .getNotificationSettings();

      return settings.authorizationStatus ==
              AuthorizationStatus
                  .authorized ||
          settings.authorizationStatus ==
              AuthorizationStatus
                  .provisional;
    }

    if (Platform.isAndroid) {
      return Permission
          .notification.isGranted;
    }

    return true;
  }

  Future<bool>
      _requestNotificationPermission() async {
    if (Platform.isIOS ||
        Platform.isMacOS) {
      final settings =
          await FirebaseMessaging.instance
              .requestPermission();

      return settings.authorizationStatus ==
              AuthorizationStatus
                  .authorized ||
          settings.authorizationStatus ==
              AuthorizationStatus
                  .provisional;
    }

    if (Platform.isAndroid) {
      final status =
          await Permission.notification
              .request();

      return status.isGranted ||
          status.isLimited;
    }

    return true;
  }

  Future<void>
      onToggleNotifications(
    bool value,
  ) async {
    final id = userId;

    if (id == null ||
        id.isEmpty) {
      return;
    }

    if (value) {
      final granted =
          await _requestNotificationPermission();

      if (!granted) {
        if (mounted) {
          setState(() {
            notificationsEnabled =
                false;
          });
        }

        await openAppSettings();
        return;
      }

      await _notificationsService
          .saveFcmTokenToSupabase(id);

      if (mounted) {
        setState(() {
          notificationsEnabled =
              true;
        });
      }
    } else {
      try {
        await FirebaseMessaging
            .instance
            .deleteToken();
      } catch (_) {}

      await _notificationsService
          .removeFcmTokenFromSupabase(
        id,
      );

      if (mounted) {
        setState(() {
          notificationsEnabled =
              false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    userId =
        context
            .read<IUserService>()
            .getCurrentUserId();

    _notificationsService =
        context
            .read<
              INotificationsService
            >();

    _initializeNotifications();
  }

  Future<void>
      _initializeNotifications() async {
    final id = userId;

    if (id == null ||
        id.isEmpty) {
      return;
    }

    final hasPermission =
        await _hasNotificationPermission();

    final hasToken =
        await _notificationsService
            .hasTokenInSupabase(id);

    if (!mounted) {
      return;
    }

    setState(() {
      notificationsEnabled =
          hasPermission && hasToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _PreferenceTile(
      icon:
          Icons.notifications_outlined,
      label: 'Notifications',
      trailing: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Text(
            notificationsEnabled
                ? 'Activé'
                : 'Désactivé',
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 14,
              color:
                  Theme.of(context)
                      .colorScheme
                      .primary,
            ),
          ),

          const SizedBox(width: 6),

          Switch(
            value:
                notificationsEnabled,
            onChanged:
                onToggleNotifications,
          ),
        ],
      ),
    );
  }
}

class ProfileEditDialog
    extends StatefulWidget {
  final String? avatarUrl;

  const ProfileEditDialog({
    super.key,
    this.avatarUrl,
  });

  @override
  State<ProfileEditDialog>
      createState() =>
          _ProfileEditDialogState();
}

class _ProfileEditDialogState
    extends State<ProfileEditDialog> {
  late final TextEditingController
      _nickController;

  Uint8List? _pendingAvatarBytes;

  String? _pendingAvatarExt;

  bool _deleteAvatar = false;

  @override
  void initState() {
    super.initState();

    final vm =
        context.read<ProfileViewModel>();

    _nickController =
        TextEditingController(
      text:
          vm.currentUser?.nickname ??
              '',
    );
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor:
          Theme.of(context)
              .colorScheme
              .surface,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            24,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Modifier le profil',
                      style: TextStyle(
                        fontFamily:
                            'Mplus1p',
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              const Divider(),

              const SizedBox(height: 10),

              const Text(
                'Photo de profil',
                style: TextStyle(
                  fontFamily:
                      'Mplus1p',
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child:
                    ProfileAvatarWidget(
                  avatarUrl:
                      _deleteAvatar
                          ? null
                          : widget
                              .avatarUrl,
                  avatarBytes:
                      _pendingAvatarBytes,
                  radius:
                      screenWidth < 370
                          ? 32
                          : 38,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed: () async {
                    final picker =
                        ImagePicker();

                    final XFile?
                        picked =
                        await picker
                            .pickImage(
                      source:
                          ImageSource
                              .gallery,
                      maxWidth: 1024,
                      imageQuality: 85,
                    );

                    if (picked == null) {
                      return;
                    }

                    final bytes =
                        await picked
                            .readAsBytes();

                    final ext =
                        picked.name
                            .split('.')
                            .last
                            .toLowerCase();

                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _pendingAvatarBytes =
                          bytes;

                      _pendingAvatarExt =
                          ext;

                      _deleteAvatar =
                          false;
                    });
                  },
                  icon: const Icon(
                    Icons.image_outlined,
                  ),
                  label: const Text(
                    'Changer la photo',
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _pendingAvatarBytes =
                          null;

                      _pendingAvatarExt =
                          null;

                      _deleteAvatar =
                          true;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    'Supprimer la photo',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Nom public',
                style: TextStyle(
                  fontFamily:
                      'Mplus1p',
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    _nickController,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Nom affiché aux autres utilisateurs',
                  prefixIcon:
                      Icon(
                    Icons
                        .account_circle_outlined,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: Consumer<
                    ProfileViewModel>(
                  builder: (
                    context,
                    vm,
                    _,
                  ) {
                    return FilledButton.icon(
                      onPressed:
                          vm.isSaving
                              ? null
                              : () async {
                                  bool ok =
                                      true;

                                  final newNick =
                                      _nickController
                                          .text
                                          .trim();

                                  final currentNick =
                                      vm.currentUser
                                              ?.nickname
                                              .trim() ??
                                          '';

                                  if (newNick
                                          .isNotEmpty &&
                                      newNick !=
                                          currentNick) {
                                    ok =
                                        await vm
                                            .changeNickname(
                                      newNick,
                                    );
                                  }

                                  if (ok &&
                                      _pendingAvatarBytes !=
                                          null) {
                                    ok =
                                        await vm
                                            .uploadAvatar(
                                      _pendingAvatarBytes!,
                                      _pendingAvatarExt ??
                                          'jpg',
                                    );
                                  } else if (ok &&
                                      _deleteAvatar) {
                                    ok =
                                        await vm
                                            .deleteAvatar();
                                  }

                                  if (!mounted) {
                                    return;
                                  }

                                  if (ok) {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  }
                                },
                      icon:
                          vm.isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                    color:
                                        Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                ),
                      label:
                          const Text(
                        'Enregistrer les modifications',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
