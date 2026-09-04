import 'package:flutter/material.dart';
import 'package:flutter_marketplace_template/screens/auth/sign_in_screen.dart';
import 'package:flutter_marketplace_template/screens/auth/sign_up_screen.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/adapters/language_dialog.dart';

/// Welcome screen shown on app launch if user is not authenticated,
/// with options to go to sign in or sign up screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    //final languageViewModel = Provider.of<LanguageViewModel>(context);
    //final Size size = MediaQuery.of(context).size;
    //var screenWidth = size.width;
    //var screenHeight = size.height;
    String selectedLanguage =
        Localizations.localeOf(context).languageCode == 'fr'
            ? 'Français'
            : 'English';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(124, 231, 255, 1),
              Color.fromRGBO(70, 79, 255, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Zdjęcie
              Positioned(
                top: 175,
                left: 0,
                right: 0,
                child: Center(
                  child: const Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      Icons.storefront,
      size: 90,
      color: Colors.white,
    ),
    SizedBox(height: 8),
    Text(
      'KOTEKA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 42,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
      ),
    ),
  ],
),
                ),
              ),

              // Zaloguj się
              Positioned(
                top: 426,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 210,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignInScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              );

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(curvedAnimation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 6,
                        shadowColor: const Color.fromRGBO(16, 20, 94, 0.25),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.go_to_login,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromRGBO(16, 20, 94, 1),
                          fontFamily: 'Mplus1p',
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          height: 1.0,
                          letterSpacing: 0.0,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 502,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 210,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignUpScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              final curvedAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              );

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(curvedAnimation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                        alignment: Alignment.center,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 6,
                        shadowColor: const Color.fromRGBO(16, 20, 94, 0.25),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.go_to_registration,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromRGBO(16, 20, 94, 1),
                          fontFamily: 'Mplus1p',
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          height: 1.0,
                          letterSpacing: 0.0,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 574,
                left: 75,
                child: GestureDetector(
                  onTap: () {
                    showLanguageDialog(context, selectedLanguage);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    child: const Center(
                      child: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
