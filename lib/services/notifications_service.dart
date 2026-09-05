import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/services/logger_service.dart';

/// Service for managing push notifications.
abstract class INotificationsService {
  Future<String?> getFcmToken();
  Future<void> saveFcmTokenToSupabase(String userId);
  Future<void> removeFcmTokenFromSupabase(String userId);
  Future<bool> hasTokenInSupabase(String userId);
}

/// Service for managing push notifications using Firebase Cloud Messaging (FCM) and Supabase for token storage.
class NotificationsServiceSupabase implements INotificationsService {
  NotificationsServiceSupabase() {
    //TODO: after click in pop-up notification, navigate to the chat screen
    // not implemented yet
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // możesz pokazać własny in-app dialog
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final chatId = message.data['chat_id'];
      //context.go('/chat/$chatId');
    });
  }

  ///Fetchses the FCM token for the device.
    @override
  Future<String?> getFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final token = await messaging.getToken();
      return token;
    } catch (e) {
      Log.error('Firebase Messaging indisponible: $e');
      return null;
    }
  }

  /// Saves the FCM token to Supabase for the given user ID.
  @override
  Future<void> saveFcmTokenToSupabase(String userId) async {
    final token = await getFcmToken();
    if (token == null) return;

    try {
      await supabase.from('user_devices').upsert({
        'user_id': userId,
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Log.error('Failed to save FCM token to Supabase: $e');
    }
  }

  /// Removes the FCM token from Supabase for the given user ID.
  @override
  Future<void> removeFcmTokenFromSupabase(String userId) async {
    final token = await getFcmToken();
    if (token == null) return;

    try {
      await supabase
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (e) {
      Log.error('Failed to remove FCM token from Supabase: $e');
    }
  }

  /// Checks if the FCM token exists in Supabase for the given user ID.
  @override
  Future<bool> hasTokenInSupabase(String userId) async {
    final token = await getFcmToken();
    if (token == null) return false;

    final dynamic response;
    try {
      response = await supabase
          .from('user_devices')
          .select('token')
          .eq('user_id', userId)
          .eq('token', token)
          .limit(1);
    } catch (e) {
      Log.error('Failed to check FCM token in Supabase: $e');
      return false;
    }

    final data = response as List<dynamic>;
    return data.isNotEmpty;
  }
}
