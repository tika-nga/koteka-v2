import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/models/app_user.dart';
import 'package:flutter_marketplace_template/core/user_result.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:flutter_marketplace_template/utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final IUserService _userService;

  AppUser? _currentUser;
  bool _loading = false;
  String? _error;
  bool _saving = false;

  int? _publishedAdsCount;

  ProfileViewModel(this._userService) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (session != null) {
        loadCurrentUser();
      } else {
        clear();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      loadCurrentUser();
    }
  }

  AppUser? get currentUser => _currentUser;

  bool get isLoading => _loading;

  String? get errorMessage => _error;

  bool get isSaving => _saving;

  bool get isPremium =>
      _currentUser?.isPremium ?? false;

  int? get publishedAdsCount =>
      _publishedAdsCount;

  Future<void> loadCurrentUser() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result =
        await _userService.getUser();

    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;
        _error = null;

        await _loadPublishedAdsCount();
        break;

      case UserSuccess():
        await _loadPublishedAdsCount();
        break;

      case UserError(:final errorMessage):
        _error = errorMessage;
        _currentUser = null;
        _publishedAdsCount = null;
        break;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _loadPublishedAdsCount() async {
    final userId =
        Supabase.instance.client.auth.currentUser?.id;

    if (userId == null || userId.isEmpty) {
      _publishedAdsCount = null;
      return;
    }

    try {
      final response =
          await Supabase.instance.client
              .from('annonces')
              .select('id')
              .eq('user_id', userId);

      _publishedAdsCount =
          (response as List).length;
    } catch (_) {
      _publishedAdsCount = null;
    }
  }

  Future<void> refreshPublishedAdsCount() async {
    await _loadPublishedAdsCount();
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _error = null;
    _publishedAdsCount = null;

    notifyListeners();
  }

  Future<bool> changeNickname(
    String nickname,
  ) async {
    final trimmed = nickname.trim();

    final validation =
        Validators.validateNickname(trimmed);

    if (validation is ValidationError) {
      _error = validation.message;
      notifyListeners();

      return false;
    }

    _saving = true;
    _error = null;
    notifyListeners();

    final result =
        await _userService.changeUserNickname(
      trimmed,
    );

    switch (result) {
      case UserSuccess():
        await loadCurrentUser();

        _saving = false;
        notifyListeners();

        return true;

      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();

        return false;

      default:
        _saving = false;
        notifyListeners();

        return false;
    }
  }

  Future<bool> uploadAvatar(
    Uint8List bytes,
    String fileExt,
  ) async {
    _saving = true;
    _error = null;
    notifyListeners();

    final result =
        await _userService.uploadAvatarFromBytes(
      bytes,
      fileExt,
    );

    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;

        await _loadPublishedAdsCount();

        _saving = false;
        notifyListeners();

        return true;

      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();

        return false;

      default:
        _saving = false;
        notifyListeners();

        return false;
    }
  }

  Future<bool> deleteAvatar() async {
    _saving = true;
    _error = null;
    notifyListeners();

    final result =
        await _userService.deleteAvatar();

    switch (result) {
      case UserLoaded(:final user):
        _currentUser = user;

        await _loadPublishedAdsCount();

        _saving = false;
        notifyListeners();

        return true;

      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();

        return false;

      default:
        _saving = false;
        notifyListeners();

        return false;
    }
  }

  Future<bool> setPremium(
    bool premium,
  ) async {
    _saving = true;
    _error = null;
    notifyListeners();

    final result =
        await _userService.changePremiumStatus(
      premium,
    );

    switch (result) {
      case UserSuccess():
        await loadCurrentUser();

        _saving = false;
        notifyListeners();

        return true;

      case UserError(:final errorMessage):
        _error = errorMessage;
        _saving = false;
        notifyListeners();

        return false;

      default:
        _saving = false;
        notifyListeners();

        return false;
    }
  }
}
