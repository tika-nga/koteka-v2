import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @welcome_back.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour !'**
  String get welcome_back;

  /// No description provided for @sign_in.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get sign_in;

  /// No description provided for @sign_up.
  ///
  /// In fr, this message translates to:
  /// **'S’inscrire'**
  String get sign_up;

  /// No description provided for @dont_have_an_account_yet.
  ///
  /// In fr, this message translates to:
  /// **'Vous n’avez pas encore de compte ? '**
  String get dont_have_an_account_yet;

  /// No description provided for @already_have_an_account.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ? '**
  String get already_have_an_account;

  /// No description provided for @go_to_login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get go_to_login;

  /// No description provided for @go_to_registration.
  ///
  /// In fr, this message translates to:
  /// **'S’inscrire'**
  String get go_to_registration;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get english;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @choose_language.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get choose_language;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @forgot_your_password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgot_your_password;

  /// No description provided for @reset_your_password.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser votre mot de passe'**
  String get reset_your_password;

  /// No description provided for @repeat_your_password.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer votre mot de passe'**
  String get repeat_your_password;

  /// No description provided for @enter_the_code.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code à 6 chiffres envoyé à votre adresse e-mail'**
  String get enter_the_code;

  /// No description provided for @enter_your_email.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l’adresse e-mail associée à votre compte'**
  String get enter_your_email;

  /// No description provided for @set_a_new_password.
  ///
  /// In fr, this message translates to:
  /// **'Créez un nouveau mot de passe pour votre compte'**
  String get set_a_new_password;

  /// No description provided for @email_hint_text.
  ///
  /// In fr, this message translates to:
  /// **'email@domaine.com'**
  String get email_hint_text;

  /// No description provided for @log_out.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get log_out;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @favourite_places.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favourite_places;

  /// No description provided for @view_favourite_places.
  ///
  /// In fr, this message translates to:
  /// **'Voir les favoris'**
  String get view_favourite_places;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @on.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get on;

  /// No description provided for @off.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get off;

  /// No description provided for @edit_profile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get edit_profile;

  /// No description provided for @profile_picture.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil'**
  String get profile_picture;

  /// No description provided for @change_picture.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get change_picture;

  /// No description provided for @delete_picture.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get delete_picture;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Nom d’utilisateur'**
  String get username;

  /// No description provided for @set_nickname.
  ///
  /// In fr, this message translates to:
  /// **'Définir un nom public'**
  String get set_nickname;

  /// No description provided for @save_changes.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get save_changes;

  /// No description provided for @automatic.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get automatic;

  /// No description provided for @light.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get dark;

  /// No description provided for @delete_account.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get delete_account;

  /// No description provided for @confirm_action.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez-vous ?'**
  String get confirm_action;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @chat_load_failure.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la discussion'**
  String get chat_load_failure;

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @deletedChat.
  ///
  /// In fr, this message translates to:
  /// **'Discussion supprimée'**
  String get deletedChat;

  /// No description provided for @unknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknown;

  /// No description provided for @private_chat.
  ///
  /// In fr, this message translates to:
  /// **'Discussion privée'**
  String get private_chat;

  /// No description provided for @chat.
  ///
  /// In fr, this message translates to:
  /// **'Discussion'**
  String get chat;

  /// No description provided for @deleted_chat_description.
  ///
  /// In fr, this message translates to:
  /// **'Cette discussion a été supprimée et il n’est plus possible d’y envoyer des messages.'**
  String get deleted_chat_description;

  /// No description provided for @unable_to_get_location.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez autoriser l’accès à votre position.'**
  String get unable_to_get_location;

  /// No description provided for @no_selected_location.
  ///
  /// In fr, this message translates to:
  /// **'Aucun emplacement sélectionné.'**
  String get no_selected_location;

  /// No description provided for @your_location.
  ///
  /// In fr, this message translates to:
  /// **'Votre position'**
  String get your_location;

  /// No description provided for @radius.
  ///
  /// In fr, this message translates to:
  /// **'Rayon'**
  String get radius;

  /// No description provided for @reset_link_expired.
  ///
  /// In fr, this message translates to:
  /// **'Le lien de réinitialisation a expiré ou est incorrect.'**
  String get reset_link_expired;

  /// No description provided for @password_changed.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe a été modifié'**
  String get password_changed;

  /// No description provided for @empty_password.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe ne peut pas être vide'**
  String get empty_password;

  /// No description provided for @change_password.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le mot de passe'**
  String get change_password;

  /// No description provided for @password_reset_link_sent.
  ///
  /// In fr, this message translates to:
  /// **'Le lien de réinitialisation du mot de passe a été envoyé à votre adresse e-mail.'**
  String get password_reset_link_sent;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @days.
  ///
  /// In fr, this message translates to:
  /// **'jours'**
  String get days;

  /// No description provided for @day.
  ///
  /// In fr, this message translates to:
  /// **'jour'**
  String get day;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
