
import 'package:flutter_marketplace_template/core/auth_result.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/services/notifications_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthService {
  Future<AuthResult> signUpWithPassword(String email, String password);
  Future<AuthResult> signInWithPassword(String email, String password);
  Future<bool> isUserDeleted(String userId);
  Future<AuthResult> resetPassword(String email);
  Future<void> logout();
}

class AuthServiceSupabase implements IAuthService {
  final INotificationsService _notificationsService;

  AuthServiceSupabase(this._notificationsService);

  /// Attempts to register a new user using an email address and password.
  ///
  /// Uses Supabase Auth directly.
  ///
  /// Returns [AuthSuccess] if successful, otherwise [AuthError] with an error description.
  @override
  Future<AuthResult> signUpWithPassword(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final User? user = res.user;
      if (user == null) {
        return AuthError('Impossible de créer le compte.');
      }

      return AuthSuccess();
    } on AuthException catch (e) {
      return AuthError(e.message);
    } catch (e) {
      return AuthError("Erreur lors de l'inscription : $e");
    }
  }

  /// Attempts to log in the user using their email and password.
  ///
  /// Uses Supabase Auth (`signInWithPassword`) to authenticate the user
  /// and establish a new session.
  ///
  /// Checks that the user's account has not been deleted.
  ///
  /// Returns [AuthSuccess] if successful, or [AuthError] if there is an error.
  @override
  Future<AuthResult> signInWithPassword(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      //final Session? session = res.session;
      final User? user = res.user;

      if (user != null) {
        if (await isUserDeleted(user.id)) {
          await logout();
          return AuthError('Account has been deleted.');
        }
        await _notificationsService.saveFcmTokenToSupabase(user.id);
        return AuthSuccess();
      }

      return AuthError('Failed to log in user');
    } on AuthException catch (e) {
      return AuthError(e.message);
    } catch (e) {
      return AuthError('Unknown error: $e');
    }
  }

  /// Checks if the user with the given [userId] has been deleted.
  @override
  Future<bool> isUserDeleted(String userId) async {
    try {
      final response =
          await supabase
              .from('users')
              .select('deleted_at')
              .eq('id', userId)
              .maybeSingle();

      if (response == null) {
        return false;
      }
      return response['deleted_at'] != null;
    } catch (e) {
      return false;
    }
  }

  /// Sends an email with a password reset link to the specified email address.
  @override
  Future<AuthResult> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return AuthSuccess();
    } on AuthException catch (e) {
      return AuthError(e.message);
    } catch (e) {
      return AuthError('Unknown error: $e');
    }
  }

  /// Logs out the currently logged-in user.
  ///
  /// Removes the local session and invalidates it on the server.
  @override
  Future<void> logout() async {
    await _notificationsService.removeFcmTokenFromSupabase(
      supabase.auth.currentUser!.id,
    );
    await supabase.auth.signOut();
  }
}
