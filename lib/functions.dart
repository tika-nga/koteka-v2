import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'application e-mail avec
/// une adresse et un sujet préremplis.
Future<void> goToMail(
  String email,
  BuildContext context, {
  String subject = '',
}) async {
  String encodeQueryParameters(
    Map<String, String> params,
  ) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}='
              '${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  final emailUri = Uri(
    scheme: 'mailto',
    path: email,
    query: encodeQueryParameters(
      <String, String>{
        'subject': subject,
      },
    ),
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
    return;
  }

  throw Exception(
    'Impossible d’ouvrir l’application e-mail.',
  );
}

/// Ouvre un lien externe.
Future<void> runUrl(
  String url,
) async {
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    return;
  }

  throw Exception(
    'Impossible d’ouvrir le lien.',
  );
}

/// Transforme une durée en texte lisible.
String formatDuration(
  Duration duration,
) {
  final parts = <String>[];

  if (duration.inDays >= 2) {
    parts.add(
      '${duration.inDays} jours',
    );
  } else if (duration.inDays == 1) {
    parts.add('1 jour');
  }

  final hours =
      duration.inHours % 24;

  if (hours > 0) {
    parts.add('${hours}h');
  }

  final minutes =
      duration.inMinutes % 60;

  if (minutes > 0) {
    parts.add('${minutes}min');
  }

  final seconds =
      duration.inSeconds % 60;

  if (seconds > 0) {
    parts.add('${seconds}s');
  }

  if (parts.isEmpty) {
    return '0min';
  }

  return parts.join(' ');
}

/// Réessaie une opération plusieurs fois
/// avec un délai progressivement plus long.
Future<T> retry<T>(
  Future<T> Function() operation, {
  int attempts = 3,
}) async {
  for (var i = 0; i < attempts; i++) {
    try {
      return await operation();
    } catch (_) {
      final isLastAttempt =
          i == attempts - 1;

      if (isLastAttempt) {
        rethrow;
      }

      await Future.delayed(
        Duration(
          milliseconds:
              200 * (1 << i),
        ),
      );
    }
  }

  throw StateError(
    'Tentatives épuisées.',
  );
}
