import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_marketplace_template/screens/auth/send_reset_password_email_screen.dart';
import 'package:flutter_marketplace_template/view_models/auth_view_model.dart';
import 'package:flutter_marketplace_template/screens/auth/sign_up_screen.dart';
import 'package:flutter_marketplace_template/screens/loading_screen.dart';
import 'package:flutter_marketplace_template/views/components/auth_text_field.dart';
import 'package:flutter_marketplace_template/l10n/app_localizations.dart';
import 'package:flutter_marketplace_template/adapters/app_bar.dart';
import 'package:flutter_marketplace_template/views/components/error_message_widget.dart';

/// Screen for signing in, where user enters email and password to log in,
/// also has options to go to sign up screen and reset password screen
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen()
        : Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: CustomAppBar(
            showTitle: false,
            showMenu: false,
            showChat: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(16, 20, 94, 0.25),
                            blurRadius: 3,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: TextStyle(
                                fontFamily: 'Mplus1p',
                                fontSize: 24,
                                letterSpacing: -1,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 0.5,
                            color: const Color.fromRGBO(195, 196, 215, 1),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 9),
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                AuthTextField(
                                  controller: emailController,
                                  errorMessage:
                                      context
                                          .watch<AuthViewModel>()
                                          .emailErrorMessage,
                                  isPassword: false,
                                ),
                                Consumer<AuthViewModel>(
                                  builder:
                                      (context, value, child) =>
                                          errorMessageWidget(
                                            value.emailErrorMessage,
                                            context,
                                          ),
                                ),
                                const SizedBox(height: 6),
                                AuthTextField(
                                  controller: passwordController,
                                  errorMessage:
                                      context
                                          .watch<AuthViewModel>()
                                          .passwordErrorMessage,
                                  isPassword: true,
                                ),
                                Consumer<AuthViewModel>(
                                  builder:
                                      (context, value, child) => Column(
                                        children: [
                                          errorMessageWidget(
                                            value.passwordErrorMessage,
                                            context,
                                          ),
                                          errorMessageWidget(
                                            value.errorMessage,
                                            context,
                                          ),
                                        ],
                                      ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                        text: TextSpan(
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${AppLocalizations.of(context)!.forgot_your_password}\n',
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer:
                                                  TapGestureRecognizer()
                                                    ..onTap = () {
                                                      if (context.mounted) {
                                                        context
                                                            .read<
                                                              AuthViewModel
                                                            >()
                                                            .clearErrors();
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (_) =>
                                                                    const SendResetPasswordEmailScreen(),
                                                          ),
                                                        );
                                                      }
                                                    },
                                            ),
                                            const WidgetSpan(
                                              child: SizedBox(height: 29),
                                            ),
                                            TextSpan(
                                              text:
                                                  '${AppLocalizations.of(context)!.dont_have_an_account_yet}\n',
                                              style: const TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  AppLocalizations.of(
                                                    context,
                                                  )!.sign_up,
                                              style: TextStyle(
                                                fontFamily: 'Mplus1p',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 14,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                              recognizer:
                                                  TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Navigator.of(
                                                        context,
                                                      ).pushReplacement(
                                                        MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  SignUpScreen(),
                                                        ),
                                                      );
                                                    },
                                            ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 22,
                                          left: 8,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 35,
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              context
                                                  .read<AuthViewModel>()
                                                  .clearErrors();
                                              isLoading = true;
                                            });

                                            String email =
                                                emailController.text.trim();
                                            String password =
                                                passwordController.text.trim();

                                            if (await Provider.of<
                                              AuthViewModel
                                            >(
                                              context,
                                              listen: false,
                                            ).login(email, password)) {
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            }
                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
