import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_marketplace_template/models/annonce.dart';
import 'package:flutter_marketplace_template/services/favorite_places_service.dart';
import 'package:flutter_marketplace_template/services/fetch_response.dart';

class FavoritePlacesViewModel extends ChangeNotifier {
  final IFavoritePlacesService _favoritePlacesService;

  FavoritePlacesViewModel(
    this._favoritePlacesService,
  ) {
    Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.session != null) {
          loadFavorites();
        } else {
          clear();
        }
      },
    );

    if (Supabase.instance.client.auth.currentUser != null) {
      loadFavorites();
    }
  }

  Set<int> _favorites = <int>{};
  List<Annonce> _favoriteAnnonces = <Annonce>[];

  bool _loading = false;
  String? _error;

  final Set<int> _pending = <int>{};

  bool get isLoading => _loading;

  String? get errorMessage => _error;

  int get favoritesCount => _favorites.length;

  Set<int> get favorites => _favorites;

  List<Annonce> get favoriteAnnonces =>
      List.unmodifiable(_favoriteAnnonces);

  bool isFavorite(int annonceId) {
    return _favorites.contains(annonceId);
  }

  Future<void> loadFavorites() async {
    if (_loading) {
      return;
    }

    _loading = true;
    _error = null;

    notifyListeners();

    final response = await _favoritePlacesService
        .fetchFavoritePlacesDetailedForCurrentUser();

    if (response is FetchListSuccess<Annonce>) {
      _favoriteAnnonces =
          List<Annonce>.from(response.items);

      _favorites =
          _favoriteAnnonces.map((a) => a.id).toSet();

      _error = null;
    } else if (response
        is FetchListFailure<Annonce>) {
      _error = response.message;
    }

    _loading = false;

    notifyListeners();
  }

  Future<void> toggleFavorite(
    int annonceId, {
    Annonce? annonce,
  }) async {
    if (_pending.contains(annonceId)) {
      return;
    }

    _pending.add(annonceId);

    final previousFavorites =
        Set<int>.from(_favorites);

    final previousAnnonces =
        List<Annonce>.from(_favoriteAnnonces);

    final wasFavorite =
        _favorites.contains(annonceId);

    if (wasFavorite) {
      _favorites.remove(annonceId);

      _favoriteAnnonces.removeWhere(
        (a) => a.id == annonceId,
      );
    } else {
      _favorites.add(annonceId);

      if (annonce != null &&
          !_favoriteAnnonces.any(
            (a) => a.id == annonceId,
          )) {
        _favoriteAnnonces.insert(
          0,
          annonce,
        );
      }
    }

    notifyListeners();

    final success = wasFavorite
        ? await _favoritePlacesService
            .removeFavorite(annonceId)
        : await _favoritePlacesService
            .addFavorite(annonceId);

    if (!success) {
      _favorites = previousFavorites;
      _favoriteAnnonces = previousAnnonces;

      notifyListeners();
    }

    _pending.remove(annonceId);
  }

  void clear() {
    _favorites = <int>{};
    _favoriteAnnonces = <Annonce>[];
    _error = null;
    _loading = false;
    _pending.clear();

    notifyListeners();
  }
}
