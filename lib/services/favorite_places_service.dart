import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';

abstract class IFavoritePlacesService {
  Future<FetchResponse<Annonce>>
      fetchFavoritePlacesDetailedForCurrentUser();

  Future<bool> addFavorite(int annonceId);

  Future<bool> removeFavorite(int annonceId);

  Future<bool> toggleFavorite(int annonceId);
}

class FavoritePlacesServiceSupabase
    implements IFavoritePlacesService {
  static const String table = 'favorite_annonces';

  static User _requireAuthUser() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return user;
  }

  @override
  Future<FetchResponse<Annonce>>
      fetchFavoritePlacesDetailedForCurrentUser() async {
    try {
      final uid = _requireAuthUser().id;

      final rows = await supabase
          .from(table)
          .select('annonce_id, annonces(*)')
          .eq('user_id', uid)
          .order(
            'created_at',
            ascending: false,
          );

      final annonces = <Annonce>[];

      for (final raw in rows) {
        final annonceRaw = raw['annonces'];

        if (annonceRaw is Map) {
          annonces.add(
            Annonce.fromJson(
              Map<String, dynamic>.from(
                annonceRaw,
              ),
            ),
          );
        }
      }

      return FetchListSuccess<Annonce>(
        annonces,
      );
    } catch (e) {
      Log.warning(
        'Erreur chargement favoris Koteka : $e',
      );

      return FetchListFailure<Annonce>(
        'Impossible de charger les favoris : $e',
      );
    }
  }

  @override
  Future<bool> addFavorite(
    int annonceId,
  ) async {
    try {
      final uid = _requireAuthUser().id;

      await supabase.from(table).upsert({
        'user_id': uid,
        'annonce_id': annonceId,
      });

      return true;
    } catch (e) {
      Log.warning(
        'Erreur ajout favori : $e',
      );

      return false;
    }
  }

  @override
  Future<bool> removeFavorite(
    int annonceId,
  ) async {
    try {
      final uid = _requireAuthUser().id;

      await supabase
          .from(table)
          .delete()
          .eq('user_id', uid)
          .eq('annonce_id', annonceId);

      return true;
    } catch (e) {
      Log.warning(
        'Erreur suppression favori : $e',
      );

      return false;
    }
  }

  @override
  Future<bool> toggleFavorite(
    int annonceId,
  ) async {
    try {
      final uid = _requireAuthUser().id;

      final existing = await supabase
          .from(table)
          .select('annonce_id')
          .eq('user_id', uid)
          .eq('annonce_id', annonceId)
          .limit(1);

      if (existing.isNotEmpty) {
        await removeFavorite(annonceId);
        return false;
      }

      await addFavorite(annonceId);
      return true;
    } catch (e) {
      Log.warning(
        'Erreur modification favori : $e',
      );

      return false;
    }
  }
}
