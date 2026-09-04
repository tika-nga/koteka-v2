import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/language_view_model.dart';
import '../l10n/app_localizations.dart';

/// Displays a dialog for selecting the app language
Future<void> showLanguageDialog(BuildContext context, String selectedLanguage) async {
  final languageViewModel = context.read<LanguageViewModel>();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 7),
        titlePadding: EdgeInsets.only(left: 15, right: 15, top: 15),
        backgroundColor: Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Center(
          child: Column( 
              children:[
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 20),
                    IgnorePointer(
                      child: Text(
                        AppLocalizations.of(context)!.choose_language,
                        style: TextStyle(
                          fontFamily: 'Mplus1p',
                          fontSize: 24,
                          letterSpacing: -1,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: IconTheme(
                        data: IconThemeData(
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                SizedBox(height: 15),
              ]
          )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _langOption(context, 'Français', 'fr', selectedLanguage, languageViewModel),
_langOption(context, 'English', 'en', selectedLanguage, languageViewModel),
          ],
        ),
      );
    },
  );
}

Widget _langOption(
  BuildContext context,
  String label,
  String code,
  String selectedLanguage,
  LanguageViewModel languageViewModel,
) {
  return InkWell(
    onTap: () {
      languageViewModel.changeLocale(code);
      Navigator.of(context).pop();
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 0, right: 18, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (label != selectedLanguage)
            const SizedBox(width: 18),
          if (label == selectedLanguage)
            Icon(Icons.check, size: 18, color: label == selectedLanguage ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Mplus1p',
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: label == selectedLanguage ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    ),
  );
}