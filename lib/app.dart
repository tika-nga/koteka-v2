import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/services/auth_service.dart';
import 'package:flutter_marketplace_template/services/chat_service.dart';
import 'package:flutter_marketplace_template/services/favorite_places_service.dart';
import 'package:flutter_marketplace_template/services/places_service.dart';
import 'package:flutter_marketplace_template/services/user_service.dart';
import 'package:flutter_marketplace_template/main.dart';
import 'package:flutter_marketplace_template/screens/auth/reset_password_screen_2.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/screens/auth/auth_gate.dart';
import 'package:flutter_marketplace_template/view_models/chat_view_model.dart';
import 'package:flutter_marketplace_template/view_models/chats_list_view_model.dart';
import 'package:flutter_marketplace_template/view_models/filter_view_model.dart';
import 'package:flutter_marketplace_template/view_models/language_view_model.dart';
import 'package:flutter_marketplace_template/view_models/navigation_view_model.dart';
import 'package:flutter_marketplace_template/view_models/places_model.dart';
import 'package:flutter_marketplace_template/view_models/profile_view_model.dart';
import 'package:flutter_marketplace_template/view_models/favorite_places_view_model.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/view_models/theme_view_model.dart';
import 'package:flutter_marketplace_template/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth event: ${data.event}');
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const ResetPasswordScreen2()),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read<IAuthService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => ChatViewModel(
                context.read<IUserService>(),
                context.read<IChatService>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => ChatsListViewModel(
                context.read<IPlacesService>(),
                context.read<IChatService>(),
                context.read<IUserService>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(context.read<IUserService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => FavoritePlacesViewModel(
                context.read<IFavoritePlacesService>(),
              ),
        ),
        ChangeNotifierProvider(create: (_) => FilterViewModel()),
        ChangeNotifierProvider(create: (context) => NavigationViewModel()),
        ChangeNotifierProvider(
          create:
              (context) => PlacesModel(
                context.read<IPlacesService>(),
                context.read<FilterViewModel>(),
              ),
        ),
      ],
      child: Consumer2<LanguageViewModel, ThemeViewModel>(
        builder: (context, languageViewModel, themeViewModel, _) {
          return MaterialApp(
            title: 'Koteka',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeViewModel.flutterMode,
            home: const AuthGate(),
            locale: languageViewModel.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
