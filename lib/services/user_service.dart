import 'dart:typed_data';
import 'package:flutter_marketplace_template/core/user_result.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';
import 'package:flutter_marketplace_template/models/app_user.dart' as domain;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling user-related operations.
abstract class IUserService {
  String users = 'users';
  User requireUser();
  String? getCurrentUserId();
  Future<UserResult> createUserRecord(String uid, String email);
  @override
Future<UserResult> changeUserNickname(String nickname) async {
  try {
    final uid = getCurrentUserId();

    if (uid == null || uid.isEmpty) {
      return const UserError(
        errorMessage: 'Utilisateur non connecté.',
      );
    }

    final result = await supabase
        .from(users)
        .update({
          'nickname': nickname.trim(),
        })
        .eq('id', uid)
        .select();

    Log.info('Modification du nom : $result');

    if (result.isEmpty) {
      return const UserError(
        errorMessage:
            'Le profil n’a pas été modifié. Vérifiez les autorisations Supabase.',
      );
    }

    return UserSuccess();
  } catch (e) {
    Log.warning(
      'Erreur modification du nom : $e',
    );

    return UserError(
      errorMessage:
          'Impossible de modifier le nom : $e',
    );
  }
}

/// Service for handling user-related operations via Supabase.
class UserServiceSupabase implements IUserService {
  @override
  String users = 'users';
  static const String avatarBucket = 'user-avatars';

