import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

import 'package:flutter_marketplace_template/app.dart';
import 'package:flutter_marketplace_template/services/auth_service.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/delete_user_use_case_service.dart';
import 'package:flutter_marketplace_template/services/favorite_places_service.dart';
import 'package:flutter_marketplace_template/services/notifications_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';

final supabase = Supabase.instance.client;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration générale de Koteka.
  await dotenv.load(
    fileName: '.env',
  );

  await Firebase.initializeApp();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await Hive.initFlutter();
  await Hive.openBox('settings');

  await initNotifications();

  runApp(
    MultiProvider(
      providers: [
        Provider<INotificationsService>(
          create: (_) =>
              NotificationsServiceSupabase(),
        ),

        Provider<IAuthService>(
          create: (context) =>
              AuthServiceSupabase(
            context.read<INotificationsService>(),
          ),
        ),

        Provider<IUserService>(
          create: (_) =>
              UserServiceSupabase(),
        ),

        Provider<IChatService>(
          create: (context) =>
              ChatServiceSupabase(
            context.read<IUserService>(),
          ),
        ),

        Provider<IDeleteUserUseCaseService>(
          create: (context) =>
              DeleteUserUseCaseServiceSupabase(
            context.read<IUserService>(),
            context.read<IChatService>(),
            context.read<IAuthService>(),
          ),
        ),

        Provider<IFavoritePlacesService>(
          create: (_) =>
              FavoritePlacesServiceSupabase(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialisation des notifications locales.
Future<void> initNotifications() async {
  initializeTimeZones();

  // Fuseau utilisé par Koteka/Kinshasa.
  setLocalLocation(
    getLocation('Africa/Kinshasa'),
  );

  const androidSettings =
      AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const iosSettings =
      DarwinInitializationSettings();

  const initSettings =
      InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(
    initSettings,
  );

  // Android 13+
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // iOS
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}
