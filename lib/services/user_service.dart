import 'dart:typed_data';

import 'package:flutter_marketplace_template/core/user_result.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';
import 'package:flutter_marketplace_template/models/app_user.dart'
    as domain;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service de gestion des utilisateurs.
abstract class IUserService {
  String users = 'users';

  User requireUser();

  String? getCurrentUserId();

  Future<UserResult> createUserRecord(
    String uid,
    String email,
  );

  Future<UserResult> changeUserNickname(
    String nickname,
  );

  Future<FetchResponse<String?>> getUserNickname(
    String userId,
  );

  Future<UserResult> changePremiumStatus(
    bool isPremium,
  );

  Future<UserResult> getUser();

  Future<UserResult> uploadAvatarFromBytes(
    Uint8List bytes,
    String fileExt,
  );

  Future<UserResult> deleteAvatar();
}

/// Service de gestion des utilisateurs avec Supabase.
class UserServiceSupabase implements IUserService {
  @override
  String users = 'users';

  static const String avatarBucket =
      'user-avatars';

  // ==========================================================
  // UTILISATEUR CONNECTÉ
  // ==========================================================

  @override
  User requireUser() {
    final user =
        supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'Aucun utilisateur connecté.',
      );
    }

    return user;
  }

  @override
  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  // ==========================================================
  // CRÉATION DU PROFIL
  // ==========================================================

  @override
  Future<UserResult> createUserRecord(
    String uid,
    String email,
  ) async {
    try {
      final res =
          await supabase.from(users).insert({
        'id': uid,
        'email': email,
      });

      Log.info(
        'Profil utilisateur créé avec succès.',
      );

      Log.info(res);

      return UserSuccess();
    } catch (e) {
      Log.warning(
        'Erreur lors de la création du profil : $e',
      );

      return UserError(
        errorMessage:
            'Impossible de créer le profil utilisateur : $e',
      );
    }
  }

  // ==========================================================
  // MODIFICATION DU NOM PUBLIC
  // ==========================================================

  @override
  Future<UserResult> changeUserNickname(
    String nickname,
  ) async {
    try {
      final uid = getCurrentUserId();

      if (uid == null || uid.isEmpty) {
        return const UserError(
          errorMessage:
              'Utilisateur non connecté.',
        );
      }

      final newNickname =
          nickname.trim();

      if (newNickname.isEmpty) {
        return const UserError(
          errorMessage:
              'Le nom ne peut pas être vide.',
        );
      }

      final result = await supabase
          .from(users)
          .update({
            'nickname': newNickname,
          })
          .eq('id', uid)
          .select();

      Log.info(
        'Modification du nom : $result',
      );

      if (result.isEmpty) {
        return const UserError(
          errorMessage:
              'Le profil n’a pas été modifié. '
              'Vérifiez les autorisations Supabase.',
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

  // ==========================================================
  // RÉCUPÉRATION DU NOM PUBLIC
  // ==========================================================

  @override
  Future<FetchResponse<String?>>
      getUserNickname(
    String userId,
  ) async {
    try {
      final List<Map<String, dynamic>>
          rows = await supabase
              .from(users)
              .select('nickname')
              .eq('id', userId)
              .limit(1);

      if (rows.isEmpty) {
        return FetchOneSuccess(null);
      }

      final row = rows.first;

      final nickname =
          row['nickname'] as String?;

      return FetchOneSuccess(
        nickname,
      );
    } catch (e) {
      Log.warning(
        'Erreur récupération du nom : $e',
      );

      return FetchOneFailure(
        'Erreur récupération du nom : $e',
      );
    }
  }

  // ==========================================================
  // STATUT PREMIUM
  // ==========================================================

  @override
  Future<UserResult> changePremiumStatus(
    bool isPremium,
  ) async {
    try {
      final uid = getCurrentUserId();

      if (uid == null || uid.isEmpty) {
        return const UserError(
          errorMessage:
              'Utilisateur non connecté.',
        );
      }

      final result = await supabase
          .from(users)
          .update({
            'is_premium': isPremium,
          })
          .eq('id', uid)
          .select();

      if (result.isEmpty) {
        return const UserError(
          errorMessage:
              'Le statut Premium n’a pas été modifié.',
        );
      }

      return UserSuccess();
    } catch (e) {
      Log.warning(
        'Erreur modification du statut Premium : $e',
      );

      return UserError(
        errorMessage:
            'Impossible de modifier le statut Premium : $e',
      );
    }
  }

  // ==========================================================
  // RÉCUPÉRATION DU PROFIL
  // ==========================================================

  @override
  Future<UserResult> getUser() async {
    try {
      final authUser =
          requireUser();

      final List<Map<String, dynamic>>
          rows = await supabase
              .from(users)
              .select()
              .eq('id', authUser.id)
              .limit(1);

      if (rows.isEmpty) {
        return const UserError(
          errorMessage:
              'Profil utilisateur introuvable.',
        );
      }

      final row = rows.first;

      String? computedUrl =
          row['avatar_url'] as String?;

      final String? path =
          row['avatar_path'] as String?;

      if (computedUrl == null &&
          path != null &&
          path.isNotEmpty) {
        computedUrl = supabase.storage
            .from(avatarBucket)
            .getPublicUrl(path);

        row['avatar_url'] =
            computedUrl;
      }

      final domainUser =
          domain.AppUser.fromJson(
        row,
      );

      return UserLoaded(
        domainUser,
      );
    } catch (e) {
      Log.warning(
        'Erreur récupération utilisateur : $e',
      );

      return const UserError(
        errorMessage:
            'Impossible de récupérer les données utilisateur.',
      );
    }
  }

  // ==========================================================
  // PHOTO DE PROFIL
  // ==========================================================

  @override
  Future<UserResult> uploadAvatarFromBytes(
    Uint8List bytes,
    String fileExt,
  ) async {
    try {
      final uid = getCurrentUserId();

      if (uid == null || uid.isEmpty) {
        return const UserError(
          errorMessage:
              'Utilisateur non connecté.',
        );
      }

      String? previousPath;

      try {
        final prevRows =
            await supabase
                .from(users)
                .select('avatar_path')
                .eq('id', uid)
                .limit(1);

        if (prevRows.isNotEmpty) {
          previousPath =
              prevRows.first[
                      'avatar_path']
                  as String?;
        }
      } catch (e) {
        Log.warning(
          'Impossible de récupérer '
          'l’ancienne photo : $e',
        );
      }

      final lowerExt =
          fileExt.toLowerCase();

      const allowedExts = [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ];

      if (!allowedExts.contains(
        lowerExt,
      )) {
        return const UserError(
          errorMessage:
              'Format de fichier non autorisé.',
        );
      }

      // Limite : 512 Ko.
      const maxBytes =
          512 * 1024;

      if (bytes.length > maxBytes) {
        return const UserError(
          errorMessage:
              'La photo est trop volumineuse '
              '(maximum 512 Ko).',
        );
      }

      final fileName =
          '$uid-'
          '${DateTime.now().millisecondsSinceEpoch}.'
          '$lowerExt';

      final path =
          '$uid/$fileName';

      final contentType =
          _contentTypeForExt(
        lowerExt,
      );

      await supabase.storage
          .from(avatarBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType:
                  contentType,
            ),
          );

      final publicUrl =
          supabase.storage
              .from(avatarBucket)
              .getPublicUrl(path);

      final result = await supabase
          .from(users)
          .update({
            'avatar_path': path,
            'avatar_url': publicUrl,
          })
          .eq('id', uid)
          .select();

      if (result.isEmpty) {
        return const UserError(
          errorMessage:
              'La photo a été envoyée, '
              'mais le profil n’a pas pu être mis à jour.',
        );
      }

      if (previousPath != null &&
          previousPath.isNotEmpty &&
          previousPath != path) {
        try {
          await supabase.storage
              .from(avatarBucket)
              .remove([
            previousPath,
          ]);
        } catch (e) {
          Log.warning(
            'Impossible de supprimer '
            'l’ancienne photo '
            '($previousPath) : $e',
          );
        }
      }

      return await getUser();
    } catch (e) {
      Log.warning(
        'Erreur envoi photo de profil : $e',
      );

      return UserError(
        errorMessage:
            'Impossible d’envoyer '
            'la photo de profil : $e',
      );
    }
  }

  // ==========================================================
  // SUPPRESSION DE LA PHOTO
  // ==========================================================

  @override
  Future<UserResult> deleteAvatar() async {
    try {
      final authUser =
          requireUser();

      final rows =
          await supabase
              .from(users)
              .select('avatar_path')
              .eq(
                'id',
                authUser.id,
              )
              .limit(1);

      if (rows.isNotEmpty) {
        final path =
            rows.first[
                    'avatar_path']
                as String?;

        if (path != null &&
            path.isNotEmpty) {
          try {
            await supabase.storage
                .from(avatarBucket)
                .remove([
              path,
            ]);
          } catch (e) {
            Log.warning(
              'Impossible de supprimer '
              'le fichier de la photo : $e',
            );
          }
        }
      }

      final result = await supabase
          .from(users)
          .update({
            'avatar_path': null,
            'avatar_url': null,
          })
          .eq(
            'id',
            authUser.id,
          )
          .select();

      if (result.isEmpty) {
        return const UserError(
          errorMessage:
              'La photo de profil '
              'n’a pas pu être supprimée.',
        );
      }

      return await getUser();
    } catch (e) {
      Log.warning(
        'Erreur suppression photo '
        'de profil : $e',
      );

      return UserError(
        errorMessage:
            'Impossible de supprimer '
            'la photo de profil : $e',
      );
    }
  }

  // ==========================================================
  // TYPE MIME DES PHOTOS
  // ==========================================================

  static String _contentTypeForExt(
    String ext,
  ) {
    switch (ext.toLowerCase()) {
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