  /// Returns the ID of the currently logged-in user or throws an exception.
  @override
  User requireUser() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Brak zalogowanego użytkownika.');
    }
    return user;
  }

  /// Returns the ID of the current user, or null if not logged in.
  @override
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  /// Creates a new user record in the database.
  @override
  Future<UserResult> createUserRecord(String uid, String email) async {
    try {
      final res = await supabase.from(users).insert({
        'id': uid,
        'email': email,
      });

      Log.info('New user successfully created');
      Log.info(res);
      return UserSuccess();
    } catch (e) {
      Log.warning('An error occurred');
      return UserError(
        errorMessage:
            'An error occurred while creating user record: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserResult> changeUserNickname(String nickname) async {
    try {
      final uid = getCurrentUserId();
      if (uid == null) {
        return const UserError(errorMessage: 'No logged-in user');
      }
      await supabase
          .from(users)
          .update({'nickname': nickname})
          .eq('id', uid)
          .select();
      return const UserSuccess();
    } catch (e) {
      return const UserError(errorMessage: 'Unable to change user nickname');
    }
  }

  @override
  Future<FetchResponse<String?>> getUserNickname(String userId) async {
    try {
      final List<Map<String, dynamic>> rows = await supabase
          .from(users)
          .select('nickname')
          .eq('id', userId)
          .limit(1);

      if (rows.isEmpty) {
        return FetchOneSuccess(null);
      }

      final row = rows.first;
      final nickname = row['nickname'] as String?;
      return FetchOneSuccess(nickname);
    } catch (e) {
      Log.warning('User nickname fetching error: $e');
      return FetchOneFailure('User nickname fetching error: $e');
    }
  }

  /// Changes user's premium status.
  @override
  Future<UserResult> changePremiumStatus(bool isPremium) async {
    try {
      final uid = getCurrentUserId();
      if (uid == null) {
        return const UserError(errorMessage: 'No logged-in user');
      }
      await supabase
          .from(users)
          .update({'is_premium': isPremium})
          .eq('id', uid)
          .select();
      return const UserSuccess();
    } catch (e) {
      return const UserError(
        errorMessage: 'Unable to change user premium status',
      );
    }
  }

  @override
  Future<UserResult> getUser() async {
    try {
      final authUser = requireUser();
      final List<Map<String, dynamic>> rows = await supabase
          .from(users)
          .select()
          .eq('id', authUser.id)
          .limit(1);

      if (rows.isEmpty) {
        return const UserError(errorMessage: 'No user profile found');
      }

      final row = rows.first;
      // If avatar_url is not saved, but avatar_path is, calculate the public URL.
      String? computedUrl = row['avatar_url'] as String?;
      final String? path = row['avatar_path'] as String?;
      if (computedUrl == null && path != null && path.isNotEmpty) {
        final res = supabase.storage.from(avatarBucket).getPublicUrl(path);
        computedUrl = res;
        // Optionally, you can cache the URL in the DB:
        // await supabase.from(users).update({‘avatar_url’: computedUrl}).eq(‘id’, authUser.id);
        row['avatar_url'] = computedUrl;
      }

      final domainUser = domain.AppUser.fromJson(row);
      return UserLoaded(domainUser);
    } catch (e) {
      Log.warning('Błąd pobierania użytkownika: $e');
      return const UserError(errorMessage: 'Failed to retrieve user data');
    }
  }

  /// Uploads the user's profile picture to Supabase Storage and updates the record in public.users.
  /// [bytes] - file content, [fileExt] - extension, e.g., ‘jpg’, ‘png’.
  @override
  Future<UserResult> uploadAvatarFromBytes(
    Uint8List bytes,
    String fileExt,
  ) async {
    try {
      final uid = getCurrentUserId();
      if (uid == null) return const UserError(errorMessage: 'No logged user');

      // Download the previous profile picture path (if it exists) to delete after the new upload is successful.
      String? previousPath;
      try {
        final prevRows = await supabase
            .from(users)
            .select('avatar_path')
            .eq('id', uid)
            .limit(1);
        if (prevRows.isNotEmpty) {
          previousPath = prevRows.first['avatar_path'] as String?;
        }
      } catch (_) {
        // We ignore the error – the lack of a previous profile picture does not block the upload.
      }

      final fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$uid/$fileName';
      final contentType = _contentTypeForExt(fileExt);

      // File size and type validations (1MB, selected extensions only)
      const maxBytes = 1 * 1024 * 512; // 512KB limit for the avatar
      if (bytes.length > maxBytes) {
        return const UserError(errorMessage: 'File is too large (max 1MB)');
      }
      const allowedExts = ['jpg', 'jpeg', 'png', 'webp'];
      final lowerExt = fileExt.toLowerCase();
      if (!allowedExts.contains(lowerExt)) {
        return const UserError(errorMessage: 'Not allowed file format');
      }

      await supabase.storage
          .from(avatarBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      final publicUrl = supabase.storage.from(avatarBucket).getPublicUrl(path);

      // Update user record
      await supabase
          .from(users)
          .update({'avatar_path': path, 'avatar_url': publicUrl})
          .eq('id', uid)
          .select();

      // Delete the previous file if it exists and differs from the new path.
      if (previousPath != null &&
          previousPath.isNotEmpty &&
          previousPath != path) {
        try {
          await supabase.storage.from(avatarBucket).remove([previousPath]);
        } catch (e) {
          Log.warning(
            'Unable to delete old profile picture ($previousPath): $e',
          );
        }
      }

      // Return the updated user
      return await getUser();
    } catch (e) {
      Log.warning('profile picture upload error: $e');
      return const UserError(errorMessage: 'Failed to upload profile picture ');
    }
  }

  /// Removes the profile picture from Storage (if it exists) and clears the fields in the DB.
  @override
  Future<UserResult> deleteAvatar() async {
    try {
      final authUser = requireUser();
      final rows = await supabase
          .from(users)
          .select('avatar_path')
          .eq('id', authUser.id)
          .limit(1);
      if (rows.isNotEmpty) {
        final path = rows.first['avatar_path'] as String?;
        if (path != null && path.isNotEmpty) {
          await supabase.storage.from(avatarBucket).remove([path]);
        }
      }

      await supabase
          .from(users)
          .update({'avatar_path': null, 'avatar_url': null})
          .eq('id', authUser.id)
          .select();

      return await getUser();
    } catch (e) {
      Log.warning('profile picture deletion error: $e');
      return const UserError(errorMessage: 'Failed to delete profile picture ');
    }
  }

  static String _contentTypeForExt(String ext) {
    final e = ext.toLowerCase();
    switch (e) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
